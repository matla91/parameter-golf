param(
    [Parameter(Mandatory=$true)]
    [string]$Source
)

Copy-Item $Source train_gpt.py -Force
Write-Host "Promoted $Source -> train_gpt.py"
