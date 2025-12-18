
# GitNic

GitNic is a small Windows tool written in PowerShell, intended as an entry point
for beginners who want to interact with Git through a simple interface.

If you choose to run the installer (and ignore the Windows warning),
GitNic will be installed to `Program Files\GitNic`.

The installer does not modify the system PATH, but adds GitNic to the
Windows Explorer context menu.

The application can be uninstalled by navigating to
`Program Files\GitNic` and running `uninstall.cmd` as administrator.

## Features
- Explorer context menu integration
- Git repository detection
- Simple UI for common Git actions
- Install and uninstall scripts

## Project Structure
- `src/` – Core PowerShell source files
- `build.ps1` – Build script
- `dev_uninstall.ps1` – Development cleanup script

## Notes
This project was created as a hobby tool.
The code is not recently refactored, but the repository demonstrates
PowerShell scripting, Windows integration, and basic UI logic.