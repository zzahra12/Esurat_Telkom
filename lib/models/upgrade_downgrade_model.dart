class UpgradeDowngradeModel {
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

  // Detail Permohonan Upgrade/Downgrade
  final String tipeModifikasi; // "UPGRADE" atau "DOWNGRADE"
  final String namaTransaksi;
  final String keterangan;
  final String tagihan;
  final String keteranganTambahanDetail;

  UpgradeDowngradeModel({
    this.namaKuasa = '',
    this.alamatKuasa = '',
    this.tipeIdentitasKuasa = '',
    this.nomorIdentitasKuasa = '',
    required this.namaPelanggan,
    required this.alamatPelanggan,
    required this.tipeIdentitasPelanggan,
    required this.nomorIdentitasPelanggan,
    required this.nomorLayanan,
    required this.tipeModifikasi,
    required this.namaTransaksi,
    this.keterangan = '-',
    this.tagihan = '-',
    this.keteranganTambahanDetail = '-',
  });
}