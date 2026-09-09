class PdaModel {
  final String namaPelanggan;
  final String alamatPelanggan;
  final String tipeIdentitasPelanggan;
  final String nomorIdentitasPelanggan;
  final String nomorLayanan;
  final String atasNamaLayanan; // 👈 Wajib ada
  final String alamatLokasiLayanan; // 👈 Wajib ada
  final String alamatLama;
  final String alamatBaru;
  final String nomorTeleponLama;
  final String nomorTeleponBaru;
  final String nomorInternetLama;
  final String nomorInternetBaru;
  final String keterangan;
  final String namaPjTelkom;
  final bool tampilkanTtdTelkom;
  final String? namaKuasa;
  final String? tipeIdentitasKuasa;
  final String? nomorIdentitasKuasa;
  final String? alamatKuasa;

  PdaModel({
    required this.namaPelanggan,
    required this.alamatPelanggan,
    required this.tipeIdentitasPelanggan,
    required this.nomorIdentitasPelanggan,
    required this.nomorLayanan,
    required this.atasNamaLayanan, // 👈 Wajib ada
    required this.alamatLokasiLayanan, // 👈 Wajib ada
    required this.alamatLama,
    required this.alamatBaru,
    required this.nomorTeleponLama,
    required this.nomorTeleponBaru,
    required this.nomorInternetLama,
    required this.nomorInternetBaru,
    required this.keterangan,
    required this.namaPjTelkom,
    required this.tampilkanTtdTelkom,
    this.namaKuasa,
    this.tipeIdentitasKuasa,
    this.nomorIdentitasKuasa,
    this.alamatKuasa,
  });
}