param(
    [Parameter(Position = 0)]
    [AllowNull()]
    [AllowEmptyString()]
    [string]$Path
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Helper functions ---
function New-GitNicForm {
    New-Object System.Windows.Forms.Form
}

function New-GitNicLabel {
    New-Object System.Windows.Forms.Label
}

function New-GitNicTableLayoutPanel {
    New-Object System.Windows.Forms.TableLayoutPanel
}

function New-GitNicButton {
    New-Object System.Windows.Forms.Button
}

function New-GitNicPadding {
    param([int]$left, [int]$top, [int]$right, [int]$bottom)
    New-Object System.Windows.Forms.Padding($left, $top, $right, $bottom)
}

function New-GitNicSize {
    param([int]$width, [int]$height)
    New-Object System.Drawing.Size($width, $height)
}

function New-GitNicPoint {
    param([int]$x, [int]$y)
    New-Object System.Drawing.Point($x, $y)
}

function New-GitNicTextBox {
    $rtb = New-Object System.Windows.Forms.RichTextBox
    $rtb.BorderStyle = 'None'
    $rtb.ScrollBars  = 'Vertical'
    $rtb.BackColor   = [System.Drawing.Color]::FromArgb(0,0,0)
    $rtb.ForeColor   = [System.Drawing.Color]::FromArgb(220,220,220)
    return $rtb
}

function New-GitNicFont {
    param(
        [string]$family,
        [float] $size,
        [string]$style = 'Regular'
    )
    $styleEnum = [System.Drawing.FontStyle]::$style
    New-Object System.Drawing.Font($family, $size, $styleEnum)
}

function New-GitNicColor {
    param([int]$r, [int]$g, [int]$b)
    [System.Drawing.Color]::FromArgb($r, $g, $b)
}

function Show-GitNicMessageBox {
    param(
        [string]$Text,
        [string]$Caption = "",
        [string]$Buttons = "OK",
        [string]$Icon    = "None"
    )

    $buttonsEnum = [System.Windows.Forms.MessageBoxButtons]::$Buttons
    $iconEnum    = [System.Windows.Forms.MessageBoxIcon]::$Icon

    # Return the raw DialogResult
    [System.Windows.Forms.MessageBox]::Show($Text, $Caption, $buttonsEnum, $iconEnum)
}

function Add-GitNicRowStylePercent {
    param(
        [object]$RowStyles,
        [int]$Percent
    )

    $style = New-Object System.Windows.Forms.RowStyle
    $style.SizeType = [System.Windows.Forms.SizeType]::Percent
    $style.Height   = $Percent
    [void]$RowStyles.Add($style)
}

function Add-GitNicColumnStylePercent {
    param(
        [object]$ColumnStyles,
        [int]$Percent
    )

    $style = New-Object System.Windows.Forms.ColumnStyle
    $style.SizeType = [System.Windows.Forms.SizeType]::Percent
    $style.Width    = $Percent
    [void]$ColumnStyles.Add($style)
}

function Show-GitNicInstallPrompt {
    param(
        [string]$Text,
        [string]$Caption
    )

    $result = [System.Windows.Forms.MessageBox]::Show(
        $Text,
        $Caption,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    return ($result -eq [System.Windows.Forms.DialogResult]::Yes)
}

function Show-GitNicProgressDialog {
    param(
        [string]$Title,
        [string]$Message,
        [int]   $DurationMs = 3000,
        [System.Windows.Forms.Form]  $OwnerForm,
        [ScriptBlock]$OnComplete
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    if ($DurationMs -le 0) { $DurationMs = 1 }

    # --- Form ---
    $form                  = New-Object System.Windows.Forms.Form
    $form.Text             = $Title
    
    $form.StartPosition    = 'Manual'
    $form.FormBorderStyle  = 'None'
    $form.MaximizeBox      = $false
    $form.MinimizeBox      = $false
    $form.Size             = [System.Drawing.Size]::new(200, 125)
    $form.BackColor        = [System.Drawing.Color]::White
    $form.ForeColor        = [System.Drawing.Color]::White
    $form.TopMost          = $true
    $form.Padding          = 2

    # Dark inner border panel
    $border = New-Object System.Windows.Forms.Panel
    $border.BackColor = [System.Drawing.Color]::FromArgb(25,25,25)
    $border.Dock = 'Fill'
    $border.Padding = [System.Windows.Forms.Padding]::new(10, 10, 10, 10)
    $form.Controls.Add($border)
    $border.SendToBack()

    # --- Position relative to owner or screen ---
    if ($OwnerForm) {
        $x = $OwnerForm.Left + [int](($OwnerForm.Width  - $form.Width)  / 2)
        $y = $OwnerForm.Top  + [int](($OwnerForm.Height - $form.Height) / 2)
        $form.Location = [System.Drawing.Point]::new($x, $y)
        $form.Owner = $OwnerForm
    }
    else {
        $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
        $x = $screen.Left + [int](($screen.Width  - $form.Width)  / 2)
        $y = $screen.Top  + [int](($screen.Height - $form.Height) / 2)
        $form.Location = [System.Drawing.Point]::new($x, $y)
    }

    # --- Label ---
    $label = New-Object System.Windows.Forms.Label
    $label.Text      = $Message
    $label.AutoSize  = $false
    $label.Dock      = 'Top'
    $label.Height    = 40
    $label.TextAlign = 'MiddleCenter'
    $label.Font      = [System.Drawing.Font]::new("Consolas", 16, [System.Drawing.FontStyle]::Bold)

    # --- Fake progress bar using panels ---

    # Outer track (background)
    $track               = New-Object System.Windows.Forms.Panel
    $track.Width         = 150
    $track.Height        = 16
    $track.BackColor     = [System.Drawing.Color]::FromArgb(40,40,40)
    $track.BorderStyle   = 'FixedSingle'
    $track.Top           = 50
    # center within the inner border's client area
    $track.Left          = [int](($border.ClientSize.Width - $track.Width) / 2)
    $track.Anchor        = 'Top'

    # Inner fill (the "bar")
    $fill                = New-Object System.Windows.Forms.Panel
    $fill.Height         = $track.ClientSize.Height - 4
    $fill.Width          = 0
    $fill.Left           = 2
    $fill.Top            = 2
    $fill.BackColor      = [System.Drawing.Color]::White  # nice blue

    $track.Controls.Add($fill)

    # --- Cancel button ---
    $cancelBtn              = New-Object System.Windows.Forms.Button
    $cancelBtn.Text         = "Cancel"
    $cancelBtn.Font         = [System.Drawing.Font]::new("Consolas", 10, [System.Drawing.FontStyle]::Bold)
    $cancelBtn.Height       = 30
    $cancelBtn.Width        = 80
    $cancelBtn.Top          = $border.ClientSize.Height - $cancelBtn.Height - 15
    $cancelBtn.Left         = [int](($border.ClientSize.Width - $cancelBtn.Width) / 2)

    $cancelled = $false

    $cancelBtn.Add_Click({
        Set-Variable -Name cancelled -Scope 1 -Value $true
        $form.Close()
    })

    # Add controls to the inner border panel
    $border.Controls.Add($cancelBtn)
    $border.Controls.Add($track)
    $border.Controls.Add($label)

    # --- Show non-modally & run our own loop ---
    $form.Show()
    # bump it up a bit visually if you like
    $form.Location = [System.Drawing.Point]::new($form.Location.X, $form.Location.Y - 150)

    $start   = Get-Date
    $totalMs = [double]$DurationMs

    while ($form.Visible -and -not $cancelled) {
        $now       = Get-Date
        $elapsedMs = (New-TimeSpan -Start $start -End $now).TotalMilliseconds

        # Compute percent
        $percent = [int][Math]::Min(100.0, 100.0 * $elapsedMs / $totalMs)
        if ($percent -lt 0)   { $percent = 0 }
        if ($percent -gt 100) { $percent = 100 }

        # Update fake bar width
        $fill.Width = [int]($track.ClientSize.Width * $percent / 100.0)

        if ($elapsedMs -ge $totalMs) {
            break
        }

        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 50
    }

    # Decide if we really finished by time (not cancelled / not X)
    $now           = Get-Date
    $elapsedMs     = (New-TimeSpan -Start $start -End $now).TotalMilliseconds
    $finishedByTime = (-not $cancelled) -and ($elapsedMs -ge $totalMs)

    # Force bar to 100% once finished (if not cancelled), so visually hits the end
    if (-not $cancelled) {
        $fill.Width = $track.ClientSize.Width
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
    }

    if ($form.Visible) {
        $form.Close()
    }

    if ($finishedByTime -and $OnComplete) {
        & $OnComplete
    }
}


function Show-GitNicToastDialog {
    param(
        [string]$Message,
        [int]$DurationMs = 1300,
        [System.Windows.Forms.Form]$OwnerForm
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    if ($DurationMs -le 0) { $DurationMs = 1 }

    # --- Create form ---
    $form                 = New-Object System.Windows.Forms.Form
    $form.FormBorderStyle = 'None'
    $form.StartPosition   = 'Manual'
    $form.BackColor       = [System.Drawing.Color]::White
    $form.ForeColor       = [System.Drawing.Color]::White
    $form.Width           = 200
    $form.Height          = 75
    $form.TopMost         = $true
    $form.ShowInTaskbar   = $false
    $form.Padding = 2

    $border = New-Object System.Windows.Forms.Panel
    $border.BackColor = [System.Drawing.Color]::FromArgb(25,25,25)
    $border.Dock = 'Fill'   # It fills the form
    $form.Controls.Add($border)
    $border.SendToBack()
    $border.Padding = [System.Windows.Forms.Padding]::new(10, 10, 10, 10)

    # --- Label ---
    $label = New-Object System.Windows.Forms.Label
    $label.Dock           = 'Fill'
    $label.TextAlign      = 'MiddleCenter'
    $label.Font           = [System.Drawing.Font]::new("Consolas", 16, [System.Drawing.FontStyle]::Bold)
    $label.Text           = $Message
    $label.ForeColor      = [System.Drawing.Color]::White
    $label.BackColor      = [System.Drawing.Color]::Transparent

    $border.Controls.Add($label)

    # --- Position relative to owner or center screen ---
    if ($OwnerForm) {
        $x = $OwnerForm.Left + [int](($OwnerForm.Width  - $form.Width)  / 2)
        $y = $OwnerForm.Top  + [int](($OwnerForm.Height - $form.Height) / 2)
        $form.Location = [System.Drawing.Point]::new($x, $y)
        $form.Owner = $OwnerForm
    }
    else {
        # Fallback: center screen
        $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
        $x = $screen.Left + [int](($screen.Width  - $form.Width)  / 2)
        $y = $screen.Top  + [int](($screen.Height - $form.Height) / 2)
        $form.Location = [System.Drawing.Point]::new($x, $y)
    }

    # --- Show + timing loop ---
    $form.Show()
    $form.Location = [System.Drawing.Point]::new($form.Location.X, $form.Location.Y - 150)
    $start = Get-Date
    $totalMs = [double]$DurationMs

    while ($form.Visible) {
        $elapsed = (New-TimeSpan -Start $start -End (Get-Date)).TotalMilliseconds
        if ($elapsed -ge $totalMs) { break }

        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 20
    }

    if ($form.Visible) { $form.Close() }
}

function Show-NoGitInstalledDialog {
    param(
        [System.Windows.Forms.Form]$OwnerForm
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # --- Form ---
    $form = New-Object System.Windows.Forms.Form
    $form.Text            = "Git not installed"
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox     = $false
    $form.MinimizeBox     = $false
    $form.ShowInTaskbar   = $false
    $form.TopMost         = $true
    $form.StartPosition   = if ($OwnerForm) { 'CenterParent' } else { 'CenterScreen' }
    $form.ClientSize      = [System.Drawing.Size]::new(420, 150)

    if ($OwnerForm) {
        $form.Owner = $OwnerForm
    }

    # --- Label ---
    $label = New-Object System.Windows.Forms.Label
    $label.AutoSize   = $false
    $label.Dock       = 'Top'
    $label.Height     = 90
    $label.TextAlign  = 'MiddleCenter'
    $label.Padding    = [System.Windows.Forms.Padding]::new(10, 20, 10, 10)
    $label.Text       = "No Git installation was detected.`r`n`r`nYou need to download and install Git for Windows."
    $form.Controls.Add($label)

    # --- Buttons ---
    $buttonWidth  = 100
    $buttonHeight = 30
    $bottomMargin = 15
    $gap          = 10

    # Install button
    $btnInstall = New-Object System.Windows.Forms.Button
    $btnInstall.Text   = "Install"
    $btnInstall.Width  = $buttonWidth
    $btnInstall.Height = $buttonHeight
    $btnInstall.Anchor = 'Bottom,Right'
    $btnInstall.Location = [System.Drawing.Point]::new(
        $form.ClientSize.Width - (2 * $buttonWidth + $gap + 15),
        $form.ClientSize.Height - $buttonHeight - $bottomMargin
    )
    $btnInstall.Add_Click({
        $form.Tag = "Install"
        $form.Close()
    })
    $form.Controls.Add($btnInstall)

    # Cancel button
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text   = "Cancel"
    $btnCancel.Width  = $buttonWidth
    $btnCancel.Height = $buttonHeight
    $btnCancel.Anchor = 'Bottom,Right'
    $btnCancel.Location = [System.Drawing.Point]::new(
        $form.ClientSize.Width - ($buttonWidth + 15),
        $form.ClientSize.Height - $buttonHeight - $bottomMargin
    )
    $btnCancel.Add_Click({
        $form.Tag = "Cancel"
        $form.Close()
    })
    $form.Controls.Add($btnCancel)

    $form.AcceptButton = $btnInstall
    $form.CancelButton = $btnCancel

    # --- Show dialog ---
    [void]$form.ShowDialog($OwnerForm)
    return $form.Tag
}

function Invoke-GitHidden {
    param(
        [string]$RepoPath,
        [string]$Arguments
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'git'                     # call git.exe directly
    $psi.Arguments = $Arguments
    $psi.WorkingDirectory = $RepoPath
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow  = $true
    $psi.WindowStyle     = 'Hidden'

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $process.Start() | Out-Null

    # Read both streams so nothing is left to be emitted to console
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    return [PSCustomObject]@{
        ExitCode = $process.ExitCode
        Output   = $stdout.Trim()
        Error    = $stderr.Trim()
    }
}

function IsThereAGitRepo([string]$path) {
    $result = Invoke-GitHidden -RepoPath $path -Arguments 'rev-parse --is-inside-work-tree --quiet'
    # Do not write result.Output or result.Error to host; check exit code only
    return ($result.ExitCode -eq 0)
}