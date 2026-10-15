@echo off
title Windows Huge Pages Optimizer
cd /d "%~dp0"

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ========================================================
    echo  [!] PERINGATAN: Hak Administrator Diperlukan!
    echo      Silakan KLIK KANAN file ini lalu pilih:
    echo      'Run as administrator' (Jalankan sebagai administrator)
    echo ========================================================
    pause
    exit /b 1
)

echo >>> Mengonfigurasi hak akses 'Lock Pages in Memory' untuk Huge Pages...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name; " ^
  "$secFile = [System.IO.Path]::GetTempFileName(); " ^
  "secedit /export /cfg $secFile | Out-Null; " ^
  "$content = Get-Content $secFile; " ^
  "if ($content -match 'SeLockMemoryPrivilege\s*=') { $newContent = $content -replace '(SeLockMemoryPrivilege\s*=.*)', ('$1,' + $user) } else { $newContent = $content -replace '(\[Privilege Rights\])', ('$1`r`nSeLockMemoryPrivilege = ' + $user) }; " ^
  "Set-Content -Path $secFile -Value $newContent; " ^
  "$dbFile = [System.IO.Path]::GetTempFileName(); " ^
  "secedit /configure /db $dbFile /cfg $secFile /areas USER_RIGHTS | Out-Null; " ^
  "Remove-Item $secFile, $dbFile -Force -ErrorAction SilentlyContinue; " ^
  "Write-Host '[OK] Sukses! Lock Pages in Memory telah diberikan untuk:' $user -ForegroundColor Green; " ^
  "Write-Host '--------------------------------------------------------' -ForegroundColor Cyan; " ^
  "Write-Host '[!] PENTING: Silakan RESTART / REBOOT laptop/PC kamu sekarang' -ForegroundColor Yellow; " ^
  "Write-Host '    agar Windows memuat hak akses memori Huge Pages ini.' -ForegroundColor Yellow;"

pause
