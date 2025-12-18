Class GitShell {

    [string]$gitPath
    [string]$repoPath

    GitShell([string]$gitPath, [string]$repoPath) {
        $this.gitPath = $gitPath
        $this.repoPath = $repoPath
    }

    [string[]] GetGitBranches() {

        $output = $this.ExecuteGitCommand('branch --list --format="%(refname:short)" --no-color --no-column')

        $branches = $output -split '\r?\n' |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne '' }

        return $branches
    }

    [string] ExecuteSetDescription([string[]]$Args) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "git"
    $psi.Arguments = [string]::Join(' ', ($Args | ForEach-Object {
        # naive quoting: wrap each arg in quotes, escape inner quotes
        '"{0}"' -f ($_ -replace '"', '\"')
    }))
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute        = $false

    $p = [System.Diagnostics.Process]::Start($psi)
    $p.WaitForExit()

    return $p.StandardOutput.ReadToEnd()
}

[string] GetRepoRoot() {
    $out = $this.ExecuteGitCommand("rev-parse --show-toplevel")
    if ([string]::IsNullOrWhiteSpace($out)) { return $null }
    return $out.Trim()
}

[void] SetBranchDescription([string]$branchName, [string]$description) {

    $repoRoot = $this.GetRepoRoot()
    if (-not $repoRoot) { return }

    $metaDir = Join-Path $repoRoot ".git\magit-descriptions"

    if (-not (Test-Path $metaDir)) {
        New-Item -ItemType Directory -Path $metaDir | Out-Null
    }

    $file = Join-Path $metaDir ($branchName + ".txt")

    # Save exactly what the user wrote
    $description | Set-Content -Path $file -Encoding UTF8
}

    [string] GetBranchDescription([string]$branchName) {

        $repoRoot = $this.GetRepoRoot()
        if (-not $repoRoot) { return "" }

        $metaDir = Join-Path $repoRoot ".git\magit-descriptions"
        $file    = Join-Path $metaDir "$branchName.txt"

        if (-not (Test-Path $file)) { return "" }

        return Get-Content -Path $file -Raw -Encoding UTF8
    }

    <# [void] SetBranchDescription([string]$branchName, [string]$description) {

        $key   = "branch.$branchName.description"

        # normalize newlines to simple \n (your call if you want real multiline)
        $clean = ($description -replace "`r`n", "`n") -replace "`r", "`n"

        # Escape embedded double quotes for PowerShell / git
        $escaped = $clean -replace '"', '\"'

        # Important:
        #   --replace-all : avoid multiple values for same key
        #   `"...`"       : pass the whole description as ONE argument
        $cmd = "config --replace-all $key `"$escaped`""

        $null = $this.ExecuteGitCommand($cmd)
    } #>

    [string] ExecuteGitCommand([string]$command) {
        $oldLocation = Get-Location
        try {
            # Go to the repo path first
            Set-Location -Path $this.repoPath

            # Split the command string into args (good enough for simple commands)
            $args = $command -split ' '

            # Call git like from the console, capture stdout+stderr
            $output = git @args 2>&1
            $exitCode = $LASTEXITCODE

            if ($exitCode -ne 0) {
                $msg = ($output -join [Environment]::NewLine)
                throw "Git command failed with exit code $exitCode`n$msg"
            }

            return (($output -join [Environment]::NewLine).Trim())
        }
        finally {
            Set-Location $oldLocation
        }
    }

    [string] ExecuteGitCommand2([string]$command) {
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $this.gitPath
        $processInfo.Arguments = "-C `"$($this.repoPath)`" $command"
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        $process.Start() | Out-Null

        $output = $process.StandardOutput.ReadToEnd()
        $errorOutput = $process.StandardError.ReadToEnd()
        $process.WaitForExit()

        if ($process.ExitCode -ne 0) {
            throw "Git command failed: $errorOutput"
        }
 
        return $output.Trim()
    }

    [string] GetStatus() {
        return $this.ExecuteGitCommand("status --short")
    }

    [string] Commit([string]$message) {
        return $this.ExecuteGitCommand("commit -m `"$message`"")
    }

    [string] Push([string]$remote = "origin", [string]$branch = "main") {
        return $this.ExecuteGitCommand("push $remote $branch")
    }

    [string] Pull([string]$remote = "origin", [string]$branch = "main") {
        return $this.ExecuteGitCommand("pull $remote $branch")
    }
}
