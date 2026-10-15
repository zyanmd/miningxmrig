# ⛏️ Monero (XMR) RandomX Smart Mining Suite

<p align="center">
  <img src="https://img.shields.io/badge/Algorithm-RandomX-blue.svg" alt="RandomX">
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6.svg?logo=windows" alt="Windows">
  <img src="https://img.shields.io/badge/CPU-Ryzen%20%2F%20Intel-orange.svg" alt="CPU">
  <img src="https://img.shields.io/badge/Dev%20Fee-0%25%20Wrapper-brightgreen.svg" alt="0% Fee">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT License">
</p>

Suite automasi dan pengatur efisiensi daya cerdas untuk menambang **Monero (XMR)** dengan algoritma **RandomX** pada prosesor multi-core (**AMD Ryzen** & **Intel Core**). 

Dirancang khusus agar komputer/laptop tetap **dingin, baterai aman, game bebas lag**, dan hashrate maksimal secara otomatis.

---

### 💡 Konsep Efisiensi Daya RandomX: "Mengapa Tidak 100% Core?"
Pada algoritma RandomX, 1 thread penambang membutuhkan **2 MB L3 Cache**.
$$\text{Thread Maksimal Efektif} = \frac{\text{Kapasitas L3 Cache (MB)}}{2\text{ MB}}$$

> *Contoh:* Prosesor dengan 16 MB L3 Cache hanya membutuhkan maksimal $16 \div 2 = 8$ thread. Memaksa lebih banyak thread tidak akan menaikkan hashrate, melainkan hanya membuang watt listrik dan membuat CPU panas (akibat *cache bottleneck*). Script ini otomatis mendeteksi dan menghitung alokasi optimal untuk CPU apa pun!

---

### 🛡️ Jaminan 100% Transparan & Anti-DevFee Scam

Banyak script mining di internet (YouTube/Telegram/forum) diam-diam **merugikan pengguna** dengan menyisipkan wallet si pembuat, mengarahkan koneksi ke server proxy perantara yang memotong hashrate 5%-20%, atau menyembunyikan malware.

**Script ini dibuat 100% aman, bersih, dan murni untuk keuntunganmu:**
- **0% Potongan untuk Pembuat Script (Zero Script Fee):** 100% hasil penambangan langsung masuk ke dompetmu.
- **Koneksi Langsung Tanpa Proxy Perantara:** Komputer kamu terhubung langsung ke pool resmi (`pool.supportxmr.com` / `moneroocean.stream`).
- **Parameter Proteksi Terkunci:** 
  - `--donate-level=1` : Level donasi minimum resmi developer XMRig (1 menit per 100 menit).
  - `--donate-over-proxy=0` : Menolak pemotongan donasi oleh proxy luar.
