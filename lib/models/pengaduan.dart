class Pengaduan {
  final int idPengaduan;
  final String namaPengaduan;
  final String deskripsi;
  final String lokasi;
  final String? foto;
  final String status;
  final DateTime tglPengajuan;
  final DateTime? tglVerifikasi;
  final DateTime? tglSelesai;
  final String? catatanAdmin;
  final String? saranPetugas;
  final Item? item;
  final Petugas? petugas;

  Pengaduan({
    required this.idPengaduan,
    required this.namaPengaduan,
    required this.deskripsi,
    required this.lokasi,
    this.foto,
    required this.status,
    required this.tglPengajuan,
    this.tglVerifikasi,
    this.tglSelesai,
    this.catatanAdmin,
    this.saranPetugas,
    this.item,
    this.petugas,
  });

  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      idPengaduan: json['id_pengaduan'],
      namaPengaduan: json['nama_pengaduan'],
      deskripsi: json['deskripsi'],
      lokasi: json['lokasi'],
      foto: json['foto'],
      status: json['status'],
      tglPengajuan: DateTime.parse(json['tgl_pengajuan']),
      tglVerifikasi: json['tgl_verifikasi'] != null ? DateTime.parse(json['tgl_verifikasi']) : null,
      tglSelesai: json['tgl_selesai'] != null ? DateTime.parse(json['tgl_selesai']) : null,
      catatanAdmin: json['catatan_admin'],
      saranPetugas: json['saran_petugas'],
      item: json['item'] != null ? Item.fromJson(json['item']) : null,
      petugas: json['petugas'] != null ? Petugas.fromJson(json['petugas']) : null,
    );
  }
}

class Item {
  final int idItem;
  final String namaItem;

  Item({
    required this.idItem,
    required this.namaItem,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      idItem: json['id_item'],
      namaItem: json['nama_item'],
    );
  }
}

class Petugas {
  final int idPetugas;
  final String? namaPetugas;

  Petugas({
    required this.idPetugas,
    this.namaPetugas,
  });

  factory Petugas.fromJson(Map<String, dynamic> json) {
    return Petugas(
      idPetugas: json['id_petugas'],
      namaPetugas: json['nama_petugas'],
    );
  }
}