# Felix
This funcion will perform a deletion of contents from file(s) without removing the file

Usage:  felix [-Extension] [-Path]

Currently valid extensions: .docx, .doc, .pdf, .pptx, .xlsx, .xls, .txt, .mp4, .mp3, .jpg, .jpeg, .png

- You can assign more than 1 extension at once
- Use felix * [-Path] to select all extensions
- The [-Path] parameter is optional, default value: C:\Users\$env:UserName\Documents
- Felix works recursively, so be careful!
