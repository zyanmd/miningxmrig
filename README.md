# ⛏️ Monero (XMR) RandomX Smart Mining Suite

Suite automasi dan pengatur efisiensi daya lengkap untuk menambang Monero (XMR) dengan algoritma RandomX pada prosesor multi-core (dioptimasi khusus untuk **AMD Ryzen 7 7435HS**).

---

### 💻 Spesifikasi & Kalkulasi Hardware Kamu
- **Processor:** AMD Ryzen 7 7435HS (8 Cores, 16 Logical Processors)
- **L3 Cache:** 16 MB
- **Alokasi RandomX:** **8 Thread Maksimal** (1 Thread butuh 2 MB L3 Cache).

---

### 🛡️ Jaminan 100% Transparan & Anti-DevFee Scam (Hanya Menguntungkan Kamu)

Banyak script mining di internet (YouTube/Telegram/forum) diam-diam **merugikan pengguna** dengan menyisipkan wallet si pembuat, mengarahkan koneksi ke server proxy perantara yang memotong hashrate 5%-20%, atau menyembunyikan malware.

**Script ini dibuat 100% aman, bersih, dan murni untuk keuntunganmu:**
1. **0% Potongan untuk Pembuat Script (Zero Script Fee):**  
   Script wrapper ini tidak memotong sepeser pun. 100% hasil penambangan langsung masuk ke dompetmu.
2. **Koneksi Langsung Tanpa Proxy Perantara:**  
   Laptop kamu terhubung langsung ke pool resmi (`pool.supportxmr.com:3333` / `moneroocean.stream`). Tidak ada server penengah yang memotong shares.
