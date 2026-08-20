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

    // Format tanggal real-time otomatis (Contoh: Banyuwangi, 12 Agustus 2026)
    final String tanggalRealtime =
        'Banyuwangi, ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}';

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Judul Surat
              pw.Center(
                child: pw.Text(
                  'SURAT PERMINTAAN PINDAH ALAMAT LAYANAN',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              // 1. Bagian Atas: DATA PELANGGAN
pw.Text('Yang bertanda tangan di bawah ini :'),
pw.SizedBox(height: 4),
pw.Row(children: [pw.SizedBox(width: 100, child: pw.Text('Nama')), pw.Text(': ${data.namaPelanggan}')]),
pw.Row(children: [pw.SizedBox(width: 100, child: pw.Text('Alamat')), pw.Text(': ${data.alamatPelanggan}')]),
pw.Row(children: [pw.SizedBox(width: 100, child: pw.Text('Tipe Identitas')), pw.Text(': ${data.tipeIdentitasPelanggan}')]),
pw.Row(children: [pw.SizedBox(width: 100, child: pw.Text('Nomor Identitas')), pw.Text(': ${data.nomorIdentitasPelanggan}')]),

pw.SizedBox(height: 12),

// 2. Bagian Bawah: PENERIMA KUASA (Jika ada / diisi)
if (data.namaKuasa.isNotEmpty) ...[
  pw.Text('Bertindak untuk dan atas nama (Penerima Kuasa):'),
  pw.SizedBox(height: 4),
  pw.Row(children: [pw.SizedBox(width: 100, child: pw.Text('Nama')), pw.Text(': ${data.namaKuasa}')]),
  pw.Row(children: [pw.SizedBox(width: 100, child: pw.Text('Alamat')), pw.Text(': ${data.alamatKuasa}')]),
  pw.Row(children: [pw.SizedBox(width: 100, child: pw.Text('Tipe Identitas')), pw.Text(': ${data.tipeIdentitasKuasa}')]),
  pw.Row(children: [pw.SizedBox(width: 100, child: pw.Text('Nomor Identitas')), pw.Text(': ${data.nomorIdentitasKuasa}')]),
],

              // Sub 3: Layanan
              pw.Text(
                'Selanjutnya disebut sebagai "PELANGGAN", selaku pihak yang berlangganan layanan sebagai berikut:',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 3),
              _buildRow('Nomor Layanan', data.nomorLayanan),
              _buildRow('Atas Nama', data.namaPelanggan),
              _buildRow('Alamat', data.alamatPelanggan),
              pw.SizedBox(height: 12),

              // Pernyataan
              pw.Center(
                child: pw.Text(
                  'MENYATAKAN',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'BAHWA, PELANGGAN adalah benar pihak yang berlangganan Layanan Indibiz berdasarkan Kontrak Berlangganan, dan dengan ini mengajukan permintaan Pindah Alamat Layanan Indibiz, sebagai berikut:',
                style: const pw.TextStyle(fontSize: 8.5),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 10),

              // Detail Pindah Alamat
              pw.Text('Jenis Permohonan : Pindah Alamat', style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 3),
              _buildSubRow('a. Alamat Lama', data.alamatLama),
              _buildSubRow('b. Alamat Baru', data.alamatBaru),
              _buildSubRow('c. Nomor Telepon Lama', data.noTelpLama),
              _buildSubRow('d. Nomor Telepon Baru', data.noTelpBaru),
              _buildSubRow('e. Nomor Internet Lama', data.noInternetLama),
              _buildSubRow('f. Nomor Internet Baru', data.noInternetBaru),
              _buildSubRow('g. Keterangan', data.keterangan),
              pw.SizedBox(height: 10),

              // Keterangan Tambahan
              pw.Text('Keterangan Tambahan:', style: const pw.TextStyle(fontSize: 8.5)),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '1.  Permohonan ini berlaku sejak ditandatanganinya Surat Permintaan Pindah Alamat Layanan Indibiz ini.',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      '2.  Surat Permintaan Pindah Alamat Layanan Indibiz ini merupakan satu kesatuan yang tidak terpisahkan dengan Kontrak Berlangganan yang telah ditandatanganinya PT Telkom Indonesia (Persero) Tbk dengan PELANGGAN.',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // 📍 TANGGAL REALTIME OTOMATIS DI KANAN (TANPA GARIS TITIK-TITIK)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  tanggalRealtime,
                  style: const pw.TextStyle(fontSize: 9.5),
                ),
              ),
              pw.SizedBox(height: 12),

              // Tanda Tangan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    children: [
                      pw.Text('Penanggung Jawab Telkom', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 40),
                      pw.Text('(nama)', style: const pw.TextStyle(fontSize: 8.5)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('Pelanggan', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Padding(
        padding: const pw.EdgeInsets.only(right: 25.0), // Geser sedikit ke kiri
        child: pw.SizedBox(
          height: 28, // Memberikan jarak spasi area tanda tangan
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Materai',
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
              ),
              pw.Text(
                '10.000',
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ),
      pw.SizedBox(height: 6),
                      pw.Text('(${data.namaPelanggan})', style: const pw.TextStyle(fontSize: 8.5)),
                    ],
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
          pw.SizedBox(width: 120, child: pw.Text(label, style: const pw.TextStyle(fontSize: 8.5))),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 8.5))),
        ],
      ),
    );
  }

  static pw.Widget _buildSubRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 150, child: pw.Text(label, style: const pw.TextStyle(fontSize: 8.5))),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 8.5))),
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