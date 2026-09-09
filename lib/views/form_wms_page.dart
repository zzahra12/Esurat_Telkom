import 'package:flutter/material.dart';
import '../models/wms_model.dart';
import '../services/wms_pdf_service.dart';
import 'preview_surat_page.dart';

class FormWmsPage extends StatefulWidget {
  const FormWmsPage({super.key});

  @override
  State<FormWmsPage> createState() => _FormWmsPageState();
}

class _FormWmsPageState extends State<FormWmsPage> {
  final _namaTeldaController = TextEditingController(text: 'BANYUWANGI');
  final _tanggalSuratController = TextEditingController(
    text: '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
  );
  final _nomorSuratManualController = TextEditingController(text: 'TEL. XXXX/YN000/T3W-0B0L0000');
  final _nomorLayananWmsController = TextEditingController();
  final _paketWmsController = TextEditingController();
  
  final _namaPelangganController = TextEditingController();
  final _nikPelangganController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _alamatPemasanganController = TextEditingController();
  final _kotaLokasiController = TextEditingController(text: 'Banyuwangi');

  bool _isLoading = false;

  Future<void> _prosesCetakPdf() async {
    if (_nomorLayananWmsController.text.isEmpty ||
        _paketWmsController.text.isEmpty ||
        _namaPelangganController.text.isEmpty ||
        _nikPelangganController.text.isEmpty ||
        _nomorHpController.text.isEmpty ||
        _alamatPemasanganController.text.isEmpty ||
        _namaTeldaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi Semua Data Surat dan Pelanggan WMS!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = WmsModel(
        namaTelda: _namaTeldaController.text,
        tanggalSurat: _tanggalSuratController.text,
        nomorSuratManual: _nomorSuratManualController.text,
        nomorLayananWms: _nomorLayananWmsController.text,
        paketWms: _paketWmsController.text,
        namaPelanggan: _namaPelangganController.text,
        nikPelanggan: _nikPelangganController.text,
        nomorHp: _nomorHpController.text,
        alamatPemasangan: _alamatPemasanganController.text,
        kotaLokasi: _kotaLokasiController.text.isEmpty ? 'Banyuwangi' : _kotaLokasiController.text,
      );

      final pdfBytes = await WmsPdfService.generatePdf(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Surat_WMS_${_namaPelangganController.text.replaceAll(' ', '_')}_$timestamp.pdf';

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewSuratPage(
            jenisSurat: 'Surat Pernyataan Berlangganan WMS',
            pdfBytes: pdfBytes,
            fileName: fileName,
            onCetakPdf: (bytes, name) async {
              await WmsPdfService.saveAndOpenFile(bytes, name);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat preview PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF140F47),
            fontWeight: FontWeight.bold,
          ),
          alignLabelWithHint: true,
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF757575), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF140F47), width: 1.8),
          ),
        ),
      ),
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
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Surat Pernyataan Berlangganan WMS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),

            const Text('DATA SURAT & LAYANAN', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF140F47))),
            const SizedBox(height: 12),

            _buildInputField(
              label: 'Nama TELDA (Untuk No. Surat) *',
              controller: _namaTeldaController,
            ),
            _buildInputField(
              label: 'Tanggal Surat *',
              controller: _tanggalSuratController,
            ),
            _buildInputField(
              label: 'Nomor Surat WMS (Manual) *',
              controller: _nomorSuratManualController,
            ),
            _buildInputField(
              label: 'Nomor Layanan WMS *',
              controller: _nomorLayananWmsController,
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              label: 'Paket WMS *',
              controller: _paketWmsController,
            ),

            const SizedBox(height: 12),
            const Text('DATA PELANGGAN', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF140F47))),
            const SizedBox(height: 12),

            _buildInputField(
              label: 'Nama Lengkap Pelanggan *',
              controller: _namaPelangganController,
            ),
            _buildInputField(
              label: 'NIK (KTP) *',
              controller: _nikPelangganController,
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              label: 'Nomor HP Aktif *',
              controller: _nomorHpController,
              keyboardType: TextInputType.phone,
            ),
            _buildInputField(
              label: 'Alamat Lengkap Pemasangan / KTP *',
              controller: _alamatPemasanganController,
              maxLines: 2,
            ),
            _buildInputField(
              label: 'Kota Lokasi Surat (Atas Tanda Tangan)',
              controller: _kotaLokasiController,
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF140F47),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _prosesCetakPdf,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Lanjutkan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}