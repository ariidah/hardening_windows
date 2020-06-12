# hardening_wimdows_01.vbs

### DISCLAIMER

SAYA TIDAK BERTANGGUNG-JAWAB ATAS KERUGIAN APAPUN YANG MUNGKIN DAN DIHASILKAN DARI SCRIPT INI, BACA DAN PELAJARI DULU ISI DARI SCRIPT INI SEBELUM DIPASANG DI PRODUCTION ENVIRONMENT.

Sesuai namanya, script ini saya gunakan untuk hardening windows ditulis pada bahasa VBScript alasannya tidak perlu repot-repot compile ulang semisal ada baris yang perlu disesuaikan (sewaktu-waktu) ketika akan dijalankan di environment lain. Kekurangannya bisa dimodifikasi dan dibalikkan fungsinya oleh orang lain. Daripada hardening, script ini lebih mirip worm.

Saya sudah memasang script ini di Laptop saya (sejak 2020-01-26) sejauh ini belum ada masalah yang signifikan terkecuali modifikasi-modifikasi script untuk menambah fungsi.

Note : "REMOVABLE MEDIA" yang disebutkan disini adalah media yang bisa di format (Flashdrive, HDD) fitur Android MTP, PTP dan yang lainnya tidak termasuk.

### PERILAKU SCRIPT

- Script ini akan selalu terminate process 'conhost.exe', tujuannya untuk selalu terminate command prompt ('cmd.exe' membutuhkan 'conhost.exe') BAHKAN SEBELUM USER LOGIN.

- Script ini secara otomatis akan menghapus file yang terdeteksi sebagai 'blacklist' (mengandalkan ekstensi, definisi ada di variabel ext_regex) menggunakan Regular Expression (regex), untuk menghemat baris karena hanya butuh match atau mismatch.

- Script ini harus "run as Administrator" untuk akses registry pada fungsi allowrd() dan denyrd().

- Untuk eksekusi saja, setelah modifikasi tanpa output diasumsikan script sudah OK :

```
wscript.exe hardening_windows_01.vbs
```

- Untuk eksekusi (tanpa menghapus file di removable media maupun terminate 'conhost.exe', hanya memanggil allowrd()) menampilkan yang terindikasi akan diubah (terminate process, delete file) bisa menggunakan :

```
cscript.exe hardening_windows_01.vbs
```

### FUNGSI DAN SUB

denyrd()
- memblock akses read dan write ke removable media, akibatnya ketika menancapkan flashdrive baru tidak akan bisa diakses, free space dari removable media tidak akan tampil, hal ini akan terjadi setelah satu file dari removable media MATCH dengan ext_regex.

allowrd()
- membuka akses block read dan write ke removable media, selalu dieksekusi di awal script, membatalkan denyrd() via restart PC.

### VARIABEL YANG BISA DIMODIFIKASI

ext_regex,string
- digunakan untuk memblokir (blacklist) semua file di flashdrive dengan ekstensi yang match di regex ini secara default akan dihapus dan memicu trigger sub denyrd() isian ini HARUS berisi regex yang WORK, silahkan mempelajari lebih lanjut untuk penggunaan regex.
- default "(rar)|(exe)|(vbe)$"
- format  "(ekstensi-1)|(ekstensi-2)|(ekstensi-3)$"
- DEFAULT DIHAPUS bisa diubah dengan mencari baris 'fs.deletefile'.

proc_regex,string
- digunakan untuk mengizinkan (whitelist) executable yang menggunakan host 'conhost.exe' silahkan pelajari lebih lanjut untuk kegunaan process 'conhost.exe', isian ini HARUS berisi regex yang WORK, silahkan mempelajari lebih lanjut untuk penggunaan regex.
- default "(gpg).exe$"
- format  "(filename-1)|(filename-2)|(filename-3).exe$"

repeat,boolean
- set false untuk hanya satu kali scan direktori pada removable media
- set true untuk terus scan direktori pada removable media (digunakan untuk meminimalisir file dicopy ke removable media, berdasarkan ekstensi)

Untuk pemasangan permanent lokasi file script ini (sebagai contoh) bisa disimpan di direktori C:\ untuk menghindari modifikasi oleh orang yang tidak diizinkan. JANGAN SAMPAI ADA ORANG LAIN MEMILIKI AKSES UNTUK MODIFIKASI SCRIPT INI, KARENA BERDASARKAN TASK SCHEDULER YANG TELAH DIBUAT SETIAP BARIS YANG TERTERA PADA SCRIPT INI AKAN RUN AS ADMINISTRATOR. SAYA SUDAH MEMPERINGATKAN ANDA.

Untuk pemasangan permanent, eksekusi dianjurkan menggunakan/menambahkan Task Scheduler [Control Panel/System and Security/Administrative Tools/Task Scheduler] atau `taskschd.msc /s` pada "Task Scheduler Library" menggunakan "Administrator Privileges" dengan Trigger "At Startup" serta "Run whether user is logged on or not". Selengkapnya :

[General]

When running the task, use the following user account : [Gunakan user yang memiliki Administrative Privileges]

centang "Run whether user is logged  on or not"

centang "Run with highest privileges"

[Triggers]

Begin the task : At Startup

centang "Enabled"

[Actions]

Action : Start a program

Program/script : [path untuk script ini] usahakan aman, tidak bisa dimodifikasi atau diubah oleh orang lain. Referensi : 
 Advanced file Permission Windows.

[Conditions]

Pastikan tidak ada yang dicentang

[Settings]

centang If the task fails, restart every : 1 minute

Attempt restart up to : 3 times [bisa disesuaikan]

If the task is already running, then the following rule applies : Do not start a new instance
