# Update Batch 1 — Tema Futuristik PPSI_app

## Cara pasang
Zip ini berisi HANYA file yang baru/berubah (bukan seluruh folder lib),
supaya aman ditimpa ke project lama kamu. Strukturnya sudah sama persis
dengan folder `lib/` project kamu, jadi tinggal:

1. Tutup semua proses Java/Gradle dulu (biar tidak "File in Use" seperti kemarin).
2. Extract zip ini.
3. Copy folder `lib/` di dalam zip ini ke `D:\flutter_projects\PPSI_app\`,
   pilih **"Replace/Overwrite"** saat Windows nanya (isinya cuma menimpa
   8 file ini, file lain di lib kamu TIDAK disentuh/dihapus).
4. Di terminal project: `flutter clean` lalu `flutter pub get` lalu jalankan
   di emulator.

## File yang baru (nambah, aman):
- `lib/widgets/app_logo.dart` — logo RT digambar lewat kode (bukan file
  gambar), jadi tidak perlu ubah `pubspec.yaml` sama sekali.
- `lib/widgets/hover_scale.dart` — komponen efek hover kursor + tekan,
  dipakai di banyak tombol/menu.
- `lib/widgets/running_text_pembayaran.dart` — teks berjalan status iuran
  di bawah card "Selamat Datang" pada Home.

## File yang diubah (ditimpa):
- `lib/utils/app_colors.dart` — nambah gradient hijau baru yang lebih
  hidup/futuristik (`futuristicGradient`, `authBackgroundGradient`) +
  memperkaya `mainGradient` yang lama (otomatis bikin header semua
  halaman sekunder — Pengumuman, Kegiatan, dst — ikut lebih hidup tanpa
  perlu saya sentuh satu-satu).
- `lib/widgets/app_drawer.dart` — logo di header sidebar, gradient baru,
  efek hover/tint di setiap menu.
- `lib/widgets/modern_app_bar.dart` — tombol menu (☰) dikasih efek hover.
- `lib/screens/login_screen.dart` — didesain ulang total: background
  gradient gelap dengan blob glow, kartu kaca (glassmorphism), logo di
  atas, toggle "Masuk/Daftar" model pill animasi, input dengan glow saat
  fokus, tombol dengan efek hover+tekan. **Logic login/register/validasi
  error tidak diubah sedikit pun** — murni tampilan.
- `lib/screens/home_screen.dart` — header dikasih tombol ☰ (buka sidebar),
  logo, gradient baru; hero card "Selamat Datang" pakai gradient baru;
  ditambahkan banner teks berjalan status iuran tepat di bawahnya; semua
  quick action & tombol hero sekarang punya efek hover/klik.

## Tentang logo
Saya belum punya file PNG logo final kamu (yang bentuk lingkaran hijau
"RT 003 RW 011" itu) di dalam project, dan menambah file gambar baru
butuh edit `pubspec.yaml` (di luar folder `lib`) — jadi supaya update ini
bisa cukup dengan **swap folder lib saja** seperti maumu, saya bikin logo
versi vektor (digambar lewat kode Flutter) yang senada: hijau, ikon rumah,
aksen daun. Ini dipakai di semua tempat (login, drawer, header home).

Kalau nanti kamu mau pakai file PNG logo asli:
1. Taruh filenya di `lib/img/logo.png`
2. Tambahkan di `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - lib/img/logo.png
   ```
3. Bilang ke saya, nanti saya update `app_logo.dart` untuk load PNG itu
   langsung — cukup 1 file, tidak perlu ubah tempat lain karena semua
   sudah refer ke widget `AppLogo` ini.

## Yang BELUM termasuk di batch ini (menyusul di batch berikutnya)
Sesuai kesepakatan kita, batch ini baru tahap tema/tampilan. Fitur
akun keluarga (Tambah Anggota, aktivasi KK), Pantau Pembayaran,
pembayaran custom, FAQ, live chat, approval UMKM, laporan keuangan,
manual book, dan export database akan saya buat di batch selanjutnya.

## Uji coba yang disarankan di emulator
- Buka halaman Login/Daftar → cek tampilan gradient, toggle, dan hover
  di tombol (kalau di run di Chrome/Windows desktop, coba hover mouse).
- Login sebagai warga → cek header Home ada ikon ☰, tap untuk buka sidebar.
- Perhatikan banner teks berjalan di bawah card "Selamat Datang" — kalau
  belum ada data pembayaran bulan ini di Firestore, ia akan tampil sebagai
  "belum bayar" (warna amber) dan bisa diketuk ke halaman Pembayaran.
