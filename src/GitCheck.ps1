class GitCheck {

    GitCheck() {
        if ($this.TestGitAvailable() -eq $null) {
            $this.PromptInstallGit()
        }

        # (Optional) double-check git actually runs:
        $null = git --version
        if ($LASTEXITCODE -ne 0) { $this.PromptInstallGit() }
    }

    [string] TestGitAvailable() {
        $cmd = Get-Command git -ErrorAction SilentlyContinue
        return $null -ne $cmd
    }

    [void] PromptInstallGit() {

        $msg = "Git was not found on this system.`n`nWould you like to open the Git for Windows download page?"

        # Call the helper function (defined in Main.ps1)
        $userWantsGit = Show-MagitInstallPrompt -Text $msg -Caption "Git Not Found"

        if ($userWantsGit) {
            Start-Process "https://git-scm.com/download/win"
        }

        # Quit the app if Git isn't available
        exit 1
    }
}
