import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'surat_selesai_page.dart';

class PreviewSuratPage extends StatelessWidget {
  final String jenisSurat;
  final Uint8List pdfBytes;
  final String fileName;
  final Future<void> Function(Uint8List bytes, String fileName) onCetakPdf;

  const PreviewSuratPage({
    super.key,
    required this.jenisSurat,
    required this.pdfBytes,
    required this.fileName,
    required this.onCetakPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Preview Surat',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Header Jenis Surat
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.black),
                children: [
                  const TextSpan(text: 'Jenis Surat : '),
                  TextSpan(
                    text: jenisSurat,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Area Preview PDF
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: const Color(0xFFDCDCDC),
                  child: PdfPreview(
                    build: (format) => pdfBytes,
                    useActions: false, // Menyembunyikan toolbar bawaan
                    allowPrinting: false,
                    allowSharing: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Edit Data
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDCDCDC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context), // Kembali ke Form untuk Edit
                child: const Text(
                  'Edit Data',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Cetak Surat (PDF)
            // Tombol Cetak Surat (PDF)
SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF140F47),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: () {
      // 🚀 Pindah ke Halaman Surat Anda Selesai
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuratSelesaiPage(
            pdfBytes: pdfBytes,
            fileName: fileName,
          ),
        ),
      );
    },
    child: const Text(
      'Cetak Surat (PDF)',
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}