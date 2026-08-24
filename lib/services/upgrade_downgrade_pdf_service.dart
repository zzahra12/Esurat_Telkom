import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/upgrade_downgrade_model.dart';

class UpgradeDowngradePdfService {
  static Future<Uint8List> generatePdf(UpgradeDowngradeModel data) async {
    // Inisialisasi locale tanggal Bahasa Indonesia
    await initializeDateFormatting('id_ID', null);

    // Format tanggal real-time otomatis
    final String tanggalRealtime =
        'Banyuwangi, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}';

    // Logika coret salah satu (UPGRADE / DOWNGRADE)
    final isUpgrade = data.tipeModifikasi.toUpperCase() == 'UPGRADE';

    final pdf = pw.Document();

    // Cek ketersediaan data Penerima Kuasa
    final bool adaKuasa =
        (data.namaKuasa ?? '').toString().trim().isNotEmpty &&
            (data.namaKuasa ?? '').toString().trim() != '-';

    // 🔄 PEMETAAN VARIABEL STANDARD TELKOM:
    // ATAS: Selalu Data Pelanggan Utama
    String atasNama = data.namaPelanggan;
    String atasAlamat = data.alamatPelanggan;
    String atasTipeId = data.tipeIdentitasPelanggan;
    String atasNoId = data.nomorIdentitasPelanggan;

    // TENGAH: Data Penerima Kuasa (jika ada) atau '-'
    String bawahNama = adaKuasa ? data.namaKuasa : '-';
    String bawahAlamat = adaKuasa ? data.alamatKuasa : '-';
    String bawahTipeId = adaKuasa ? data.tipeIdentitasKuasa : '-';
    String bawahNoId = adaKuasa ? data.nomorIdentitasKuasa : '-';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. JUDUL SURAT
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'SURAT PERMINTAAN',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                    pw.Text(
                      'MODIFIKASI LAYANAN',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // 2. BAGIAN ATAS: YANG BERTANDA TANGAN DI BAWAH INI (DATA PELANGGAN)
              pw.Text('Yang bertanda tangan di bawah ini :',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 3),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Column(
                  children: [
                    _buildRow('Nama', atasNama),
                    _buildRow('Alamat', atasAlamat),
                    _buildRow('Tipe Identitas', atasTipeId),
                    _buildRow('Nomor Identitas', atasNoId),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '(*diisi bila mutasi dilakukan oleh pihak penerima kuasa dari PELANGGAN)',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              // 3. BAGIAN TENGAH: BERTINDAK UNTUK DAN ATAS NAMA (DATA KUASA)
              pw.Text('Bertindak untuk dan atas nama:',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 3),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Column(
                  children: [
                    _buildRow('Nama*', bawahNama),
                    _buildRow('Alamat*', bawahAlamat),
                    _buildRow('Tipe Identitas*', bawahTipeId),
                    _buildRow('Nomor Identitas*', bawahNoId),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // 4. DETAIL LAYANAN
              pw.Text(
                'Selanjutnya disebut sebagai "PELANGGAN", selaku pihak yang berlangganan layanan Indibiz sebagai berikut:',
                style: const pw.TextStyle(fontSize: 8.5),
              ),
              pw.SizedBox(height: 4),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Column(
                  children: [
                    _buildRow('Nomor Layanan', data.nomorLayanan),
                    _buildRow('Atas Nama', data.namaPelanggan),
                    _buildRow('Alamat', data.alamatPelanggan),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // 5. MENYATAKAN
              pw.Center(
                child: pw.Text(
                  'MENYATAKAN',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 6),

              // Pernyataan dengan Coret Salah Satu
              pw.RichText(
                textAlign: pw.TextAlign.justify,
                text: pw.TextSpan(
                  style: const pw.TextStyle(
                      fontSize: 8.5, color: PdfColors.black),
                  children: [
                    const pw.TextSpan(
                      text:
                          'BAHWA, PELANGGAN adalah benar pihak yang berlangganan Layanan Indibiz berdasarkan Kontrak Berlangganan, dan dengan ini mengajukan permintaan ',
                    ),
                    pw.TextSpan(
                      text: 'UPGRADE',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        decoration: isUpgrade
                            ? pw.TextDecoration.none
                            : pw.TextDecoration.lineThrough,
                      ),
                    ),
                    const pw.TextSpan(text: '/'),
                    pw.TextSpan(
                      text: 'DOWNGRADE',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        decoration: !isUpgrade
                            ? pw.TextDecoration.none
                            : pw.TextDecoration.lineThrough,
                      ),
                    ),
                    const pw.TextSpan(
                      text:
                          ' (coret salah satu) Layanan Indibiz, sebagai berikut:',
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // 6. DETAIL PERMOHONAN MODIFIKASI
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Column(
                  children: [
                    _buildSubRow('Jenis Permohonan', data.tipeModifikasi),
                    _buildSubRow('Nama Transaksi', data.namaTransaksi),
                    _buildSubRow('Keterangan', data.keterangan),
                    _buildSubRow('Tagihan', data.tagihan),
                    _buildSubRow('Keterangan Tambahan',
                        data.keteranganTambahanDetail),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // 7. KETERANGAN TAMBAHAN
              pw.Text('Keterangan Tambahan :',
                  style: const pw.TextStyle(fontSize: 8.5)),
              pw.SizedBox(height: 2),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('1.  ', style: const pw.TextStyle(fontSize: 8)),
                  pw.Expanded(
                    child: pw.Text(
                      'Permohonan ini berlaku sejak ditandatanganinya Surat Permintaan Upgrade/Downgrade Layanan ini.',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('2.  ', style: const pw.TextStyle(fontSize: 8)),
                  pw.Expanded(
                    child: pw.Text(
                      'Surat Permintaan Upgrade/Downgrade Layanan ini merupakan satu kesatuan yang tidak terpisahkan dengan Kontrak Berlangganan yang telah ditandatanganinya PT Telkom Indonesia (Persero) Tbk dengan PELANGGAN.',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // 8. DUA KOLOM TANDA TANGAN (PERBAIKAN NAMA & KUASA)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Kolom Kiri: Penanggung Jawab Telkom (Otomatis Yustika Monita)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.SizedBox(height: 12),
                        pw.Text(
                          'Penanggung Jawab Telkom',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 45),
                        pw.Text(
                          '(Yustika Monita)',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),

                  // Kolom Kanan: Pelanggan (Penerima Kuasa / Pelanggan Utama)
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          tanggalRealtime,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Pelanggan',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(right: 15.0),
                          child: pw.SizedBox(
                            height: 35,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'Materai',
                                  style: const pw.TextStyle(
                                      fontSize: 7, color: PdfColors.black),
                                ),
                                pw.Text(
                                  '10.000',
                                  style: const pw.TextStyle(
                                      fontSize: 7, color: PdfColors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.Text(
                          '(${adaKuasa ? data.namaKuasa : data.namaPelanggan})',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 120,
              child:
                  pw.Text(label, style: const pw.TextStyle(fontSize: 8.5))),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Expanded(
              child: pw.Text(value.toString().isEmpty ? '-' : value.toString(),
                  style: const pw.TextStyle(fontSize: 8.5))),
        ],
      ),
    );
  }

  static pw.Widget _buildSubRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 140,
              child:
                  pw.Text(label, style: const pw.TextStyle(fontSize: 8.5))),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Expanded(
              child: pw.Text(value.toString().isEmpty ? '-' : value.toString(),
                  style: const pw.TextStyle(fontSize: 8.5))),
        ],
      ),
    );
  }

  static Future<void> saveAndOpenFile(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    }
  }
}