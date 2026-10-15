# ⛏️ Monero (XMR) RandomX Smart Mining Suite

Suite automasi dan pengatur efisiensi daya cerdas untuk menambang **Monero (XMR)** dengan algoritma **RandomX** pada prosesor multi-core (**AMD Ryzen** & **Intel Core**).

Script ini secara cerdas mendeteksi kapasitas **L3 Cache** dan core CPU kamu secara otomatis, lalu menentukan alokasi thread yang paling efisien, dingin, dan hemat listrik tanpa membuang daya percuma.

---

### 💡 Konsep Efisiensi Daya RandomX: "Mengapa Tidak 100% Core?"
Pada algoritma RandomX, 1 thread penambang membutuhkan **2 MB L3 Cache**.
- **Rumus:** $\text{Thread Optimal} = \frac{\text{Kapasitas L3 Cache (MB)}}{2\text{ MB}}$
- *Contoh:* Jika prosesor memiliki L3 Cache 16 MB, maka alokasi maksimal yang efektif adalah $16 \div 2 = 8$ thread. Memaksa lebih banyak thread dari kapasitas cache hanya akan membuat CPU panas dan boros listrik tanpa menambah hashrate (akibat *cache bottleneck*). Script ini otomatis menghitungnya untuk CPU apa pun yang kamu gunakan!

---

### 🛡️ Jaminan 100% Transparan & Anti-DevFee Scam (Hanya Menguntungkan Kamu)

Banyak script mining di internet (YouTube/Telegram/forum) diam-diam **merugikan pengguna** dengan menyisipkan wallet si pembuat, mengarahkan koneksi ke server proxy perantara yang memotong hashrate 5%-20%, atau menyembunyikan malware.

**Script ini dibuat 100% aman, bersih, dan murni untuk keuntunganmu:**
1. **0% Potongan untuk Pembuat Script (Zero Script Fee):**  
   Script wrapper ini tidak memotong sepeser pun. 100% hasil penambangan langsung masuk ke dompetmu.
2. **Koneksi Langsung Tanpa Proxy Perantara:**  
   Komputer kamu terhubung langsung ke pool resmi (`pool.supportxmr.com` / `moneroocean.stream`). Tidak ada server penengah yang memotong shares.
