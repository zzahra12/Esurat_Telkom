import 'package:flutter/material.dart';
import '../models/isolir_model.dart';
import '../services/isolir_pdf_service.dart';
import 'preview_surat_page.dart';

class FormIsolirPage extends StatefulWidget {
  const FormIsolirPage({super.key});

  @override
  State<FormIsolirPage> createState() => _FormIsolirPageState();
}

class _FormIsolirPageState extends State<FormIsolirPage> {
  // Data Pelanggan
  final _namaPelangganController = TextEditingController();
  final _tipeIdentitasPelangganController = TextEditingController(text: 'KTP');
  final _nomorIdentitasPelangganController = TextEditingController();
  final _alamatPelangganController = TextEditingController();
  final _nomorLayananController = TextEditingController();
  final _atasNamaLayananController = TextEditingController(); // Ditambahkan
  final _alamatLokasiLayananController = TextEditingController(); // Ditambahkan

  // Detail Isolir
  final _durasiIsolirController = TextEditingController();
  final _tanggalIsolirController = TextEditingController();
  final _tanggalBukaIsolirController = TextEditingController();
  final _keteranganController = TextEditingController();

  // Penanggung Jawab Telkom & Checkbox TTD
  final _namaPjTelkomController = TextEditingController(text: 'Yustika Monita');
  bool _tampilkanTtdTelkom = true;

  // Penerima Kuasa (Opsional)
  final _namaKuasaController = TextEditingController();
  final _tipeIdentitasKuasaController = TextEditingController();
  final _nomorIdentitasKuasaController = TextEditingController();
  final _alamatKuasaController = TextEditingController();

  bool _isLoading = false;

  Future<void> _prosesLanjutkan() async {
    if (_namaPelangganController.text.isEmpty ||
        _alamatPelangganController.text.isEmpty ||
        _nomorIdentitasPelangganController.text.isEmpty ||
        _nomorLayananController.text.isEmpty ||
        _atasNamaLayananController.text.isEmpty ||
        _alamatLokasiLayananController.text.isEmpty ||
        _durasiIsolirController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Lengkapi Data Pelanggan, Atas Nama, Alamat Lokasi, dan Durasi Isolir!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = IsolirModel(
        namaKuasa: _namaKuasaController.text,
        alamatKuasa: _alamatKuasaController.text,
        tipeIdentitasKuasa: _tipeIdentitasKuasaController.text,
        nomorIdentitasKuasa: _nomorIdentitasKuasaController.text,
        namaPelanggan: _namaPelangganController.text,
        alamatPelanggan: _alamatPelangganController.text,
        tipeIdentitasPelanggan: _tipeIdentitasPelangganController.text,
        nomorIdentitasPelanggan: _nomorIdentitasPelangganController.text,
        nomorLayanan: _nomorLayananController.text,
        atasNamaLayanan: _atasNamaLayananController.text,
        alamatLokasiLayanan: _alamatLokasiLayananController.text,
        durasiIsolir: _durasiIsolirController.text,
        tanggalIsolir: _tanggalIsolirController.text.isEmpty
            ? '-'
            : _tanggalIsolirController.text,
        tanggalBukaIsolir: _tanggalBukaIsolirController.text.isEmpty
            ? '-'
            : _tanggalBukaIsolirController.text,
        keterangan: _keteranganController.text.isEmpty
            ? '-'
            : _keteranganController.text,
        namaPjTelkom: _namaPjTelkomController.text,
        tampilkanTtdTelkom: _tampilkanTtdTelkom,
      );

      final pdfBytes = await IsolirPdfService.generatePdf(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'Surat_Isolir_${_namaPelangganController.text.replaceAll(' ', '_')}_$timestamp.pdf';

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewSuratPage(
            jenisSurat: 'Surat Permintaan Isolir',
            pdfBytes: pdfBytes,
            fileName: fileName,
            onCetakPdf: (bytes, name) async {
              await IsolirPdfService.saveAndOpenFile(bytes, name);
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                'Data Surat Permintaan Isolir',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            const SizedBox(height: 24),

            _buildInputField(
              label: 'Nama Lengkap Pelanggan *',
              controller: _namaPelangganController,
            ),
            _buildInputField(
              label: 'Alamat Pelanggan (Sesuai KTP) *',
              controller: _alamatPelangganController,
              maxLines: 2,
            ),
            _buildInputField(
              label: 'Tipe Identitas *',
              controller: _tipeIdentitasPelangganController,
            ),
            _buildInputField(
              label: 'Nomor Identitas (NIK) *',
              controller: _nomorIdentitasPelangganController,
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              label: 'Nomor Layanan *',
              controller: _nomorLayananController,
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              label: 'Atas Nama Layanan (Nama Kantor / Usaha / Sekolah) *',
              controller: _atasNamaLayananController,
            ),
            _buildInputField(
              label: 'Alamat Lokasi Layanan (Pemasangan) *',
              controller: _alamatLokasiLayananController,
              maxLines: 2,
            ),

            const SizedBox(height: 12),
            const Text('DETAIL WAKTU ISOLIR',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF140F47))),
            const SizedBox(height: 12),

            _buildInputField(
              label: 'Durasi Isolir *',
              controller: _durasiIsolirController,
            ),
            _buildInputField(
              label: 'Tanggal Mulai Isolir *',
              controller: _tanggalIsolirController,
            ),
            _buildInputField(
              label: 'Tanggal Buka Isolir *',
              controller: _tanggalBukaIsolirController,
            ),
            _buildInputField(
              label: 'Keterangan / Alasan (Opsional)',
              controller: _keteranganController,
              maxLines: 2,
            ),

            _buildInputField(
              label: 'Nama Penanggung Jawab Telkom',
              controller: _namaPjTelkomController,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _tampilkanTtdTelkom,
                  activeColor: const Color(0xFF140F47),
                  onChanged: (bool? value) {
                    setState(() {
                      _tampilkanTtdTelkom = value ?? true;
                    });
                  },
                ),
                const Text(
                  'Tempelkan Tanda Tangan Telkom',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ExpansionTile(
              title: const Text(
                'Isi Data Pemberi Kuasa (Opsional)',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              children: [
                _buildInputField(
                  label: 'Nama Pemberi Kuasa',
                  controller: _namaKuasaController,
                ),
                _buildInputField(
                  label: 'Tipe Identitas Pemberi Kuasa',
                  controller: _tipeIdentitasKuasaController,
                ),
                _buildInputField(
                  label: 'Nomor Identitas Kuasa',
                  controller: _nomorIdentitasKuasaController,
                ),
                _buildInputField(
                  label: 'Alamat Pemberi Kuasa',
                  controller: _alamatKuasaController,
                  maxLines: 2,
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF140F47),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _prosesLanjutkan,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Lanjutkan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}