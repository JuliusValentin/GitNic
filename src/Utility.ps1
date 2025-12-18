Class Utility{

    static [string] CheckFolderSize([string]$Path, [long]$MaxSize = [long]100MB) {
        [long]$total = 0

        foreach ($file in Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue) {
            $total += $file.Length
            if ($total -gt $MaxSize) {
                return "Directory exceeds $([Utility]::FormatBytes($MaxSize)) (currently ~ $([Utility]::FormatBytes($total)))."
            }
        }

        return "Directory is not bigger than $([Utility]::FormatBytes($MaxSize)). (currently ~ $([Utility]::FormatBytes($total)))"
    }

    static [string] FormatBytes([long]$bytes){

        if ($bytes -ge 1TB) {
            return "{0:N2} TB" -f ($bytes / 1TB)
        } elseif ($bytes -ge 1GB) {
            return "{0:N2} GB" -f ($bytes / 1GB)
        } elseif ($bytes -ge 1MB) {
            return "{0:N2} MB" -f ($bytes / 1MB)
        } elseif ($bytes -ge 1KB) {
            return "{0:N2} KB" -f ($bytes / 1KB)
        } else {
            return "$bytes Bytes"
        }
    }

}
