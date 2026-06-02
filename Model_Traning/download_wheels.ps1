param(
    [string]$ReleaseTag = "wheels-cu128",
    [string]$Repo = "QingYuan-Chen/Yolo_Traing"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WheelDir = Join-Path $ScriptDir "wheels"
$TempDir = Join-Path $env:TEMP "yolo-wheel-download"
$BaseUrl = "https://github.com/$Repo/releases/download/$ReleaseTag"

New-Item -ItemType Directory -Force -Path $WheelDir | Out-Null
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

function Download-Asset {
    param(
        [string]$Name
    )

    $target = Join-Path $TempDir $Name
    $url = "$BaseUrl/$Name"

    Write-Host "Downloading $Name"
    Invoke-WebRequest -Uri $url -OutFile $target
    return $target
}

$nonTorchZip = Download-Asset "wheels-non-torch.zip"
Expand-Archive -LiteralPath $nonTorchZip -DestinationPath $WheelDir -Force

$torchName = "torch-2.8.0+cu128-cp312-cp312-win_amd64.whl"
$torchPath = Join-Path $WheelDir $torchName
Remove-Item -LiteralPath $torchPath -Force -ErrorAction SilentlyContinue

$partNames = @(
    "$torchName.part01",
    "$torchName.part02"
)

$outputStream = [System.IO.File]::Create($torchPath)
try {
    foreach ($partName in $partNames) {
        $partPath = Download-Asset $partName
        $inputStream = [System.IO.File]::OpenRead($partPath)
        try {
            $inputStream.CopyTo($outputStream)
        }
        finally {
            $inputStream.Dispose()
        }
    }
}
finally {
    $outputStream.Dispose()
}

Write-Host ""
Write-Host "Wheels downloaded to: $WheelDir"
Write-Host "Offline install example:"
Write-Host "pip install --no-index --find-links `"$WheelDir`" -r `"$ScriptDir\requirements.txt`""
