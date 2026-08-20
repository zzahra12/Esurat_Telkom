class BukaIsolirModel {
  // Data Yang Bertanda Tangan (Penerima Kuasa) - Opsional
  final String namaKuasa;
  final String alamatKuasa;
  final String tipeIdentitasKuasa;
  final String nomorIdentitasKuasa;

  // Data Pelanggan
  final String namaPelanggan;
  final String alamatPelanggan;
  final String tipeIdentitasPelanggan;
  final String nomorIdentitasPelanggan;

  // Data Layanan
  final String nomorLayanan;

  BukaIsolirModel({
    this.namaKuasa = '',
    this.alamatKuasa = '',
    this.tipeIdentitasKuasa = '',
    this.nomorIdentitasKuasa = '',
    required this.namaPelanggan,
    required this.alamatPelanggan,
    required this.tipeIdentitasPelanggan,
    required this.nomorIdentitasPelanggan,
    required this.nomorLayanan,
  });
}