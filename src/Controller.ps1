Class Controller {

    [GitShell] $GitShell
    [string] $Directory
    [string[]] $Months = @("jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec")
    [string] $NoRepo_Form_Result

    Controller([string]$directory, [GitShell]$gitShell) {

        $this.Directory = $directory
        $this.GitShell = $gitShell
    }

    [void] SetNoRepoFormResult([string]$result){
        $this.NoRepo_Form_Result = $result
    }

    [void] InitializeGit(){

        $this.GitShell.ExecuteGitCommand("init");
    }

    [string[]] GetBranches(){

        return $this.GitShell.GetGitBranches();
    }

    [bool] IsThereSomethingToCommit(){

        $git_status_return = $this.GitShell.ExecuteGitCommand("status");

        return -not $git_status_return.Contains("nothing to commit");
    }

    [void] LoadBranch([string]$branch_name){

        $this.GitShell.ExecuteGitCommand("reset --hard HEAD");
        $this.GitShell.ExecuteGitCommand("clean -fd");
        $this.GitShell.ExecuteGitCommand("switch $branch_name");
        $this.GitShell.ExecuteGitCommand("branch -D current_save");
        $this.GitShell.ExecuteGitCommand("switch -c current_save");
    }

    [void] SaveBranch([string]$message, [string]$save_name){

        $save_name = $save_name + $this.get_date_formatted();
        $this.GitShell.ExecuteGitCommand("add .");
        $this.GitShell.ExecuteGitCommand("commit -m `"$message`"");
        $this.GitShell.ExecuteGitCommand("branch -m $save_name");
        $this.GitShell.ExecuteGitCommand("switch -c current_save");
    }

    [string] GetBranchDescription([string]$branchName) {
        # Temporary implementation – just delegate to GitShell or return empty
        if (-not $this.GitShell) { return "" }
        return $this.GitShell.GetBranchDescription($branchName)
    }

    [void] SetBranchDescription([string]$branchName, [string]$description) {
        if (-not $this.GitShell) { return }
        $this.GitShell.SetBranchDescription($branchName, $description)
    }

    [string] get_date_formatted(){

        $YYMMDD = (Get-Date -Format "yyyy-MM-dd").Split("-");

        $year =  $YYMMDD[0].Substring(2,2);

        $index_of_month = [int]$YYMMDD[1];

        return $YYMMDD[2] + $this.Months[$index_of_month - 1] + $year;
    }

}
