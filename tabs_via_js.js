// Function to read the file and open URLs
function openUrlsFromFile() {
  // Create a file input element
  const fileInput = document.createElement('input');
  fileInput.type = 'file';
  fileInput.accept = '.txt';
  
  // Handle the file selection
  fileInput.addEventListener('change', (event) => {
    const file = event.target.files[0];
    if (!file) return;
    
    // Read the file
    const reader = new FileReader();
    reader.onload = (e) => {
      // Parse URLs from the file content
      const urls = e.target.result.trim().split('\n');
      
      // Display count and ask for confirmation
      if (confirm(`About to open ${urls.length} tabs. Continue?`)) {
        // Open each URL in a new tab
        urls.forEach(url => {
          if (url && !url.startsWith('#')) {
            window.open(url.trim(), '_blank');
          }
        });
      }
    };
    
    reader.readAsText(file);
  });
  
  // Trigger the file dialog
  fileInput.click();
}

// Call the function
openUrlsFromFile();

// This code:

// Creates a file input element
// Sets up an event listener to handle when a file is selected
// Reads the selected text file
// Parses the URLs (skipping empty lines and comments starting with #)
// Shows a confirmation dialog with the number of tabs that will be opened
// Opens each URL in a new tab if confirmed

// To use it:

// Copy this code
// Open your browser's developer console (F12 or right-click and select "Inspect" then go to Console tab)
// Paste and run the code
// Select your text file containing the URLs (one URL per line)

// Note: Most browsers will block multiple tabs from opening automatically. You may need to allow pop-ups for the site you're running this on, or the browser might only open a few tabs at a time.
