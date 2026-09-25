class KbmModel {
  final String namaPengaju; // Pilihan: Ericha / Azki / Yustika
  final String unitLoker;
  final String lokasiTujuan;
  final String jenisBbm; // Contoh: Pertamax / Pertalite / Solar
  final String deskripsiKegiatan;
  final String kotaLokasi;
  final String tanggalSurat;

  KbmModel({
    required this.namaPengaju,
    required this.unitLoker,
    required this.lokasiTujuan,
    required this.jenisBbm,
    required this.deskripsiKegiatan,
    required this.kotaLokasi,
    required this.tanggalSurat,
  });
}