3. **Parameter Proteksi Terkunci:**  
   Di [`start_mining.ps1`](file:///c:/Users/Raihan/Downloads/farming/start_mining.ps1) telah dikunci:
   - `--donate-level=1` : Level donasi terendah resmi developer XMRig (1 menit per 100 menit).
   - `--donate-over-proxy=0` : Menolak pemotongan donasi oleh proxy luar.
4. **Alamat Dompet Murni:**  
   Miner hanya menerima wallet dari [`config.json`](file:///c:/Users/Raihan/Downloads/farming/config.json) milikmu. Tidak ada script tersembunyi yang mengganti wallet di tengah jalan.
5. **Kode Terbuka (Open Source Plaintext):**  
   Semua file script berbentuk teks biasa (`.ps1`, `.bat`, `.json`). Tidak ada file biner tersembunyi selain `xmrig.exe` yang diunduh langsung dari GitHub resmi [xmrig/xmrig](https://github.com/xmrig/xmrig/releases).

---

### 📖 Langkah-Langkah Penggunaan (Dari Awal Sampai Berjalan)

Ikuti langkah-langkah mudah berikut untuk mulai menambang:

#### Langkah 1: Clone atau Unduh Repository
Clone repository ini ke komputer kamu:
```bash
git clone https://github.com/zyanmd/miningxmrig.git
cd miningxmrig
```
*Atau klik tombol hijau **Code** $\rightarrow$ **Download ZIP** di halaman GitHub, lalu ekstrak ke folder pilihanmu.*

#### Langkah 2: Masukkan Alamat Wallet Kamu
1. Buka file [`config.json`](file:///c:/Users/Raihan/Downloads/farming/config.json) menggunakan text editor (Notepad, VS Code, dll).
2. Ganti nilai `"YOUR_MONERO_WALLET_ADDRESS"` dengan alamat wallet Monero (XMR) milikmu:
   ```json
   "wallet": "48edfHu7V9Z84YzzMa6fUueHA6CF6XyK7...",
   "worker_name": "Worker1"
   ```
3. Simpan file (`Ctrl + S`).

#### Langkah 3: Unduh Binary XMRig Resmi
- Klik ganda file **`download_xmrig.bat`**.
- Script akan otomatis mengambil file rilis Windows resmi terbaru langsung dari GitHub XMRig dan mengekstraknya di folder yang sama.
*(Catatan: Jika kamu melewati langkah ini, script launcher utama juga akan otomatis menawarkannya).*

#### Langkah 4: (Sangat Disarankan) Aktifkan Huge Pages Windows
- Klik kanan file **`enable_huge_pages.bat`** $\rightarrow$ pilih **Run as administrator**.
- Script akan mendaftarkan izin *Lock Pages in Memory* di Windows.
- **Restart komputer kamu** setelah selesai.
> [!TIP]
> Mengaktifkan Huge Pages memberikan bonus peningkatan hashrate sebesar **+20% s/d 30% secara gratis** tanpa menaikkan watt listrik atau membuat CPU lebih panas!

#### Langkah 5: Mulai Menambang!
- Klik kanan file **`start_mining.bat`** $\rightarrow$ pilih **Run as administrator**.
*(Hak akses Administrator diperlukan agar optimasi MSR Mod pada AMD Ryzen atau Intel Core dapat diaktifkan secara otomatis).*
- Script cerdas akan mulai memantau sistem dan menjalankan miner secara otomatis.

#### Langkah 6: Pantau Statistik & Hasil Tambang
1. Buka website pool yang kamu gunakan: [supportxmr.com](https://supportxmr.com/) (atau [moneroocean.stream](https://moneroocean.stream/)).
2. Masukkan alamat wallet XMR kamu pada kolom pencarian dashboard pool.
3. Kamu bisa melihat hashrate langsung, jumlah shares yang valid, dan saldo koin XMR yang terkumpul secara real-time.

---

### ✨ Fitur-Fitur Pintar Otomasi:

1. **🔋 Battery Guard (Perlindungan Baterai Laptop)**
   - Otomatis mendeteksi sumber daya listrik.
   - Jika charger dicabut dan laptop berjalan memakai baterai, miner **otomatis di-PAUSE** agar baterai tidak cepat drop atau rusak.
   - Saat charger dicolok kembali, miner otomatis **RESUME**.

2. **💤 Smart Idle Detection (Stealth & Dual-Speed Mode)**
   - Mendeteksi pergerakan mouse & keyboard pengguna secara native.
   - **Saat PC aktif dipakai:** Otomatis beralih ke *Mode Throttle* (hanya 2 thread) sehingga PC tidak lag dan tetap dingin.
   - **Saat PC ditinggal pergi (Idle > 3 menit):** Otomatis menaikkan kecepatan ke *Mode Maksimal* (thread optimal sesuai L3 cache).

3. **🎮 Game & Heavy App Blocker (Bebas Drop FPS)**
   - Mendeteksi proses game yang sedang berjalan (*CS2, Valorant, Dota 2, GTA V, Genshin Impact, Fortnite, Apex Legends, Premiere Pro, Blender, dll*).
   - Saat game dibuka, miner otomatis berhenti total agar game mendapat 100% daya CPU & GPU tanpa lag / stuttering.
   - Saat game ditutup, miner otomatis melanjutkan penambangan.

4. **🔄 Multi-Pool Failover (Toleransi Gangguan Jaringan)**
   - Jika pool utama mengalami gangguan koneksi 3x berturut-turut, script otomatis berpindah ke **Backup Pool** (MoneroOcean) agar hashrate tidak terbuang sia-sia.

5. **⏰ Night & Time Scheduler (Jadwal Jam Tertentu)**
   - Opsi untuk membatasi mining hanya pada jam-jam tertentu (misal: pukul 22:00 malam s/d 06:00 pagi saat jam tidur atau tarif listrik malam).

---

### 📁 Struktur File di Folder:

| File | Deskripsi |
| :--- | :--- |
| [`config.json`](file:///c:/Users/Raihan/Downloads/farming/config.json) | File pusat konfigurasi (wallet, pool, batasan thread, daftar game, jadwal). |
| [`start_mining.bat`](file:///c:/Users/Raihan/Downloads/farming/start_mining.bat) | File launcher utama (Jalankan via **Run as Administrator**). |
| [`start_mining.ps1`](file:///c:/Users/Raihan/Downloads/farming/start_mining.ps1) | Mesin supervisor utama yang memantau baterai, aktivitas mouse/keyboard, dan proses game tiap 5 detik. |
| [`enable_huge_pages.bat`](file:///c:/Users/Raihan/Downloads/farming/enable_huge_pages.bat) | Tool 1-klik untuk mendaftarkan izin *Lock Pages in Memory* Windows (Boost +30% hashrate). |
| [`download_xmrig.bat`](file:///c:/Users/Raihan/Downloads/farming/download_xmrig.bat) | Script 1-klik untuk mengunduh binary resmi XMRig dari GitHub. |

---

### ⚙️ Konfigurasi Lengkap [`config.json`](file:///c:/Users/Raihan/Downloads/farming/config.json):

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
    "action_when_active": "throttle"   // Opsi: "throttle" (2 thread) atau "pause" (berhenti total)
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
