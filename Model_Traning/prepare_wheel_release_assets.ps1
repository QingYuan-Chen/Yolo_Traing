param(
    [string]$OutputDir = "$env:USERPROFILE\Desktop\yolo-wheel-release-assets",
    [int64]$PartSizeBytes = 1900MB
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WheelDir = Join-Path $ScriptDir "wheels"
$TorchWheel = Join-Path $WheelDir "torch-2.8.0+cu128-cp312-cp312-win_amd64.whl"
$NonTorchZip = Join-Path $OutputDir "wheels-non-torch.zip"

if (-not (Test-Path -LiteralPath $WheelDir)) {
    throw "Wheel directory not found: $WheelDir"
}

if (-not (Test-Path -LiteralPath $TorchWheel)) {
    throw "Torch wheel not found: $TorchWheel"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
Remove-Item -LiteralPath $NonTorchZip -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath (Join-Path $OutputDir "torch-2.8.0+cu128-cp312-cp312-win_amd64.whl.part*") -Force -ErrorAction SilentlyContinue

$NonTorchWheels = Get-ChildItem -LiteralPath $WheelDir -File -Filter "*.whl" |
    Where-Object { $_.Name -ne "torch-2.8.0+cu128-cp312-cp312-win_amd64.whl" }

Compress-Archive -LiteralPath $NonTorchWheels.FullName -DestinationPath $NonTorchZip -CompressionLevel Optimal

$buffer = New-Object byte[] (8MB)
$inputStream = [System.IO.File]::OpenRead($TorchWheel)
try {
    $partIndex = 1
    while ($inputStream.Position -lt $inputStream.Length) {
        $partPath = Join-Path $OutputDir ("torch-2.8.0+cu128-cp312-cp312-win_amd64.whl.part{0:D2}" -f $partIndex)
        $outputStream = [System.IO.File]::Create($partPath)
        try {
            $written = 0L
            while ($written -lt $PartSizeBytes -and $inputStream.Position -lt $inputStream.Length) {
                $remaining = [Math]::Min($buffer.Length, $PartSizeBytes - $written)
                $read = $inputStream.Read($buffer, 0, [int]$remaining)
                if ($read -le 0) {
                    break
                }
                $outputStream.Write($buffer, 0, $read)
                $written += $read
            }
        }
        finally {
            $outputStream.Dispose()
        }
        $partIndex++
    }
}
finally {
    $inputStream.Dispose()
}

Get-ChildItem -LiteralPath $OutputDir -File | Sort-Object Name |
    Select-Object Name,@{Name="MB";Expression={[Math]::Round($_.Length / 1MB, 2)}},@{Name="SHA256";Expression={(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}} |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Upload these files to a GitHub Release named/tagged wheels-cu128."
Write-Host "OutputDir: $OutputDir"
