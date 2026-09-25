import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/kbm_model.dart';

class KbmPdfService {
  static Future<Uint8List> generatePdf(KbmModel data) async {
    final pdf = pw.Document();

    // 🖼️ LOAD LOGO & ASSET TANDA TANGAN
    pw.MemoryImage? logoTelkom;
    pw.MemoryImage? logoSda;
    pw.MemoryImage? ttdPengaju;
    pw.MemoryImage? ttdLukman;

    // Memuat logo Telkom (kanan)
    try {
      final logoBytes = await rootBundle.load('assets/images/logo-telkom.png');
      logoTelkom = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    // Memuat logo IMPACT/SDA (kiri dari Telkom)
    try {
      final sdaBytes = await rootBundle.load('assets/images/IMPACT.png');
      logoSda = pw.MemoryImage(sdaBytes.buffer.asUint8List());
    } catch (_) {}

    // Memuat TTD Pak Lukman (Tetap - Kanan)
    try {
      final lukmanBytes = await rootBundle.load('assets/images/ttd-pak Lukman.jpeg');
      ttdLukman = pw.MemoryImage(lukmanBytes.buffer.asUint8List());
    } catch (_) {}

    // 📌 DATA DINAMIS 3 ORANG PENANDATANGAN (Sesuai dengan referensi data Anda)
    String assetTtdKiri = 'assets/images/ttd-Ericha.jpeg';
    String nikPengaju = 'NIK.405595';
    String jabatanPengaju = 'ACCOUNT MANAGER GS';
    String lokasiPengaju = 'BANYUWANGI';

    String namaLower = data.namaPengaju.toLowerCase();
    if (namaLower.contains('AZKI ZARKASI MUHAMMAD')) {
      assetTtdKiri = 'assets/images/ttd-Azki.jpeg';
      nikPengaju = 'NIK.405591';
      jabatanPengaju = 'ACCOUNT MANAGER GS';
      lokasiPengaju = 'BANYUWANGI';
    } else if (namaLower.contains('YUSTIKA MONITA')) {
      assetTtdKiri = 'assets/images/ttd-telkom.png'; // Atau sesuaikan dengan file TTD Yustika jika ada
      nikPengaju = 'NIK.980213';
      jabatanPengaju = 'OFF SO & CC';
      lokasiPengaju = 'BANYUWANGI';
    } else {
      assetTtdKiri = 'assets/images/ttd-Ericha.jpeg';
      nikPengaju = 'NIK.405595';
      jabatanPengaju = 'ACCOUNT MANAGER GS';
      lokasiPengaju = 'BANYUWANGI';
    }

    try {
      final pengajuBytes = await rootBundle.load(assetTtdKiri);
      ttdPengaju = pw.MemoryImage(pengajuBytes.buffer.asUint8List());
    } catch (_) {}

    const double margin1_27cm = 36.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(margin1_27cm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER LOGO (Kanan Atas - Logo Impact/SDA di kiri, Telkom di kanan)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoSda != null)
                    pw.SizedBox(
                      width: 150,
                      height: 70,
                      child: pw.Image(logoSda, fit: pw.BoxFit.contain),
                    ),
                  if (logoSda != null && logoTelkom != null)
                    pw.SizedBox(width: 12),
                  if (logoTelkom != null)
                    pw.SizedBox(
                      width: 125,
                      height: 55,
                      child: pw.Image(logoTelkom, fit: pw.BoxFit.contain),
                    ),
                ],
              ),
              pw.SizedBox(height: 15),

              // JUDUL SURAT
              pw.Center(
                child: pw.Text(
                  'SURAT TUGAS PENGGUNAAN KBM DAN BBM HARIAN',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              // DETAIL UTAMA SURAT
              _buildRow('Nama', data.namaPengaju),
              _buildRow('Unit / Loker', data.unitLoker),
              _buildRow('Lokasi Tujuan', data.lokasiTujuan),
              _buildRow('Jenis BBM', data.jenisBbm),
              pw.SizedBox(height: 10),

              // DESKRIPSI KEGIATAN
              pw.Text(
                'Deskripsi Kegiatan',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                constraints: const pw.BoxConstraints(minHeight: 120),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.8),
                ),
                child: pw.Text(
                  data.deskripsiKegiatan,
                  style: const pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.justify,
                ),
              ),
              pw.SizedBox(height: 20),

              // TANGGAL & TANDA TANGAN
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Kolom Kiri: Yang Mengajukan (Dinamis: Ericha / Azki / Yustika)
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${data.kotaLokasi}, ${data.tanggalSurat}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Yang mengajukan,',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(height: 4),
                        pw.SizedBox(
                          height: 60,
                          child: ttdPengaju != null
                              ? pw.Image(ttdPengaju, height: 50, fit: pw.BoxFit.contain)
                              : pw.SizedBox(),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(nikPengaju, style: const pw.TextStyle(fontSize: 12)),
                        pw.Text(
                          data.namaPengaju.toUpperCase(),
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(jabatanPengaju, style: const pw.TextStyle(fontSize: 12)),
                        pw.Text(lokasiPengaju, style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),

                  // Spasi tengah
                  pw.SizedBox(width: 40),

                  // Kolom Kanan: Yang Menyetujui (Pak Lukman)
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 18), 
                        pw.Text(
                          'Yang menyetujui,',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.SizedBox(height: 4),
                        pw.SizedBox(
                          height: 60,
                          child: ttdLukman != null
                              ? pw.Image(ttdLukman, height: 50, fit: pw.BoxFit.contain)
                              : pw.SizedBox(),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('NIK. 790032', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text(
                          'MUHAMMAD LUKMAN HAKIM',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('HEAD OF TELKOM DAERAH', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('BANYUWANGI', style: const pw.TextStyle(fontSize: 12)),
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
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 12)),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? '-' : value,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
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