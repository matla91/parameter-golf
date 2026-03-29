param(
    [Parameter(Mandatory=$true)]
    [string]$Name
)

$Date = Get-Date -Format "yyyy-MM-dd"
$Dst = "snapshots/${Date}_$Name.py"

Copy-Item train_gpt_dev.py $Dst
Write-Host "Snapshot created: $Dst"
