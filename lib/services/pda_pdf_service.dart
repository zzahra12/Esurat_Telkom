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
import '../models/pda_model.dart';

class PdaPdfService {
  static Future<Uint8List> generatePdf(PdaModel data) async {
    // Inisialisasi locale tanggal Bahasa Indonesia
    await initializeDateFormatting('id_ID', null);

    final String tanggalRealtime =
        'Banyuwangi, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}';

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
                child: pw.Text(
                  'SURAT PERMINTAAN PINDAH ALAMAT LAYANAN',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 18),

              // 2. BAGIAN ATAS: YANG BERTANDA TANGAN DI BAWAH INI (DATA PELANGGAN)
              pw.Text('Yang bertanda tangan di bawah ini :',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 4),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Column(
                  children: [
                    _buildDataRow('Nama', atasNama),
                    _buildDataRow('Alamat', atasAlamat),
                    _buildDataRow('Tipe Identitas', atasTipeId),
                    _buildDataRow('Nomor Identitas', atasNoId),
                  ],
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                '(*diisi bila mutasi dilakukan oleh pihak penerima kuasa dari PELANGGAN)',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),

              // 3. BAGIAN TENGAH: BERTINDAK UNTUK DAN ATAS NAMA (DATA KUASA)
              pw.Text('Bertindak untuk dan atas nama :',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 4),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 10),
                child: pw.Column(
                  children: [
                    _buildDataRow('Nama*', bawahNama),
                    _buildDataRow('Alamat*', bawahAlamat),
                    _buildDataRow('Tipe Identitas*', bawahTipeId),
                    _buildDataRow('Nomor Identitas*', bawahNoId),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // DETAIL LAYANAN
              pw.Text(
                'Selanjutnya disebut sebagai "PELANGGAN", selaku pihak yang berlangganan layanan Indibiz sebagai berikut:',
                style: const pw.TextStyle(fontSize: 8.5),
              ),
              pw.SizedBox(height: 6),
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

              // 4. PERNYATAAN
              pw.Center(
                child: pw.Text(
                  'MENYATAKAN',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'BAHWA, PELANGGAN adalah benar pihak yang berlangganan Layanan Indibiz berdasarkan Kontrak Berlangganan, dan dengan ini mengajukan permintaan Pindah Alamat Layanan Indibiz, sebagai berikut:',
                style: const pw.TextStyle(fontSize: 8.5),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 10),

              // 5. DETAIL PINDAH ALAMAT
              pw.Text(
                'Jenis Permohonan : Pindah Alamat',
                style:
                    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 15),
                child: pw.Column(
                  children: [
                    _buildSubRow('a. Alamat Lama', data.alamatLama),
                    _buildSubRow('b. Alamat Baru', data.alamatBaru),
                    _buildSubRow('c. Nomor Telepon Lama', data.noTelpLama),
                    _buildSubRow('d. Nomor Telepon Baru', data.noTelpBaru),
                    _buildSubRow('e. Nomor Internet Lama', data.noInternetLama),
                    _buildSubRow('f. Nomor Internet Baru', data.noInternetBaru),
                    _buildSubRow('g. Keterangan', data.keterangan),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // 6. KETERANGAN TAMBAHAN
              pw.Text('Keterangan Tambahan :',
                  style: const pw.TextStyle(fontSize: 8.5)),
              pw.SizedBox(height: 2),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('1.  ', style: const pw.TextStyle(fontSize: 8)),
                  pw.Expanded(
                    child: pw.Text(
                      'Permohonan ini berlaku sejak ditandatanganinya Surat Permintaan Pindah Alamat Layanan Indibiz ini.',
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
                      'Surat Permintaan Pindah Alamat Layanan Indibiz ini merupakan satu kesatuan yang tidak terpisahkan dengan Kontrak Berlangganan yang telah ditandatanganinya PT Telkom Indonesia (Persero) Tbk dengan PELANGGAN.',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // 7. DUA KOLOM TANDA TANGAN (PERBAIKAN NAMA & KUASA)
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

  // Helper Baris Data Form
  static pw.Widget _buildDataRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 110,
              child:
                  pw.Text(label, style: const pw.TextStyle(fontSize: 8.5))),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Expanded(
              child: pw.Text(value.toString().isEmpty ? '' : value.toString(),
                  style: const pw.TextStyle(fontSize: 8.5))),
        ],
      ),
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 110,
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