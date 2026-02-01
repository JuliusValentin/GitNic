class MainForm {

    [object]        $Form
    [object]        $Grid
    [hashtable]     $SlotButtons
    [Controller]    $Controller
    [string]        $CurrentClickedSlot
    [bool]          $button_been_pressed      = $false
    [bool]          $branch_with_save_clicked = $false
    [object]        $save_button
    [object]        $load_button

    [object]        $TopPanel

    [object]        $DirLabel

    # Description box
    [object] $SavePanel
    [object] $DescHeaderLabel
    [object] $DescTextBox
    [object] $DescFooterLabel

    # Temporary button for highlighting
    [object] $SelectedButton
    [object] $SelectedBackColor
    [object] $SelectedForeColor

    # SlotPanel
    [object] $InfoPanel         
    [object] $SlotPanel
    [object] $SlotBigLabel
    [object] $SlotSmallLabel


    MainForm([Controller]$controller, [string]$directory) {

        $this.Controller  = $controller
        $this.SlotButtons = @{}

    # Form

        $this.Form               = New-GitNicForm
        $this.Form.Text          = "GitUI"
        $this.Form.StartPosition = 'CenterScreen'
        $this.Form.Size          = New-GitNicSize 300 550
        $this.Form.BackColor     = New-GitNicColor 20 20 20
        $this.Form.ForeColor     = New-GitNicColor 255 255 255  # this *usually* works fine, but if it complains, we can make a helper

        $this.Form.FormBorderStyle = 'FixedDialog'
        $this.Form.MaximizeBox     = $false
        $this.Form.MinimizeBox     = $true 

        $this.Form.Add_Shown({
            param($sender, $eventArgs)
            $sender.TopMost = $true
            $sender.Activate()
            $sender.TopMost = $false
        })

    # --- Top panel to host path label + description textbox ---

        $this.TopPanel         = New-Object System.Windows.Forms.Panel
        $this.TopPanel.Dock    = 'Top'
        $this.TopPanel.Height  = 200
        $this.TopPanel.Padding = New-GitNicPadding 10 20 10 10
        $this.TopPanel.BackColor = New-GitNicColor 20 20 20

        # Directory label (normal mode)

            $this.DirLabel             = New-GitNicLabel
            $this.DirLabel.Dock        = 'Fill'
            $this.DirLabel.TextAlign   = 'MiddleLeft'
            $this.DirLabel.BorderStyle = 'FixedSingle'
            $this.DirLabel.BorderStyle = 'None'
            $this.DirLabel.BackColor   = New-GitNicColor 0 0 0
            $this.DirLabel.ForeColor   = New-GitNicColor 220 220 220
            $this.DirLabel.Font        = New-GitNicFont "Consolas" 10 'Regular'
            $this.SetDirectory($directory)

        # Description textbox (edit mode, overlays label)

            # === Description panel (for saves) ===

            $this.SavePanel               = New-Object System.Windows.Forms.Panel
            $this.SavePanel.Dock          = 'Fill'
            $this.SavePanel.Visible       = $false
            $this.SavePanel.BackColor     = New-GitNicColor 0 0 0
            $this.SavePanel.Dock          = 'Fill'

            $this.DescHeaderLabel           = New-GitNicLabel
            $this.DescHeaderLabel.Dock      = 'Top'
            $this.DescHeaderLabel.Height    = 24
            $this.DescHeaderLabel.TextAlign = 'MiddleLeft'
            $this.DescHeaderLabel.Font      = New-GitNicFont "Consolas" 11 'Bold'
            $this.DescHeaderLabel.ForeColor = New-GitNicColor 200 200 200
            $this.DescHeaderLabel.BackColor = New-GitNicColor 0 0 0

            $this.DescTextBox               = New-GitNicTextBox
            $this.DescTextBox.Dock          = 'Fill'
            $this.DescTextBox.Height        = 152
            $this.DescTextBox.Multiline     = $true
            $this.DescTextBox.MaxLength     = 192
            $this.DescTextBox.WordWrap      = $true
            $this.DescTextBox.ScrollBars    = 'Vertical'

            $tb = $this.DescTextBox   # or $this.YourTextBox
            $tb.Multiline = $true

            $tb.Add_TextChanged({

                $maxLines = 100
                $box = $tb

                $lineCount = $box.Lines.Length
                # Debug if you want:
                # Write-Host "Lines: $lineCount"

                if ($lineCount -le $maxLines) { return }

                # Trim from end until lines <= maxLines
                while ($box.Lines.Length -gt $maxLines -and $box.Text.Length -gt 0) {
                    $box.Text = $box.Text.Substring(0, $box.Text.Length - 1)
                }

                $box.SelectionStart = $box.Text.Length
                $box.ScrollToCaret()
            })
            
            $this.DescTextBox.BackColor     = New-GitNicColor 0 0 0
            $this.DescTextBox.ForeColor     = New-GitNicColor 220 220 220
            $this.DescTextBox.Font          = New-GitNicFont "Consolas" 11 'Regular'
            $this.DescTextBox.Enabled       = $true

            $mainForm = $this
            
            $this.form.Add_Closing({
                param($sender, $e)

                $mainForm.SaveCurrentDescription()
            })

            $this.DescTextBox.Add_Leave({

                $mainForm.SaveCurrentDescription()
            })

            $this.DescFooterLabel           = New-GitNicLabel
            $this.DescFooterLabel.Dock      = 'Bottom'
            $this.DescFooterLabel.Height    = 24
            $this.DescFooterLabel.TextAlign = 'MiddleRight'
            $this.DescFooterLabel.Font      = New-GitNicFont "Consolas" 8 'Regular'
            $this.DescFooterLabel.ForeColor = New-GitNicColor 200 200 200
            $this.DescFooterLabel.BackColor = New-GitNicColor 0 0 0

            $this.SavePanel.Controls.Add($this.DescTextBox)
            $this.SavePanel.Controls.Add($this.DescFooterLabel)
            $this.SavePanel.Controls.Add($this.DescHeaderLabel)

            # $this.DescTextBox.Text        = ""
            # $this.DescTextBox.Enabled     = $false
            # $this.DescTextBox.Visible     = $false
            

        # SlotPanel

            $this.SlotPanel              = New-Object System.Windows.Forms.Panel
            $this.SlotPanel.Dock         = 'Fill'
            $this.SlotPanel.Visible      = $false

            $this.SlotBigLabel           = New-GitNicLabel
            $this.SlotBigLabel.Dock      = 'Top'
            $this.SlotBigLabel.Height    = 130
            $this.SlotBigLabel.TextAlign = 'MiddleCenter'
            $this.SlotBigLabel.Font      = New-GitNicFont "Consolas" 28 'Bold'
            $this.SlotBigLabel.ForeColor = New-GitNicColor 240 240 240
            $this.SlotBigLabel.BackColor = New-GitNicColor 0 0 0

            $this.SlotSmallLabel           = New-GitNicLabel
            $this.SlotSmallLabel.Dock      = 'Top'
            $this.SlotSmallLabel.Height    = 70
            $this.SlotSmallLabel.TextAlign = 'TopCenter'
            $this.SlotSmallLabel.Font      = New-GitNicFont "Consolas" 10 'Regular'
            $this.SlotSmallLabel.ForeColor = New-GitNicColor 200 200 200
            $this.SlotSmallLabel.BackColor = New-GitNicColor 0 0 0

            $this.SlotPanel.Controls.Add($this.SlotSmallLabel)
            $this.SlotPanel.Controls.Add($this.SlotBigLabel)

        # Add the conttrols

            $this.TopPanel.Controls.Add($this.SavePanel)
            $this.TopPanel.Controls.Add($this.SlotPanel)
            $this.TopPanel.Controls.Add($this.DirLabel)

    # Grid 4x5 (center)

        $this.Grid             = New-GitNicTableLayoutPanel
        $this.Grid.Dock        = 'Fill'
        $this.Grid.Padding     = New-GitNicPadding 8 8 8 8
        $this.Grid.RowCount    = 4
        $this.Grid.ColumnCount = 5

    # Reset selection when clicking blank areas of the form

        $this.Form.Add_Click({
            $mainForm.reset_buttons()
        })

        $this.TopPanel.Add_Click({
            $mainForm.reset_buttons()
        })

        $this.DirLabel.Add_Click({
            $mainForm.reset_buttons()
        })

        
        $this.Grid.Add_Click({
            $mainForm.reset_buttons()
        })


        for ($r = 0; $r -lt 4; $r++) {
        Add-GitNicRowStylePercent -RowStyles $this.Grid.RowStyles -Percent 25
        }

        for ($c = 0; $c -lt 5; $c++) {
            Add-GitNicColumnStylePercent -ColumnStyles $this.Grid.ColumnStyles -Percent 20
        }

    # Create buttons

        for ($i=1; $i -le 5; $i++) {
            $btn = $this.CreateButton($i, 20, 0)
            $this.SlotButtons[$i] = $btn
        }

        for ($i=6; $i -le 10; $i++) {
            $btn = $this.CreateButton($i, 150, 5)
            $this.SlotButtons[$i] = $btn
        }

        foreach ($btn in $this.SlotButtons.Values) {
            $this.Form.Controls.Add($btn)
        }

    # Save button

        $this.save_button        = New-GitNicButton
        $this.save_button.Text   = "Save"
        $this.save_button.Tag    = "save_button"
        $this.save_button.Font   = New-GitNicFont "Consolas" 15 'Bold'
        $this.save_button.Size   = New-GitNicSize 120 50
        $this.save_button.Location = New-GitNicPoint 20 450

        $this.save_button.FlatStyle = 'Flat'
        $this.save_button.FlatAppearance.BorderSize = 2
        $this.save_button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0, 0, 0)

        $mainForm = $this
        $this.save_button.Add_Click({ $mainForm.SaveButton() })

    # Load button

        $this.load_button        = New-GitNicButton
        $this.load_button.Text   = "Load"
        $this.load_button.Tag    = "load_button"
        $this.load_button.Font   = New-GitNicFont "Consolas" 15 'Bold'
        $this.load_button.Size   = New-GitNicSize 120 50
        $this.load_button.Location = New-GitNicPoint 150 450

        $this.load_button.FlatStyle = 'Flat'
        $this.load_button.FlatAppearance.BorderSize = 2
        $this.load_button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0, 0, 0)

        $this.load_button.Add_Click({ $mainForm.LoadButton() })

        $this.save_button.Enabled = $false
        $this.load_button.Enabled = $false

        $this.Form.Controls.Add($this.save_button)
        $this.Form.Controls.Add($this.load_button)

    # Add to form

        $this.Form.Controls.Add($this.Grid)
        $this.Form.Controls.Add($this.TopPanel)
        $this.UpdateBranches($this.Controller.GetBranches());
        $this.load_button.Enabled           = $true
        $this.save_button.Enabled           = $true

    }

    [object] CreateButton([int]$index , [int]$x_position, [int]$index_subtractor) {

        $btn           = New-GitNicButton
        $btn.Text      = "Slot - $index"
        $btn.Tag       = $index
        $btn.Size      = New-GitNicSize 120 40
        $btn.Font      = New-GitNicFont "Consolas" 8 'Bold'
        $btn.Location  = New-GitNicPoint $x_position (160 + (45 * ($index - $index_subtractor)))

        $btn.FlatStyle = 'Flat'
        $btn.FlatAppearance.BorderSize = 2
        $btn.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0, 0, 0)

        $mainForm = $this
        $btn.Add_Click({
            param($sender, $eventArgs)
            $mainForm.ClickOnButton($sender, [int]$sender.Tag)
        })

        return $btn
    }

    [void] SetDirectory([string]$path) {

        $path = $path.Trim()
        $this.DirLabel.Text = "$path"
        $this.Form.Text     = "GitUI"
    }

    [void] LoadButton () {

        if (-not $this.button_been_pressed) { return }
        if ($this.CurrentClickedSlot -match "Slot - ") { return }

        $statusOutput = $this.Controller.GitShell.GetStatus()
        $deletedFiles = @()
        $modifiedFiles = @()
        if (-not [string]::IsNullOrWhiteSpace($statusOutput)) {
            $statusLines = $statusOutput -split "`r?`n"
            foreach ($line in $statusLines) {
                if ([string]::IsNullOrWhiteSpace($line)) { continue }
                $status = $line.Substring(0, [Math]::Min(2, $line.Length)).Trim()
                $path = $line.Substring([Math]::Min(3, $line.Length)).Trim()
                if ($path -like ".gitnic*" -or $path -like ".gitnic\\*" -or $path -like ".gitnic/*") {
                    continue
                }
                if ($status -eq "??") {
                    $deletedFiles += $path
                } else {
                    $modifiedFiles += $path
                }
            }
        }

        $hasChanges = ($deletedFiles.Count -gt 0) -or ($modifiedFiles.Count -gt 0)
        if ($hasChanges) {
            $confirmForm = [Confirm_Form]::new(
                $this.Controller,
                "Confirm Load",
                "Are you sure you want to load this branch ?`nThis will overwrite your current working directory.",
                $deletedFiles,
                $modifiedFiles
            )
            if ($confirmForm.Result -ne 'Yes') { return }
        }

        $mainForm   = $this
        $slotText   = $this.CurrentClickedSlot   # e.g. "Save - 8 - 22NOV25"
        $branchName = $slotText.Replace(" - ", "_")

        Show-GitNicProgressDialog -Title "Loading" -Message "LOADING" -DurationMs 3000 -OwnerForm $mainForm.Form -OnComplete {

            Show-GitNicToastDialog -Title "Loaded" -Message "LOAD SUCCESSFULL" -OwnerForm $mainForm.Form

            $mainForm.Controller.LoadBranch($branchName)
            $mainForm.reset_buttons()
            $mainForm.UpdateBranches($mainForm.Controller.GetBranches())
            # no "Load Successful" box anymore

        }
    }

    [void] SaveButton() {

        if (-not $this.button_been_pressed) {
            
            return;
        }

        $branch_data = $this.CurrentClickedSlot -split " - "
        $branch_id   = [int]$branch_data[1]

        if ($this.branch_with_save_clicked) {
            $confirmForm = [Confirm_Form]::new(
                $this.Controller,
                "Overwrite?",
                "Are you sure you want to overwrite this save?"
            )
            if ($confirmForm.Result -ne 'Yes') { return }
        }

        $mainForm   = $this

        Show-GitNicProgressDialog -Title "Saving" -Message "SAVING" -DurationMs 3000 -OwnerForm $mainForm.Form -OnComplete {

            Show-GitNicToastDialog -Title "Saved" -Message "SAVE SUCCESSFULL" -OwnerForm $mainForm.Form

            $mainForm.Controller.SaveBranch("Auto save", "save_" + $branch_id + "_");
            $mainForm.reset_buttons()
            $mainForm.UpdateBranches($mainForm.Controller.GetBranches())
            # no "Load Successful" box anymore

        
        }

    }

     [void] UpdateBranches([string[]] $branches) {

        # Reset all buttons to default "Slot - i"
        for ($i = 1; $i -le 20; $i++) {
            if ($this.SlotButtons.ContainsKey($i)) {
                $this.SlotButtons[$i].Text = "Slot - $i"
            }
        }

        # Apply branch names for any save_* branches
        foreach ($branch in $branches) {
            $b = $branch.Trim()
            if ($b.StartsWith("save_")) {
                $branch_data = $b -split "_"
                $button_id   = [int]$branch_data[1]

                if ($this.SlotButtons.ContainsKey($button_id)) {
                    $this.SlotButtons[$button_id].Text = "Save - $button_id - $($branch_data[2])"
                    $this.SlotButtons[$button_id].Refresh()
                }
            }
        }

        $this.Form.Refresh()
    }

   [void] ClickOnButton([object]$button, [int]$button_id){

    # Give previously highlighted button back its original colors
    if ($this.SelectedButton -ne $null) {

        $this.SelectedButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
    }

    $this.SelectedButton = $button

    # Apply a highlight color
    $button.FlatAppearance.BorderColor = [System.Drawing.Color]::White

    $this.CurrentClickedSlot = $button.Text

    if($button.Text -match "Slot - "){

        $this.save_button.FlatAppearance.BorderColor = [System.Drawing.Color]::White
        $this.load_button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
        $this.branch_with_save_clicked = $false

        $this.SlotBigLabel.Text   = $button.Text         # e.g. "Slot - 7"
        $this.SlotSmallLabel.Text = "This slot is available for a save"

        $this.SlotPanel.Visible   = $true
        $this.SavePanel.Visible   = $false
        # $this.DirLabel.Visible    = $false

      }else{

        $this.save_button.FlatAppearance.BorderColor = [System.Drawing.Color]::White
        $this.load_button.FlatAppearance.BorderColor = [System.Drawing.Color]::White
        $this.branch_with_save_clicked      = $true

        # $this.DirLabel.Visible    = $false
        $this.SlotPanel.Visible   = $false
        $this.SavePanel.Visible = $true

        $this.DescTextBox.Enabled = $true
        $this.DescTextBox.Visible = $true
        $this.DescTextBox.BringToFront()
        $this.DescTextBox.Select()
        $this.DescTextBox.SelectionStart = $this.DescTextBox.Text.Length

        $branch_data = $this.CurrentClickedSlot -split " - "
        $this.DescHeaderLabel.Text = "Save " + $branch_data[1]

        $this.DescFooterLabel.Text = $branch_data[2].Substring(0, 2) + " " + $branch_data[2].Substring(2, 3) + " " + $branch_data[2].Substring(5, 2);

        $branch_name = "save_{0}_{1}" -f $branch_data[1], $branch_data[2];

        $desc = $this.Controller.GetBranchDescription($branch_name);

        if ([string]::IsNullOrWhiteSpace($desc)) {
            $this.DescTextBox.Text = "You can add comments here . . ."
            $this.DescTextBox.SelectAll()
        }
        else {
            $this.DescTextBox.Text = $desc
            $this.DescTextBox.Select()
            $this.DescTextBox.SelectionStart = $this.DescTextBox.Text.Length
        }

    }

        $this.button_been_pressed = $true
       
}

    [void] reset_buttons() {
        
        $this.save_button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
        $this.load_button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
        $this.branch_with_save_clicked      = $false
        $this.button_been_pressed           = $false
        $this.CurrentClickedSlot            = $null

        # clear highlight (you already added this)

        if ($this.SelectedButton -ne $null) {

            $this.SelectedButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
        }

        # top panel back to idle state

        $this.SlotPanel.Visible       = $false
        $this.SavePanel.Visible       = $false
        $this.DirLabel.Visible        = $true

        # DirLabel always stays visible (path)

    }

        [void] SaveCurrentDescription() {

        $slot = $this.CurrentClickedSlot

        # No selection → nothing to do
        if (-not $slot) { return }

        # Only handle real save entries like "Save - 8 - 22NOV25"
        if ($slot -notmatch '^Save - ') { return }

        # ---- Get + sanitize text ----
        $text = $this.DescTextBox.Text
        if ($null -eq $text) { $text = "" }
        $text = $text.Trim()

        if ($text -eq "You can add comments here . . .") {
            $text = ""
        }

        if ($text.Length -gt 200) {
            $text = $text.Substring(0, 200)
        }

        $lines = $text -split "(\r\n|\n)"
        if ($lines.Length -gt 5) {
            $text = ($lines[0..4] -join "`n")
        }

        # Apply trimmed text back to the box so UI matches what's saved
        $this.DescTextBox.Text = $text

        # ---- Turn "Save - 8 - 22NOV25" into "save_8_22NOV25" ----
        $branch_data = $slot -split " - "
        if ($branch_data.Length -lt 3) { return }  # safety

        $id   = $branch_data[1]
        $date = $branch_data[2]

        $this.DescHeaderLabel.Text = "Save $id"

        $branch_name = "save_{0}_{1}" -f $id, $date

        try {

            $this.Controller.SetBranchDescription($branch_name, $text)
            # Write-Host $branch_name + "\n" + $text + "\n" + $this.CurrentClickedSlot
        }
        catch {
            # optional logging
        }
    }


    [void] ShowDialog() {
        [void]$this.Form.ShowDialog()
    }

    # ... the rest of your methods (reset_buttons, SetDirectory, UpdateBranches, click_on_branch, etc.) can stay mostly as-is,
    # because they only manipulate properties and strings, not types
}
