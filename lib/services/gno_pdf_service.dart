import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/gno_model.dart';

class GnoPdfService {
  static Future<Uint8List> generatePdf(GnoModel data) async {
    await initializeDateFormatting('id_ID', null);

    final String tanggalRealtime =
        'Banyuwangi, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}';

    // 🖼️ LOAD GAMBAR TTD DARI ASSETS
    pw.MemoryImage? ttdImage;
    try {
      final ttdBytes = await rootBundle.load('assets/images/ttd-telkom.jpg');
      ttdImage = pw.MemoryImage(ttdBytes.buffer.asUint8List());
    } catch (_) {}

    final pdf = pw.Document();

    final bool adaKuasa =
        (data.namaKuasa).toString().trim().isNotEmpty &&
            (data.namaKuasa).toString().trim() != '-';

    String atasNama = data.namaPelanggan;
    String atasAlamat = data.alamatPelanggan;
    String atasTipeId = data.tipeIdentitasPelanggan;
    String atasNoId = data.nomorIdentitasPelanggan;

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
                  'SURAT PERMINTAAN GANTI NOMOR LAYANAN',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 18),

              // 2. BAGIAN ATAS: DATA PELANGGAN
              pw.Text('Yang bertanda tangan di bawah ini :',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 4),
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
              pw.SizedBox(height: 6),
              pw.Text(
                '(*diisi bila mutasi dilakukan oleh pihak penerima kuasa dari PELANGGAN)',
                style: pw.TextStyle(
                    fontSize: 8,
                    fontStyle: pw.FontStyle.italic,
                    fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),

              // 3. BAGIAN TENGAH: DATA KUASA
              pw.Text('Bertindak untuk dan atas nama :',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 4),
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
                    _buildRow('Atas Nama', data.atasNamaLayanan),
                    _buildRow('Alamat', data.alamatLokasiLayanan),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // 4. MENYATAKAN
              pw.Center(
                child: pw.Text('MENYATAKAN',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 8),

              pw.Text(
                'BAHWA, PELANGGAN adalah benar pihak yang berlangganan Layanan Indibiz berdasarkan Kontrak Berlangganan, dan dengan ini mengajukan permintaan Ganti Nomor Layanan Indibiz, sebagai berikut:',
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(fontSize: 8.5),
              ),
              pw.SizedBox(height: 10),

              // 5. JENIS PERMOHONAN
              pw.Text(
                'Jenis Permohonan : Ganti Nomor Telepon / Internet',
                style:
                    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 15),
                child: pw.Column(
                  children: [
                    _buildSubRow('a. Nomor Telepon Lama', data.noTelpLama),
                    _buildSubRow('b. Nomor Telepon Baru', data.noTelpBaru),
                    _buildSubRow(
                        'c. Nomor Internet Lama', data.noInternetLama),
                    _buildSubRow(
                        'd. Nomor Internet Baru', data.noInternetBaru),
                    _buildSubRow('e. Keterangan', data.keterangan),
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
                      'Permohonan ini berlaku sejak ditandatanganinya Surat Permintaan Ganti Nomor Layanan Indibiz ini.',
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
                      'Surat Permintaan Ganti Nomor Layanan Indibiz ini merupakan satu kesatuan yang tidak terpisahkan dengan Kontrak Berlangganan yang telah ditandatanganinya PT Telkom Indonesia (Persero) Tbk dengan PELANGGAN.',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // 7. DUA KOLOM TANDA TANGAN (SEJAJAR & RUANG MATERAI / TTD LEGA)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Kolom Kiri: Penanggung Jawab Telkom
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        // Spacer transparan agar sejajar dengan baris tanggal di sebelah kanan
                        pw.SizedBox(height: 11), 
                        pw.Text(
                          'Penanggung Jawab Telkom',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.SizedBox(
                          height: 55,
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              if (data.tampilkanTtdTelkom && ttdImage != null)
                                pw.Image(
                                  ttdImage,
                                  height: 38,
                                  fit: pw.BoxFit.contain,
                                )
                              else
                                pw.SizedBox(height: 38),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '(${data.namaPjTelkom})',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),

                  // Kolom Kanan: Pelanggan (Dengan Kotak Materai Fisik 10.000)
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
                            height: 55, // Ruang lega pas untuk penempelan materai fisik asli
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Container(
                                  width: 34,
                                  height: 30,
                                  alignment: pw.Alignment.center,
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: PdfColors.grey700, width: 0.8),
                                  ),
                                  child: pw.Column(
                                    mainAxisAlignment: pw.MainAxisAlignment.center,
                                    children: [
                                      pw.Text(
                                        'Materai',
                                        style: const pw.TextStyle(
                                            fontSize: 6.5, color: PdfColors.black),
                                      ),
                                      pw.Text(
                                        '10.000',
                                        style: const pw.TextStyle(
                                            fontSize: 6.5, color: PdfColors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.Text(
                          '(${data.namaPelanggan})',
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