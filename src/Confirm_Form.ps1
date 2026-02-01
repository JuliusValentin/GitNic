Class Confirm_Form {

    [Controller] $Controller
    [string]     $Result = "No"

    Confirm_Form([Controller]$controller, [string]$title, [string]$message, [string[]]$deletedFiles = @(), [string[]]$modifiedFiles = @()) {
        $this.Controller = $controller

        $form = New-Object System.Windows.Forms.Form
        $form.Text = $title
        $form.StartPosition = "CenterScreen"
        $form.Size = [System.Drawing.Size]::new(320, 360)
        $form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
        $form.ForeColor = [System.Drawing.Color]::White
        $form.FormBorderStyle = 'FixedDialog'
        $form.MaximizeBox     = $false
        $form.MinimizeBox     = $true

        $form.Add_Shown({
            param($sender, $eventArgs)
            $sender.TopMost = $true
            $sender.Activate()
            $sender.TopMost = $false
        })

        $label = New-Object System.Windows.Forms.Label
        $label.Text = $message
        $label.AutoSize = $false
        $label.Width = 280
        $label.Height = 70
        $label.Font = New-GitNicFont "Consolas" 10 'Bold'
        $label.Location = New-Object System.Drawing.Point(20, 12)
        $label.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
        $label.ForeColor = [System.Drawing.Color]::White
        $form.Controls.Add($label)

        $detailsBox = $null
        if (
            ($deletedFiles -and $deletedFiles.Count -gt 0) -or
            ($modifiedFiles -and $modifiedFiles.Count -gt 0)
        ) {
            $lines = New-Object System.Collections.Generic.List[string]

            if ($deletedFiles -and $deletedFiles.Count -gt 0) {
                $lines.Add("These files will be deleted:")
                $lines.Add("")
                foreach ($f in $deletedFiles) {
                    $lines.Add("    $f")
                }
            }

            if ($modifiedFiles -and $modifiedFiles.Count -gt 0) {
                if ($lines.Count -gt 0) {
                    $lines.Add("")
                    $lines.Add("All changes to these files will be gone:")
                    $lines.Add("")
                }
                else {
                    $lines.Add("All changes to these files will be gone:")
                    $lines.Add("")
                }
                foreach ($f in $modifiedFiles) {
                    $lines.Add("    $f")
                }
            }

            $detailsBox = New-Object System.Windows.Forms.TextBox
            $detailsBox.Location = New-Object System.Drawing.Point(20, 95)
            $detailsBox.Size = New-Object System.Drawing.Size(280, 190)
            $detailsBox.Multiline = $true
            $detailsBox.ReadOnly = $true
            $detailsBox.ScrollBars = 'Vertical'
            $detailsBox.BorderStyle = 'None'
            $detailsBox.BackColor = [System.Drawing.Color]::FromArgb(0,0,0)
            $detailsBox.ForeColor = [System.Drawing.Color]::FromArgb(220,220,220)
            $detailsBox.Font = New-GitNicFont "Consolas" 11 'Regular'
            $detailsBox.TabStop = $false
            $detailsBox.ShortcutsEnabled = $false
            $detailsBox.HideSelection = $true
            $detailsBox.Cursor = [System.Windows.Forms.Cursors]::Default
            $detailsBox.Text = ($lines -join "`r`n")
            $form.Controls.Add($detailsBox)
        }

        $button_yes = New-Object System.Windows.Forms.Button
        $button_yes.Text = "Yes"
        $button_yes.Font = New-GitNicFont "Consolas" 10 'Bold'
        $button_yes.Location = New-Object System.Drawing.Point(60, 300)
        $button_yes.AutoSize = $true

        $button_no = New-Object System.Windows.Forms.Button
        $button_no.Text = "No"
        $button_no.Font = New-GitNicFont "Consolas" 10 'Bold'
        $button_no.Location = New-Object System.Drawing.Point(170, 300)
        $button_no.AutoSize = $true

        $confirmForm = $this

        $button_yes.Add_Click({
            $confirmForm.Result = "Yes"
            $form.Close()
        })

        $button_no.Add_Click({
            $confirmForm.Result = "No"
            $form.Close()
        })

        $form.Controls.Add($button_yes)
        $form.Controls.Add($button_no)

        $form.ShowDialog() | Out-Null
        $form.Dispose()
    }
}
