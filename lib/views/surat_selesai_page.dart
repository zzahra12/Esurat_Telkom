import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'jenissurat.dart';

class SuratSelesaiPage extends StatefulWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const SuratSelesaiPage({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  State<SuratSelesaiPage> createState() => _SuratSelesaiPageState();
}

class _SuratSelesaiPageState extends State<SuratSelesaiPage> {
  bool _isDownloading = false;
  bool _isSharing = false;

  // 📥 Fungsi Unduh PDF
  Future<void> _unduhPdf() async {
    setState(() => _isDownloading = true);
    try {
      if (kIsWeb) {
        await Printing.sharePdf(bytes: widget.pdfBytes, filename: widget.fileName);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${widget.fileName}');
        await file.writeAsBytes(widget.pdfBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF berhasil diunduh ke: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Membuka file PDF otomatis setelah diunduh
        await OpenFile.open(file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  // 📤 Fungsi Bagikan Surat (Support Telegram, WhatsApp, dll)
  Future<void> _bagikanSurat() async {
    setState(() => _isSharing = true);
    try {
      await Printing.sharePdf(
        bytes: widget.pdfBytes,
        filename: widget.fileName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan surat: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  // 🏠 Fungsi Kembali ke Dashboard (Jenis Surat)
  void _kembaliKeDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PilihJenisSuratScreen()),
      (route) => false, // Menghapus tumpukan halaman form sebelumnya
    );
  }

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
          'Surat Anda Selesai',
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
          children: [
            const SizedBox(height: 10),

            // Icon Ilustrasi Amplop Centang
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          size: 64,
                          color: Color(0xFF26A69A),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.check_circle,
                          color: Color(0xFF2E7D32),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Surat Anda Selesai',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Container Grey Placeholder / Preview Ringkas
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFDCDCDC),
                  child: PdfPreview(
                    build: (format) => widget.pdfBytes,
                    useActions: false,
                    allowPrinting: false,
                    allowSharing: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Unduh PDF
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
                onPressed: _isDownloading ? null : _unduhPdf,
                child: _isDownloading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Unduh PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Bagikan Surat
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
                onPressed: _isSharing ? null : _bagikanSurat,
                child: _isSharing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Bagikan Surat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Text Button Kembali ke Dashboard
            TextButton(
              onPressed: _kembaliKeDashboard,
              child: const Text(
                'Kembali ke Dashboard',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}