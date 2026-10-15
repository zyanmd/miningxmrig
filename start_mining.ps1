# ==============================================================================
# SMART XMRIG LAUNCHER & POWER EFFICIENCY CONTROLLER (ADVANCED EDITION)
# Features: Battery Guard | Smart Idle Detection | Game Blocker | Scheduler | Failover
# ==============================================================================

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$configFile = Join-Path $PSScriptRoot "config.json"
$xmrigExe   = Join-Path $PSScriptRoot "xmrig.exe"

# 1. Pastikan config.json ada
if (-not (Test-Path $configFile)) {
    Write-Host "[-] config.json tidak ditemukan!" -ForegroundColor Red
    Pause
    Exit
}

$cfg = Get-Content $configFile -Raw | ConvertFrom-Json

# 2. Cek apakah Wallet masih default
if ($cfg.wallet -like "*YOUR_MONERO_WALLET_ADDRESS*") {
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host "[!] PERINGATAN: Alamat Wallet Monero belum diganti!" -ForegroundColor Yellow
    Write-Host "    Silakan buka file 'config.json' dan masukkan alamat wallet XMR kamu." -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Yellow
    Write-Host ""
}

# 3. Cek keberadaan xmrig.exe
if (-not (Test-Path $xmrigExe)) {
    Write-Host "[!] xmrig.exe belum ada. Mengunduh rilis resmi..." -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot "download_xmrig.ps1")
    if (-not (Test-Path $xmrigExe)) {
        Write-Host "[-] xmrig.exe tidak ditemukan." -ForegroundColor Red
        Pause
        Exit
    }
}

# 4. Deteksi Hardware & Hitung Alokasi Thread Ideal
Write-Host ">>> Memeriksa Hardware & L3 Cache..." -ForegroundColor Cyan
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$logicalCores = $cpu.NumberOfLogicalProcessors
$l3CacheKB    = $cpu.L3CacheSize

if ($l3CacheKB -gt 0) {
    # RandomX butuh 2048 KB (2MB) L3 cache per thread
    $cacheMaxThreads = [math]::Floor($l3CacheKB / 2048)
} else {
    $cacheMaxThreads = $logicalCores
}

if ($cfg.performance.auto_detect_threads) {
    $optimalFullThreads = [math]::Min($cacheMaxThreads, $cfg.performance.max_threads)
} else {
    $optimalFullThreads = $cfg.performance.max_threads
}
if ($optimalFullThreads -lt 1) { $optimalFullThreads = 1 }

$throttleThreads = [math]::Min($cfg.performance.user_active_threads, $optimalFullThreads)
if ($throttleThreads -lt 1) { $throttleThreads = 1 }

Write-Host "    CPU Model       : $($cpu.Name.Trim())" -ForegroundColor White
Write-Host "    L3 Cache        : $([math]::Round($l3CacheKB / 1024, 1)) MB (Maks ideal cache: $cacheMaxThreads threads)" -ForegroundColor White
Write-Host "    Full Threads    : $optimalFullThreads thread (Saat Idle / Malam)" -ForegroundColor Green
Write-Host "    Pool Utama      : $($cfg.pool)" -ForegroundColor Gray
Write-Host "    Backup Pool     : $($cfg.backup_pool)" -ForegroundColor Gray
Write-Host "    Wallet Tujuan   : $($cfg.wallet)" -ForegroundColor Green
Write-Host "    Anti-Scam/DevFee: 0% FEE SCRIPT (100% Hasil masuk ke dompet kamu)" -ForegroundColor Green
Write-Host "    XMRig Base Fee  : 1% (Standar minimum resmi developer XMRig)" -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Cyan

# 5. Native Windows API untuk Deteksi Idle Waktu (Keyboard & Mouse)
$idleTypeDef = @'
using System;
using System.Runtime.InteropServices;
public class UserActivityChecker {
    [DllImport("user32.dll")]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);
    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public uint dwTime;
    }
    public static uint GetIdleSeconds() {
        LASTINPUTINFO lii = new LASTINPUTINFO();
        lii.cbSize = (uint)Marshal.SizeOf(lii);
        if (GetLastInputInfo(ref lii)) {
            return ((uint)Environment.TickCount - lii.dwTime) / 1000;
        }
        return 0;
    }
}
'@
try {
    Add-Type -TypeDefinition $idleTypeDef -ErrorAction SilentlyContinue
} catch {}

