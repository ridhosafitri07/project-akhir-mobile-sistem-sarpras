-- Fix kolom tanggal di tabel pengaduan agar bisa menyimpan JAM
-- Jalankan SQL ini di PHPMyAdmin

-- Ubah tgl_pengajuan dari DATE ke DATETIME
ALTER TABLE `pengaduan` 
MODIFY COLUMN `tgl_pengajuan` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Ubah tgl_selesai dari DATE ke DATETIME (nullable)
ALTER TABLE `pengaduan` 
MODIFY COLUMN `tgl_selesai` DATETIME NULL;

-- Setelah ini, data BARU yang dibuat akan otomatis punya jam!
-- Data lama tetap 00:00 karena memang tidak ada jam nya
