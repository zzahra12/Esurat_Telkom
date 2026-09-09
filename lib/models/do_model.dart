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
  final String atasNamaLayanan;
  final String alamatLokasiLayanan;

  // Detail Berhenti Berlangganan (DO)
  final String namaTransaksi;
  final String keterangan;
  final String tagihan;
  final String keteranganTambahan;

  // Penanggung Jawab Telkom
  final String namaPjTelkom;
  final bool tampilkanTtdTelkom;

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
    required this.atasNamaLayanan,
    required this.alamatLokasiLayanan,
    this.namaTransaksi = 'Berhenti Berlangganan',
    this.keterangan = '-',
    this.tagihan = '-',
    this.keteranganTambahan = '-',
    this.namaPjTelkom = 'nama yang menerima transaksi',
    this.tampilkanTtdTelkom = true,
  });
}