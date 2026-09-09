import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/wms_model.dart';

class WmsPdfService {
  static Future<Uint8List> generatePdf(WmsModel data) async {
    final pdf = pw.Document();

    String nomorSuratFinal = data.nomorSuratManual.replaceAll('{NAMA TELDA}', data.namaTelda.toUpperCase());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        build: (pw.Context context) {
          return [
            // Header / Judul
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'SURAT PERNYATAAN BERLANGGANAN',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'WIFI MANAGED SERVICE (WMS)',
                    style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'No : $nomorSuratFinal',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            pw.Text('Saya yang bertanda tangan di bawah ini,', style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 6),

            // Identitas Pelanggan WMS
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10),
              child: pw.Column(
                children: [
                  _buildDataRow('Nama Lengkap Pelanggan', data.namaPelanggan),
                  _buildDataRow('NIK (KTP)', data.nikPelanggan),
                  _buildDataRow('Alamat Lengkap Pemasangan', data.alamatPemasangan),
                  _buildDataRow('Nomor HP Aktif', data.nomorHp),
                  _buildDataRow('Nomor Layanan WMS', data.nomorLayananWms),
                  _buildDataRow('Paket WMS', data.paketWms),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            pw.Text(
              'Dengan ini secara sadar dan tanpa tekanan menyatakan akan mematuhi ketentuan berikut:',
              style: const pw.TextStyle(fontSize: 8.5),
            ),
            pw.SizedBox(height: 6),

            // Poin-poin Pernyataan (1 - 10)
            _buildPoinList(
              1,
              'Mempergunakan layanan WMS sesuai dengan ketentuan di dalam Kontrak Berlangganan Layanan WMS, berikut lampiran dan perubahannya.',
            ),
            _buildPoinList(
              2,
              'Tidak melakukan penjualan kembali bandwidth layanan WMS baik sebagian maupun keseluruhan.',
            ),
            _buildPoinList(
              3,
              'Tidak melakukan pemindahan, perubahan, dan/atau penyalahgunaan apapun terhadap jaringan, perangkat dan layanan WMS tanpa sepengetahuan dan izin dari Telkom.',
            ),
            _buildPoinList(
              4,
              'Melakukan pembayaran setiap bulan sebelum tanggal 20. Jika lebih dari tanggal 20 belum membayar, maka akan dilakukan isolir layanan.',
            ),
            _buildPoinList(
              5,
              'Tidak melakukan modifikasi layanan WMS dari jasa tidak resmi apapun dari pihak manapun diluar mitra resmi Telkom. Jika melanggar, Saya yang bertanda tangan di bawah ini bersedia menanggung dan membayar LUNAS semua tunggakan tagihan yang muncul beserta sanksi-nya, sesuai dengan kebijakan Telkom dengan memperhatikan penggunaan bandwidth di sisi pelanggan yang tercatat oleh Telkom.',
            ),
            _buildPoinList(
              6,
              'Saya yang bertanda tangan bersedia menanggung semua ganti rugi, sanksi pidana, sanksi administratif akibat pelaksanaan penjualan kembali bandwidth secara illegal dan penyalahgunaan layanan WMS untuk kegiatan yang bertentangan dengan kontrak berlangganan dan Peraturan Perundang-undangan yang berlaku.',
            ),
            _buildPoinList(
              7,
              'Berlangganan layanan WMS dengan minimal jangka waktu 12 (dua belas) bulan sejak layanan Indibiz ber-status Aktif. Apabila Saya yang bertanda tangan di bawah ini melakukan pengajuan pemutusan layanan untuk berhenti berlangganan layanan Indibiz sebelum 12 (dua belas) bulan berlangganan, maka Saya yang bertanda tangan di bawah ini bersedia dikenakan dan membayar denda pengakhiran senilai Rp1.000.000.- (satu juta Rupiah).',
            ),
            _buildPoinList(
              8,
              'Saya yang bertanda-tangan di bawah ini bersedia membayar lunas tagihan yang muncul jika berhenti berlangganan layanan Indibiz sesuai kebijakan yang berlaku dari Telkom.',
            ),
            _buildPoinList(
              9,
              'Demikian Surat Pernyataan ini dibuat dengan sebenarnya, secara sadar, dan tanpa tekanan. Surat Pernyataan ini merupakan satu kesatuan yang tidak terpisahkan dengan Kontrak Berlangganan Layanan WMS.',
            ),
            _buildPoinList(
              10,
              'Saya setuju dengan syarat dan ketentuan yang berlaku di dalam Surat Pernyataan ini dan Kontrak Berlangganan Layanan WMS.',
            ),
            pw.SizedBox(height: 24),

            // Tanda Tangan & Kotak Materai
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      '${data.kotaLokasi}, ${data.tanggalSurat}',
                      style: const pw.TextStyle(fontSize: 8.5),
                    ),
                    pw.SizedBox(height: 4),
                    // Kotak Materai 10rb
                    pw.Container(
                      width: 55,
                      height: 42,
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.red700, width: 1),
                      ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Materai', style: pw.TextStyle(fontSize: 7, color: PdfColors.black)),
                          pw.Text('10rb', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '(${data.namaPelanggan.isEmpty ? '....................................................' : data.namaPelanggan})',
                      style: const pw.TextStyle(fontSize: 8.5),
                    ),
                    pw.Text(
                      'Pelanggan Telkom',
                      style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ];
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
            width: 140,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 8.5)),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Expanded(
            child: pw.Text(value.isEmpty ? '-' : value, style: const pw.TextStyle(fontSize: 8.5)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPoinList(int nomor, String teks) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 18,
            child: pw.Text('$nomor.', style: const pw.TextStyle(fontSize: 8.5)),
          ),
          pw.Expanded(
            child: pw.Text(
              teks,
              style: const pw.TextStyle(fontSize: 8.5),
              textAlign: pw.TextAlign.justify,
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