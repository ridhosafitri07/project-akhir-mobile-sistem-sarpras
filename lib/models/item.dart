class Item {
  final int idItem;
  final String namaItem;
  final String? deskripsi;

  Item({
    required this.idItem,
    required this.namaItem,
    this.deskripsi,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      idItem: json['id_item'],
      namaItem: json['nama_item'],
      deskripsi: json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_item': idItem,
      'nama_item': namaItem,
      'deskripsi': deskripsi,
    };
  }
}