3. **Parameter Proteksi Terkunci:**  
   Di [`start_mining.ps1`](file:///c:/Users/Raihan/Downloads/farming/start_mining.ps1) telah dikunci:
   - `--donate-level=1` : Level donasi terendah yang diwajibkan oleh developer inti resmi XMRig (1 menit per 100 menit).
   - `--donate-over-proxy=0` : Menolak pemotongan donasi oleh proxy luar.
4. **Alamat Dompet Murni:**  
   Miner hanya menerima wallet dari [`config.json`](file:///c:/Users/Raihan/Downloads/farming/config.json) milikmu. Tidak ada script tersembunyi yang mengganti wallet di tengah jalan.
5. **Kode Terbuka (Open Source Plaintext):**  
   Semua file script berbentuk teks biasa (`.ps1`, `.bat`, `.json`). Tidak ada file biner tersembunyi selain `xmrig.exe` yang diunduh langsung dari GitHub resmi [xmrig/xmrig](https://github.com/xmrig/xmrig/releases).

#### 🔍 Cara Cek Hasil Tambangmu Secara Transparan:
1. Buka website pool yang kamu gunakan: [supportxmr.com](https://supportxmr.com/) (atau [moneroocean.stream](https://moneroocean.stream/)).
2. Masukkan alamat wallet XMR kamu di kolom pencarian dashboard pool.
3. Kamu bisa melihat worker `Ryzen7-Worker` aktif mengirim hashrate, jumlah shares yang valid, dan saldo XMR yang terkumpul secara real-time.

---

### ✨ Fitur-Fitur Pintar yang Disediakan:

1. **🔋 Battery Guard (Perlindungan Baterai Laptop)**
   - Otomatis mendeteksi sumber daya listrik.
   - Jika charger dicabut dan laptop berjalan memakai baterai, miner **otomatis di-PAUSE** agar baterai tidak rusak atau drop mendadak.
   - Saat charger dicolok kembali, miner otomatis **RESUME**.

2. **💤 Smart Idle Detection (Stealth & Dual-Speed Mode)**
   - Mendeteksi pergerakan mouse & keyboard pengguna secara native.
   - **Saat PC aktif dipakai:** Otomatis beralih ke *Mode Throttle* (hanya 2 thread) sehingga PC tidak lemot dan tetap dingin.
   - **Saat PC ditinggal pergi (Idle > 3 menit):** Otomatis menaikkan kecepatan ke *Mode Maksimal* (8 thread optimal).

3. **🎮 Game & Heavy App Blocker (Bebas Drop FPS)**
   - Mendeteksi proses game yang sedang berjalan (seperti *CS2, Valorant, Dota 2, GTA V, Genshin Impact, Fortnite, Apex Legends, Premiere Pro, Blender*).
   - Saat game dibuka, miner otomatis berhenti total agar game mendapat 100% daya CPU & GPU tanpa lag / stuttering.
   - Saat game ditutup, miner otomatis melanjutkan tugasnya.

4. **🔄 Multi-Pool Failover (Toleransi Gangguan Jaringan)**
   - Jika pool utama mengalami gangguan koneksi 3x berturut-turut, script otomatis berpindah ke **Backup Pool** (MoneroOcean) agar proses mining tidak terbuang sia-sia.

5. **⏰ Night & Time Scheduler (Jadwal Jam Tertentu)**
   - Opsi untuk membatasi mining hanya pada jam-jam tertentu (misal: 22:00 - 06:00 pagi saat jam tidur).

6. **⚡ 1-Click Huge Pages Optimizer (`enable_huge_pages.bat`)**
   - Script 1-klik untuk mengaktifkan fitur Windows *Lock Pages in Memory*.
   - Memberikan bonus hashrate **+20% s/d 30% secara gratis** tanpa menambah konsumsi daya listrik.

---

### 📁 Struktur File di Folder:
- [`config.json`](file:///c:/Users/Raihan/Downloads/farming/config.json) : Pusat pengaturan fitur (wallet, pool, thread, idle time, game list).
- [`start_mining.bat`](file:///c:/Users/Raihan/Downloads/farming/start_mining.bat) : File eksekusi utama (Jalankan via **Run as Administrator**).
- [`enable_huge_pages.bat`](file:///c:/Users/Raihan/Downloads/farming/enable_huge_pages.bat) : Tool 1-klik untuk aktivasi Huge Pages Windows.
- [`download_xmrig.bat`](file:///c:/Users/Raihan/Downloads/farming/download_xmrig.bat) : Tool pengunduh binary resmi XMRig jika diperlukan.
- [`start_mining.ps1`](file:///c:/Users/Raihan/Downloads/farming/start_mining.ps1) : Core engine supervisor yang memantau sistem tiap 5 detik.

---

### ⚙️ Cara Mengatur Pengaturan di [`config.json`](file:///c:/Users/Raihan/Downloads/farming/config.json):

```json
{
  "pool": "pool.supportxmr.com:3333",
  "backup_pool": "gulf.moneroocean.stream:10128",
  "wallet": "MASUKKAN_ALAMAT_WALLET_XMR_DISINI",
  "worker_name": "Ryzen7-Worker",

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
    "action_when_active": "throttle"   // Opsi: "throttle" (2 thread) atau "pause" (berhenti total)
  },

  "game_detection": {
    "enabled": true,
    "process_names": [
      "cs2", "valorant", "dota2", "gta5", "GenshinImpact"
    ]
  },

  "schedule": {
    "enabled": false,
    "start_time": "22:00",
    "stop_time": "06:00"
  }
}
```

---

### 🚀 Cara Menjalankan:
1. Pastikan alamat wallet di [`config.json`](file:///c:/Users/Raihan/Downloads/farming/config.json) sudah kamu isi dengan wallet Monero milikmu.
2. (Opsional sekali di awal) Klik kanan [`enable_huge_pages.bat`](file:///c:/Users/Raihan/Downloads/farming/enable_huge_pages.bat) $\rightarrow$ **Run as administrator**, lalu restart PC untuk klaim boost hashrate +30%.
3. Klik kanan [`start_mining.bat`](file:///c:/Users/Raihan/Downloads/farming/start_mining.bat) $\rightarrow$ **Run as administrator**.
4. Biarkan script bekerja di latar belakang. Script akan otomatis menyesuaikan diri saat kamu bermain game, mengetik, atau mencabut charger!
