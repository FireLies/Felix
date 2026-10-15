# Felix
### File wiping by overwriting them using random bytes.
![Version](https://img.shields.io/badge/version-v2.2-green)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1-%234281f5)
![License](https://img.shields.io/badge/License-MIT-%23f5952f)

**Setup: Import-Module .\Felix.ps1**

Usage: Felix [-e Extensions] [-p Path] [-n iteration (default is 1)] [-r recurse]

- Run BypassPolicy.bat to bypass the script execution policy and import the module
- Use ',' separator for multiple extensions
- Use '*' to assign all extensions that exist in the selected path
- More iteration will take longer to process, especially for path with many sub directories
- Recurse mode is optional. Default is off