param(
    [string]$ReleaseTag = "weights-pretrained",
    [string]$Repo = "QingYuan-Chen/Yolo_Traing"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TempDir = Join-Path $env:TEMP "yolo-weight-download"
$ZipPath = Join-Path $TempDir "weights.zip"
$BaseUrl = "https://github.com/$Repo/releases/download/$ReleaseTag"
$Url = "$BaseUrl/weights.zip"

New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

Write-Host "Downloading weights.zip"
Invoke-WebRequest -Uri $Url -OutFile $ZipPath

Expand-Archive -LiteralPath $ZipPath -DestinationPath $ScriptDir -Force

Write-Host ""
Write-Host "Weights downloaded to: $(Join-Path $ScriptDir "weights")"
