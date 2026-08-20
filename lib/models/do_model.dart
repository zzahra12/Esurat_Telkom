class DoModel {
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

  // Data Layanan
  final String nomorLayanan;

  // Detail Berhenti Berlangganan (DO)
  final String namaTransaksi;
  final String keterangan;
  final String tagihan;

  DoModel({
    this.namaKuasa = '',
    this.alamatKuasa = '',
    this.tipeIdentitasKuasa = '',
    this.nomorIdentitasKuasa = '',
    required this.namaPelanggan,
    required this.alamatPelanggan,
    required this.tipeIdentitasPelanggan,
    required this.nomorIdentitasPelanggan,
    required this.nomorLayanan,
    this.namaTransaksi = 'Berhenti Berlangganan Layanan Indibiz',
    this.keterangan = '-',
    this.tagihan = '-',
  });
}