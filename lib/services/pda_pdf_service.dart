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
import '../models/pda_model.dart';

class PdaPdfService {
  static Future<Uint8List> generatePdf(PdaModel data) async {
    await initializeDateFormatting('id_ID', null);

    final String tanggalRealtime =
        'Banyuwangi, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}';

    // 🖼️ LOAD GAMBAR TTD TELKOM DARI ASSETS
    pw.MemoryImage? ttdImage;
    try {
      final ttdBytes = await rootBundle.load('assets/images/ttd-telkom.jpg');
      ttdImage = pw.MemoryImage(ttdBytes.buffer.asUint8List());
    } catch (_) {}

    final pdf = pw.Document();

    // Cek ketersediaan Penerima Kuasa
    final bool adaKuasa =
        (data.namaKuasa ?? '').toString().trim().isNotEmpty &&
            (data.namaKuasa ?? '').toString().trim() != '-';

    // 🔄 PEMETAAN DATA PELANGGAN UTAMA
    String atasNama = data.atasNamaLayanan.trim().isNotEmpty ? data.atasNamaLayanan : data.namaPelanggan;
    String atasAlamat = data.alamatLokasiLayanan.trim().isNotEmpty ? data.alamatLokasiLayanan : data.alamatPelanggan;
    String atasTipeId = data.tipeIdentitasPelanggan;
    String atasNoId = data.nomorIdentitasPelanggan;

    // 🔄 PEMETAAN DATA PENERIMA KUASA
    String bawahNama = adaKuasa ? (data.namaKuasa ?? '-') : '-';
    String bawahAlamat = adaKuasa ? (data.alamatKuasa ?? '-') : '-';
    String bawahTipeId = adaKuasa ? (data.tipeIdentitasKuasa ?? '-') : '-';
    String bawahNoId = adaKuasa ? (data.nomorIdentitasKuasa ?? '-') : '-';

    // Penanganan nilai opsional (jika kosong, jadikan '-')
    String telpLama = (data.nomorTeleponLama.trim().isEmpty) ? '-' : data.nomorTeleponLama;
    String telpBaru = (data.nomorTeleponBaru.trim().isEmpty) ? '-' : data.nomorTeleponBaru;
    String internetLama = (data.nomorInternetLama.trim().isEmpty) ? '-' : data.nomorInternetLama;
    String internetBaru = (data.nomorInternetBaru.trim().isEmpty) ? '-' : data.nomorInternetBaru;
    String ket = (data.keterangan.trim().isEmpty) ? '-' : data.keterangan;

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

              // 2. BAGIAN ATAS: DATA PELANGGAN
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

              // 3. BAGIAN TENGAH: DATA PENERIMA KUASA
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

              // 4. DETAIL LAYANAN
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
                    _buildRow('Atas Nama', atasNama),
                    _buildRow('Alamat', atasAlamat),
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
              pw.SizedBox(height: 8),
              pw.Text(
                'BAHWA, PELANGGAN adalah benar pihak yang berlangganan Layanan Indibiz berdasarkan Kontrak Berlangganan, dan dengan ini mengajukan permintaan Pindah Alamat Layanan Indibiz, sebagai berikut:',
                style: const pw.TextStyle(fontSize: 8.5),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 10),

              // 6. DETAIL PINDAH ALAMAT
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
                    _buildSubRow('c. Nomor Telepon Lama', telpLama),
                    _buildSubRow('d. Nomor Telepon Baru', telpBaru),
                    _buildSubRow('e. Nomor Internet Lama', internetLama),
                    _buildSubRow('f. Nomor Internet Baru', internetBaru),
                    _buildSubRow('g. Keterangan', ket),
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

              // 8. DUA KOLOM TANDA TANGAN (SEJAJAR PRESISI)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Kolom Kiri: Penanggung Jawab Telkom
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
                        pw.SizedBox(height: 4),
                        if (data.tampilkanTtdTelkom == true && ttdImage != null)
                          pw.Image(
                            ttdImage,
                            height: 38,
                            fit: pw.BoxFit.contain,
                          )
                        else
                          pw.SizedBox(height: 38),
                        pw.SizedBox(height: 6), // Jarak sebelum nama
                        pw.Text(
                          '(${data.namaPjTelkom ?? 'Yustika Monita'})',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),

                  // Kolom Kanan: Pelanggan
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
                            height: 40,
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: PdfColors.grey700, width: 0.8),
                                  ),
                                  child: pw.Column(
                                    mainAxisSize: pw.MainAxisSize.min,
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
                              ],
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 6), // Jarak sebelum nama (disamakan dengan kiri)
                        pw.Text(
                          '($atasNama)',
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