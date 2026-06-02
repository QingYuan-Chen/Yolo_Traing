param(
    [string]$OutputDir = "$env:USERPROFILE\Desktop\yolo-weight-release-assets"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WeightDir = Join-Path $ScriptDir "weights"
$WeightsZip = Join-Path $OutputDir "weights.zip"

if (-not (Test-Path -LiteralPath $WeightDir)) {
    throw "Weight directory not found: $WeightDir"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
Remove-Item -LiteralPath $WeightsZip -Force -ErrorAction SilentlyContinue

$TempRoot = Join-Path $env:TEMP ("yolo-weight-assets-" + [guid]::NewGuid().ToString("N"))
$TempWeights = Join-Path $TempRoot "weights"

try {
    New-Item -ItemType Directory -Force -Path $TempWeights | Out-Null
    Copy-Item -LiteralPath (Join-Path $WeightDir "*") -Destination $TempWeights -Recurse -Force
    Compress-Archive -LiteralPath $TempWeights -DestinationPath $WeightsZip -CompressionLevel Optimal
}
finally {
    Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Get-ChildItem -LiteralPath $OutputDir -File | Sort-Object Name |
    Select-Object Name,@{Name="MB";Expression={[Math]::Round($_.Length / 1MB, 2)}},@{Name="SHA256";Expression={(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}} |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Upload weights.zip to a GitHub Release named/tagged weights-pretrained."
Write-Host "OutputDir: $OutputDir"
