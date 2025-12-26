# Felix
This script will perform a removal of contents from file(s) by overwriting them in multiple iterations.

Setup: Import-Module .\Felix.ps1  
Usage: Felix -e [Extensions] -p [Path] -n [iteration (default is 3)] -r [recurse]

- Use ',' separator for multiple extensions
- Use '*' to assign all extensions that exist in the selected path
- More iteration will take longer to process, especially for path with many sub directories
- Recurse mode is optional. Default is off
