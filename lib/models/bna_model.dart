class BnaModel {
  // Penerima Kuasa (Opsional)
  final String namaKuasa;
  final String alamatKuasa;
  final String tipeIdentitasKuasa;
  final String nomorIdentitasKuasa;

  // Pelanggan (Pemohon Balik Nama)
  final String namaPelanggan;
  final String alamatPelanggan;
  final String tipeIdentitasPelanggan;
  final String nomorIdentitasPelanggan;

  // Data Layanan Utama
  final String nomorLayanan;
  final String atasNamaLayanan;
  final String alamatLokasiLayanan;

  // Detail Permohonan Balik Nama / Ganti Nama (BNA)
  final String namaLama;
  final String namaBaru;
  final String keterangan;

  // Penanggung Jawab Telkom
  final String namaPjTelkom;
  final bool tampilkanTtdTelkom;

  BnaModel({
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
    required this.namaLama,
    required this.namaBaru,
    this.keterangan = '-',
    this.namaPjTelkom = 'Yustika Monita',
    this.tampilkanTtdTelkom = true,
  });
}