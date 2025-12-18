function Test-GitInstalled {
    $cmd = Get-Command git -ErrorAction SilentlyContinue
    return ($cmd -and $cmd.CommandType -eq 'Application')
}


# --- Main script logic ---

if (Get-Alias git -ErrorAction SilentlyContinue) {
    Remove-Item alias:git
}

if (Get-Command git -ErrorAction SilentlyContinue | Where-Object { $_.CommandType -eq 'Function' }) {
    Remove-Item function:git
}

$mainForm = $null  # or your real form

if (-not (Test-GitInstalled)) {
    $choice = Show-NoGitInstalledDialog -OwnerForm $mainForm

    if ($choice -eq "Install") {
        # Open default browser with a search for "git for windows"
        # (Change to Google/Bing if you prefer)
        Start-Process "https://www.google.com/search?q=git+for+windows"
        
    }

    # Close the program / end script
    if ($mainForm) {
        
    }

    [System.Environment]::Exit(0)
}

if (-not $PSBoundParameters.ContainsKey('Path') -and $args.Count -gt 0) {
    $Path = $args[0]
}
if ([string]::IsNullOrWhiteSpace($Path)) {
    $Path = (Get-Location).Path
}

# If running from Program Files (double-click), prompt for a folder
if ($Path -like 'C:\Program Files*' -or $Path -like "$env:ProgramFiles*") {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Select a working folder for GitNic"
    if ($dlg.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { exit 0 }
    $Path = $dlg.SelectedPath
}

$FormObject = [System.Windows.Forms.Form]
$LabelObject = [System.Windows.Forms.Label]
$ButtonObject = [System.Windows.Forms.Button]
$MessageBox = [System.Windows.Forms.MessageBox]

$git_response = git status;

$GitCheck = [GitCheck]::new()

$GitShell = [GitShell]::new("git", (Get-Location).Path)
$Controller = [Controller]::new((Get-Location).Path, $GitShell)

if (-not (IsThereAGitRepo((Get-Location).Path))) {
    $NoRepo_Form = [NoRepo_Frame]::new($Controller, (Get-Location).Path)
}

if($Controller.NoRepo_Form_Result -eq "Cancel"){

    [System.Environment]::Exit(0)
}

$MainForm = [MainForm]::new($Controller, (Get-Location).Path)
$MainForm.Form.Add_Shown({$MainForm.Form.Activate()})
[void]$MainForm.Form.ShowDialog()