- **Alamat Dompet Murni:** Miner hanya menerima wallet dari `config.json` milikmu.
- **Open Source (Plaintext):** Semua file script berbentuk teks biasa (`.ps1`, `.bat`, `.json`) yang bebas diaudit baris per baris. Binary `xmrig.exe` diunduh langsung dari rilis resmi [GitHub XMRig](https://github.com/xmrig/xmrig/releases).

---

### 📖 Panduan Penggunaan (Langkah demi Langkah)

#### 1. Clone / Unduh Repository
```bash
git clone https://github.com/zyanmd/miningxmrig.git
cd miningxmrig
```
*(Atau unduh file ZIP dari GitHub lalu ekstrak ke folder komputer kamu).*

#### 2. Masukkan Alamat Wallet Kamu
Buka file `config.json` menggunakan text editor (Notepad / VS Code), lalu ganti nilai `"wallet"` dengan alamat dompet Monero milikmu:
```json
"wallet": "48edfHu7V9Z84YzzMa6fUueHA6CF6XyK7...",
"worker_name": "Worker1"
```

#### 3. Unduh Binary XMRig Resmi (1-Klik)
Klik ganda file **`download_xmrig.bat`**. Script akan otomatis mengunduh binary resmi XMRig Windows terbaru dari GitHub.  
*(Jika kamu melewati langkah ini, script launcher utama juga akan otomatis mengunduhnya).*

#### 4. Aktifkan Huge Pages Windows (Sangat Disarankan)
Klik kanan file **`enable_huge_pages.bat`** $\rightarrow$ pilih **Run as administrator**, lalu **restart komputer kamu**.
> [!TIP]
> Mengaktifkan Huge Pages (*Lock Pages in Memory*) memberikan peningkatan hashrate **+20% s/d 30% secara gratis** tanpa menaikkan watt listrik!

#### 5. Mulai Menambang
Klik kanan file **`start_mining.bat`** $\rightarrow$ pilih **Run as administrator**.  
*(Akses admin diperlukan agar optimasi MSR Mod pada AMD Ryzen atau Intel Core dapat berjalan otomatis).*

#### 6. Pantau Statistik & Hasil Tambang
Buka website pool yang kamu gunakan (misal: [supportxmr.com](https://supportxmr.com/)), masukkan alamat wallet XMR kamu di kolom pencarian dashboard pool untuk memantau hashrate dan saldo secara transparan.

---

### ✨ Fitur-Fitur Pintar Otomasi

| Fitur | Deskripsi |
| :--- | :--- |
| **🔋 Battery Guard** | Otomatis **PAUSE** saat charger laptop dicabut (pakai baterai) agar baterai tidak rusak/cepat habis, dan otomatis **RESUME** saat dicolok kembali. |
| **💤 Smart Idle Mode** | Otomatis berjalan hemat (2 thread) saat kamu aktif menggunakan PC, dan otomatis gaspol ke kecepatan penuh saat ditinggal pergi (Idle > 3 menit). |
| **🎮 Game Blocker** | Otomatis menutup/pause miner jika game (*CS2, Valorant, Dota 2, GTA V, Genshin Impact, dll*) dibuka agar performa game 100% lancar tanpa drop FPS. |
| **🔄 Multi-Pool Failover** | Otomatis beralih ke pool cadangan (*MoneroOcean*) jika pool utama mengalami gangguan koneksi. |
| **⏰ Scheduler** | Opsi untuk membatasi jam aktif menambang (misal hanya aktif pukul 22:00 - 06:00 pagi saat tidur). |

---

### 📁 Struktur File

```
miningxmrig/
├── config.json            # Pusat pengaturan (wallet, pool, batasan thread, daftar game)
├── start_mining.bat       # Launcher 1-klik (Jalankan via Run as Administrator)
├── start_mining.ps1       # Mesin supervisor pintar yang memantau sistem tiap 5 detik
├── enable_huge_pages.bat  # Tool aktivasi Huge Pages Windows (+30% Hashrate)
├── download_xmrig.bat     # Pengunduh resmi XMRig dari GitHub
├── download_xmrig.ps1     # Script download & extract otomatis
└── README.md              # Dokumentasi lengkap
```

---

### ⚙️ Konfigurasi `config.json`

```json
{
  "pool": "pool.supportxmr.com:3333",
  "backup_pool": "gulf.moneroocean.stream:10128",
  "wallet": "YOUR_MONERO_WALLET_ADDRESS",
  "worker_name": "Worker1",

  "performance": {
    "auto_detect_threads": true,
    "max_threads": 8,
    "user_active_threads": 2,
    "priority": 1
  },

  "battery_guard": {
    "enabled": true,
    "pause_on_battery": true
  },

  "smart_idle_mode": {
    "enabled": true,
    "idle_threshold_seconds": 180,
    "action_when_active": "throttle"
  },

  "game_detection": {
    "enabled": true,
    "process_names": [
      "cs2", "valorant", "dota2", "gta5", "GenshinImpact", "FortniteClient-Win64-Shipping", "r5apex"
    ]
  },

  "schedule": {
    "enabled": false,
    "start_time": "22:00",
    "stop_time": "06:00"
  },

  "auto_restart": true
}
```
