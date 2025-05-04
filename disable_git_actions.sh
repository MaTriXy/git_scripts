#!/bin/bash
# Script to disable all workflows in multiple GitHub repositories
# Make sure you have GitHub CLI installed and authenticated with sufficient permissions

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. Please install it first: https://cli.github.com/manual/installation"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Please authenticate with GitHub CLI first: gh auth login"
    exit 1
fi

# Read repositories from file or input
REPOS_FILE="repositories.txt"

if [ ! -f "$REPOS_FILE" ]; then
    echo "Creating repositories file..."
    cat > "$REPOS_FILE" << EOL
# ... Add all other repositories here
EOL
    echo "Please edit the $REPOS_FILE file to include all repositories, then run this script again."
    exit 0
fi

# Function to extract owner and repo from URL
parse_repo_url() {
    local url=$1
    # Extract owner and repo from URL
    local owner_repo=${url#https://github.com/}
    echo "$owner_repo"
}

# Log file
LOG_FILE="disable_workflows_log.txt"
echo "Starting workflow disabling process at $(date)" > "$LOG_FILE"

# Process each repository
echo "Starting to process repositories..."
total=$(wc -l < "$REPOS_FILE")
current=0

while IFS= read -r repo_url || [ -n "$repo_url" ]; do
    # Skip empty lines or comments
    [[ -z "$repo_url" || "$repo_url" =~ ^# ]] && continue
    
    current=$((current + 1))
    echo "[$current/$total] Processing $repo_url"
    
    # Parse the URL to get owner/repo
    owner_repo=$(parse_repo_url "$repo_url")
    
    echo "Getting workflows for $owner_repo"
    # List all workflows and extract IDs
    workflows=$(gh api "repos/$owner_repo/actions/workflows" --jq '.workflows[] | .id, .name, .state')
    
    if [ -z "$workflows" ]; then
        echo "No workflows found for $owner_repo" | tee -a "$LOG_FILE"
        continue
    fi
    
    # Process each workflow
    while read -r id && read -r name && read -r state; do
        if [ "$state" = "active" ]; then
            echo "Disabling workflow: $name (ID: $id)"
            
            # Disable the workflow
            if gh api -X PUT "repos/$owner_repo/actions/workflows/$id/disable" &> /dev/null; then
                echo "Successfully disabled workflow: $name (ID: $id) in $owner_repo" | tee -a "$LOG_FILE"
            else
                echo "Failed to disable workflow: $name (ID: $id) in $owner_repo" | tee -a "$LOG_FILE"
            fi
        else
            echo "Workflow already disabled: $name (ID: $id) in $owner_repo" | tee -a "$LOG_FILE"
        fi
    done <<< "$workflows"
    
    echo "Completed processing $owner_repo"
    echo "----------------------------------------"
done < "$REPOS_FILE"

echo "All repositories processed. Check $LOG_FILE for detailed results."
