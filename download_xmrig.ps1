[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$targetDir = $PSScriptRoot
$destExe = Join-Path $targetDir "xmrig.exe"

if (Test-Path $destExe) {
    Write-Host "[OK] xmrig.exe sudah ada di folder ini." -ForegroundColor Green
    Exit
}

Write-Host ">>> Mengambil informasi rilis XMRig terbaru dari GitHub..." -ForegroundColor Cyan

try {
    $apiUrl = "https://api.github.com/repos/xmrig/xmrig/releases/latest"
    $release = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
    
    # Cari file zip Windows 64-bit (contoh: xmrig-x.x.x-windows-x64.zip)
    $asset = $release.assets | Where-Object { $_.name -like "*-windows-x64.zip" } | Select-Object -First 1
    if (-not $asset) {
        $asset = $release.assets | Where-Object { $_.name -like "*windows*x64*.zip" } | Select-Object -First 1
    }
    if (-not $asset) {
        $asset = $release.assets | Where-Object { $_.name -like "*win64.zip" } | Select-Object -First 1
    }

    if (-not $asset) {
        throw "Tidak dapat menemukan file rilis zip Windows di GitHub."
    }

    $downloadUrl = $asset.browser_download_url
    $tempZip = Join-Path $targetDir "xmrig_temp.zip"

    Write-Host ">>> Mengunduh: $($asset.name)..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing

    Write-Host ">>> Mengekstrak file..." -ForegroundColor Cyan
    $tempExtract = Join-Path $targetDir "temp_extract"
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

    # Pindahkan xmrig.exe dan file pendukung ke folder utama
    $foundExe = Get-ChildItem -Path $tempExtract -Recurse -Filter "xmrig.exe" | Select-Object -First 1
    if ($foundExe) {
        $foundDir = $foundExe.DirectoryName
        Get-ChildItem -Path $foundDir | ForEach-Object {
            $destPath = Join-Path $targetDir $_.Name
            if ((-not (Test-Path $destPath)) -or ($_.Name -like "xmrig*")) {
                Copy-Item -Path $_.FullName -Destination $destPath -Force
            }
        }
        Write-Host "[OK] XMRig berhasil diunduh dan dipasang!" -ForegroundColor Green
    } else {
        throw "Gagal menemukan xmrig.exe di dalam arsip zip."
    }

    # Bersihkan file sementara
    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue

} catch {
    Write-Host "[-] Gagal mengunduh otomatis: $_" -ForegroundColor Red
    Write-Host "    Silakan unduh manual dari: https://github.com/xmrig/xmrig/releases" -ForegroundColor Yellow
}