# Helper: Cek apakah laptop dicolok AC Power
function Test-IsOnACPower {
    try {
        $status = (Get-CimInstance -ClassName BatteryStatus -Namespace root\wmi -ErrorAction Stop).PowerOnline
        return $status
    } catch {
        # Jika bukan laptop / WMI BatteryStatus tidak ada, anggap selalu AC Power
        return $true
    }
}

# Helper: Cek apakah ada game/aplikasi berat yang sedang berjalan
function Get-RunningBlockedGame {
    param([string[]]$processNames)
    if (-not $processNames -or $processNames.Count -eq 0) { return $null }
    
    $runningProcesses = Get-Process -ErrorAction SilentlyContinue
    foreach ($proc in $runningProcesses) {
        foreach ($name in $processNames) {
            if ($proc.ProcessName -ieq $name -or $proc.ProcessName -ilike "*$name*") {
                return $proc.ProcessName
            }
        }
    }
    return $null
}

# Helper: Cek apakah waktu saat ini masuk jadwal
function Test-IsWithinSchedule {
    param([string]$start, [string]$stop)
    $now = Get-Date
    $startTime = [DateTime]::ParseExact($start, "HH:mm", $null)
    $stopTime  = [DateTime]::ParseExact($stop, "HH:mm", $null)

    if ($startTime -le $stopTime) {
        return ($now.TimeOfDay -ge $startTime.TimeOfDay -and $now.TimeOfDay -le $stopTime.TimeOfDay)
    } else {
        # Melewati tengah malam (misal 22:00 s/d 06:00)
        return ($now.TimeOfDay -ge $startTime.TimeOfDay -or $now.TimeOfDay -le $stopTime.TimeOfDay)
    }
}

# 6. Variabel State Controller
$activePool       = $cfg.pool
$consecutiveFails = 0
$minerProc        = $null
$currentThreads   = 0
$lastStatusText   = ""

function Stop-MinerProcess {
    param([string]$reason)
    if ($script:minerProc -and (-not $script:minerProc.HasExited)) {
        Write-Host "[-] Berhenti ($reason)..." -ForegroundColor Yellow
        try {
            $script:minerProc.Kill()
            $script:minerProc.WaitForExit(3000)
        } catch {}
    }
    $script:minerProc = $null
    $script:currentThreads = 0
}

function Start-MinerProcess {
    param([int]$threads, [string]$poolToUse)
    Stop-MinerProcess -reason "Penyesuaian mode/thread"

    Write-Host "[+] Menjalankan Miner ($threads Threads) di $poolToUse..." -ForegroundColor Green
    $argsList = @(
        "-o", $poolToUse,
        "-u", "$($cfg.wallet).$($cfg.worker_name)",
        "-k",
        "--donate-level=1",
        "--donate-over-proxy=0",
        "--threads=$threads",
        "--cpu-priority=$($cfg.performance.priority)",
        "--randomx-1gb-pages"
    )

    $script:minerProc = Start-Process -FilePath $xmrigExe -ArgumentList $argsList -NoNewWindow -PassThru
    $script:currentThreads = $threads
}

# Handler saat user menekan Ctrl+C
[Console]::TreatControlCAsInput = $false

Write-Host ">>> Controller aktif. Memantau sistem secara berkala (Cek tiap 5s)..." -ForegroundColor Cyan
Write-Host "    Tekan Ctrl+C di terminal ini untuk berhenti total." -ForegroundColor Gray
Write-Host ""

