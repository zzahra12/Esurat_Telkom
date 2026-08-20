class PdaModel {
  // Penerima Kuasa (Opsional)
  final String namaKuasa;
  final String alamatKuasa;
  final String tipeIdentitasKuasa;
  final String nomorIdentitasKuasa;

  // Pelanggan
  final String namaPelanggan;
  final String alamatPelanggan;
  final String tipeIdentitasPelanggan;
  final String nomorIdentitasPelanggan;

  // Data Layanan Utama
  final String nomorLayanan;

  // Detail Permohonan Pindah Alamat (PDA)
  final String alamatLama;
  final String alamatBaru;
  final String noTelpLama;
  final String noTelpBaru;
  final String noInternetLama;
  final String noInternetBaru;
  final String keterangan;

  PdaModel({
    this.namaKuasa = '',
    this.alamatKuasa = '',
    this.tipeIdentitasKuasa = '',
    this.nomorIdentitasKuasa = '',
    required this.namaPelanggan,
    required this.alamatPelanggan,
    required this.tipeIdentitasPelanggan,
    required this.nomorIdentitasPelanggan,
    required this.nomorLayanan,
    required this.alamatLama,
    required this.alamatBaru,
    this.noTelpLama = '-',
    this.noTelpBaru = '-',
    this.noInternetLama = '-',
    this.noInternetBaru = '-',
    this.keterangan = '-',
  });
}