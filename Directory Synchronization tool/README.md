# Directory Synchronization Tool

This project is a **bash script** designed to synchronize the contents of two directories. The tool compares files between a source and a destination directory, updating the destination with the necessary changes. Key functionalities include:

- **File Synchronization:** Copy files from the source to the destination directory if they are missing or have been modified.
- **File Removal:** Remove files from the destination directory if they no longer exist in the source.
- **Recursive Directory Updates:** Optionally, update subdirectories recursively to ensure the destination directory mirrors the source.
- **User Confirmation:** The script prompts the user to confirm actions before proceeding with file copying, removal, or updates.

### How to Use
1. Run the script by providing two directories as arguments:
   ```bash
   ./directorysynchronizationtool.sh /path/to/source_directory /path/to/destination_directory