# ==============================================================================
# MAIN SUPERVISOR LOOP
# ==============================================================================
try {
    while ($true) {
        # Muat ulang config secara dinamis jika file diubah
        try {
            $cfg = Get-Content $configFile -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        } catch {}

        $shouldMine    = $true
        $targetThreads = $optimalFullThreads
        $statusReason  = ""

        # A. Cek Battery Guard
        if ($cfg.battery_guard.enabled -and $cfg.battery_guard.pause_on_battery) {
            $onAC = Test-IsOnACPower
            if (-not $onAC) {
                $shouldMine   = $false
                $statusReason = "Laptop memakai Baterai (Charger dicabut - Auto-Pause)"
            }
        }

        # B. Cek Game / Heavy App Blocker
        if ($shouldMine -and $cfg.game_detection.enabled) {
            $foundGame = Get-RunningBlockedGame -processNames $cfg.game_detection.process_names
            if ($foundGame) {
                $shouldMine   = $false
                $statusReason = "Game/Aplikasi terdeteksi berjalan: $foundGame (Auto-Pause)"
            }
        }

        # C. Cek Schedule (Jam Tertentu)
        if ($shouldMine -and $cfg.schedule.enabled) {
            $inSchedule = Test-IsWithinSchedule -start $cfg.schedule.start_time -stop $cfg.schedule.stop_time
            if (-not $inSchedule) {
                $shouldMine   = $false
                $statusReason = "Di luar jadwal mining ($($cfg.schedule.start_time) - $($cfg.schedule.stop_time))"
            }
        }

        # D. Cek Smart Idle Mode (Stealth / Dynamic Throttling)
        if ($shouldMine -and $cfg.smart_idle_mode.enabled) {
            $idleSec = [UserActivityChecker]::GetIdleSeconds()
            $threshold = $cfg.smart_idle_mode.idle_threshold_seconds

            if ($idleSec -lt $threshold) {
                # Pengguna sedang aktif menggunakan PC
                if ($cfg.smart_idle_mode.action_when_active -eq "pause") {
                    $shouldMine   = $false
                    $statusReason = "Pengguna sedang aktif (Idle: ${idleSec}s / Butuh: ${threshold}s - Auto-Pause)"
                } else {
                    # Mode throttle (low power)
                    $targetThreads = $throttleThreads
                    $statusReason  = "Pengguna Aktif -> Mode Throttle (${targetThreads} Threads)"
                }
            } else {
                # Pengguna sedang idle / meninggalkan PC
                $targetThreads = $optimalFullThreads
                $statusReason  = "Pengguna Idle (${idleSec}s) -> Mode Maksimal Optimal (${targetThreads} Threads)"
            }
        } elseif ($shouldMine) {
            $statusReason = "Mode Normal (${targetThreads} Threads)"
        }

        # E. Eksekusi Status & Sinkronisasi Proses Miner
        if (-not $shouldMine) {
            if ($minerProc -and (-not $minerProc.HasExited)) {
                Stop-MinerProcess -reason $statusReason
            }
            if ($lastStatusText -ne $statusReason) {
                Write-Host "[STATUS] $statusReason" -ForegroundColor DarkYellow
                $lastStatusText = $statusReason
            }
        } else {
            # Cek apakah proses mati mendadak (Crash / Pool Error)
            if ($minerProc -and $minerProc.HasExited) {
                $exitCode = $minerProc.ExitCode
                Write-Host "[!] XMRig terhenti mendadak (Exit Code: $exitCode)." -ForegroundColor Yellow
                $consecutiveFails++
                
                # Failover Pool jika gagal berturut-turut
                if ($consecutiveFails -ge 3 -and $cfg.backup_pool) {
                    if ($activePool -eq $cfg.pool) {
                        $activePool = $cfg.backup_pool
                        Write-Host "[!] Pool utama gagal 3x. Beralih ke Backup Pool: $activePool" -ForegroundColor Magenta
                    } else {
                        $activePool = $cfg.pool
                        Write-Host "[!] Beralih kembali ke Pool Utama: $activePool" -ForegroundColor Magenta
                    }
                    $consecutiveFails = 0
                }
                $minerProc = $null
                $currentThreads = 0
            }

            # Jalankan miner jika belum running atau jumlah thread perlu disesuaikan
            if (-not $minerProc -or $currentThreads -ne $targetThreads) {
                Start-MinerProcess -threads $targetThreads -poolToUse $activePool
                $lastStatusText = $statusReason
                Write-Host "[STATUS] $statusReason" -ForegroundColor Cyan
            }
        }

        # Tunggu 5 detik sebelum evaluasi status berikutnya
        Start-Sleep -Seconds 5
    }
} finally {
    # Pastikan miner ikut tertutup jika script utama dihentikan
    Stop-MinerProcess -reason "Script ditutup oleh pengguna"
}
