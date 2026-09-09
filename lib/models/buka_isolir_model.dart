class BukaIsolirModel {
  final String namaPelanggan;
  final String tipeIdentitasPelanggan;
  final String nomorIdentitasPelanggan;
  final String alamatPelanggan;
  final String nomorLayanan;
  final String? namaPerusahaan;
  final String? alamatPemasangan;
  final String? keterangan;
  
  // Tambahkan dua baris ini:
  final String? namaPjTelkom;
  final bool? tampilkanTtdTelkom;

  // Opsional Kuasa
  final String? namaKuasa;
  final String? tipeIdentitasKuasa;
  final String? nomorIdentitasKuasa;
  final String? alamatKuasa;

  BukaIsolirModel({
    required this.namaPelanggan,
    required this.tipeIdentitasPelanggan,
    required this.nomorIdentitasPelanggan,
    required this.alamatPelanggan,
    required this.nomorLayanan,
    this.namaPerusahaan,
    this.alamatPemasangan,
    this.keterangan,
    this.namaPjTelkom,
    this.tampilkanTtdTelkom,
    this.namaKuasa,
    this.tipeIdentitasKuasa,
    this.nomorIdentitasKuasa,
    this.alamatKuasa,
  });
}