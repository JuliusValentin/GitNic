Class NoRepo_Frame{

    [Controller]     $Controller

        NoRepo_Frame([Controller]$controller, [string]$directory){
        $this.Controller = $controller
        $noRepoForm = New-Object System.Windows.Forms.Form
        $noRepoForm.Size = [System.Drawing.Size]::new(400, 250)
        $noRepoForm.Text = "GitGui"
        $noRepoForm.StartPosition = "CenterScreen"
        $noRepoForm.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
        $noRepoForm.ForeColor = [System.Drawing.Color]::White

        $noRepoForm.FormBorderStyle = 'FixedDialog'
        $noRepoForm.MaximizeBox     = $false
        $noRepoForm.MinimizeBox     = $true 
        $noRepoForm.Add_Shown({
            param($sender, $eventArgs)
            $sender.TopMost = $true
            $sender.Activate()
            $sender.TopMost = $false
        })

        $lbl_message1 = New-Object System.Windows.Forms.Label
        $lbl_message1.Text = "No git repository detected in the current directory:"
        $lbl_message1.AutoSize = $false
        $lbl_message1.Height = 40
        $lbl_message1.Width = 350
        $lbl_message1.Font = "Arial, 12pt, style=Bold"
        $lbl_message1.Location = New-Object System.Drawing.Point(20, 20)
        $noRepoForm.Controls.Add($lbl_message1)

        $lbl_message2 = New-Object System.Windows.Forms.Label
        $lbl_message2.Text = "$directory"
        $lbl_message2.AutoSize = $false
        $lbl_message2.Width = 350
        $lbl_message2.Height = 40
        $lbl_message2.Font = "Arial, 12pt, style=Bold"
        $lbl_message2.Location = New-Object System.Drawing.Point(20, 70)
        $noRepoForm.Controls.Add($lbl_message2)

        $button_ok = New-Object System.Windows.Forms.Button
        $button_ok.Text = "Initialize Git Repository"
        $button_ok.Location = New-Object System.Drawing.Point(20, 150)
        $button_ok.AutoSize = $true

        $button_cancel = New-Object System.Windows.Forms.Button
        $button_cancel.Text = "Cancel"
        $button_cancel.Location = New-Object System.Drawing.Point(250, 150)
        $button_cancel.AutoSize = $true

        $controller_ref = $controller

        $button_cancel.Add_Click({
            $Controller_ref.SetNoRepoFormResult("Cancel");
            $noRepoForm.Close()
        })

        $button_ok.Add_Click({
            $Controller_ref.InitializeGit();
            $noRepoForm.Close()
        })

        $noRepoForm.Controls.Add($button_ok)
        $noRepoForm.Controls.Add($button_cancel)

        $noRepoForm.showDialog()
        $noRepoForm.Dispose()
    }
}
