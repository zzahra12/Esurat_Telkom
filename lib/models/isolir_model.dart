class IsolirModel {
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

  // Detail Permohonan Isolir
  final String durasiIsolir; // Misal: "1 Bulan", "2 Minggu"
  final String tanggalIsolir;
  final String tanggalBukaIsolir;
  final String keterangan;

  IsolirModel({
    this.namaKuasa = '',
    this.alamatKuasa = '',
    this.tipeIdentitasKuasa = '',
    this.nomorIdentitasKuasa = '',
    required this.namaPelanggan,
    required this.alamatPelanggan,
    required this.tipeIdentitasPelanggan,
    required this.nomorIdentitasPelanggan,
    required this.nomorLayanan,
    required this.durasiIsolir,
    required this.tanggalIsolir,
    required this.tanggalBukaIsolir,
    this.keterangan = '-',
  });
}