import 'package:flutter/material.dart';
import '../models/upgrade_downgrade_model.dart';
import '../services/upgrade_downgrade_pdf_service.dart';
import 'preview_surat_page.dart';

class FormUpgradeDowngradePage extends StatefulWidget {
  const FormUpgradeDowngradePage({super.key});

  @override
  State<FormUpgradeDowngradePage> createState() =>
      _FormUpgradeDowngradePageState();
}

class _FormUpgradeDowngradePageState extends State<FormUpgradeDowngradePage> {
  // Data Pelanggan
  final _namaPelangganController = TextEditingController();
  final _tipeIdentitasPelangganController = TextEditingController(text: 'KTP');
  final _nomorIdentitasPelangganController = TextEditingController();
  final _alamatPelangganController = TextEditingController();
  final _nomorLayananController = TextEditingController();

  // Detail Upgrade / Downgrade
  String _tipeModifikasi = 'UPGRADE'; // Default UPGRADE
  final _namaTransaksiController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _tagihanController = TextEditingController();
  final _keteranganTambahanController = TextEditingController();

  // Penerima Kuasa (Opsional)
  final _namaKuasaController = TextEditingController();
  final _tipeIdentitasKuasaController = TextEditingController();
  final _nomorIdentitasKuasaController = TextEditingController();
  final _alamatKuasaController = TextEditingController();

  bool _isLoading = false;

  Future<void> _prosesLanjutkan() async {
    if (_namaPelangganController.text.isEmpty ||
        _nomorIdentitasPelangganController.text.isEmpty ||
        _nomorLayananController.text.isEmpty ||
        _namaTransaksiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Lengkapi Data Pelanggan, Nomor Layanan, dan Nama Transaksi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = UpgradeDowngradeModel(
        namaKuasa: _namaKuasaController.text,
        alamatKuasa: _alamatKuasaController.text,
        tipeIdentitasKuasa: _tipeIdentitasKuasaController.text,
        nomorIdentitasKuasa: _nomorIdentitasKuasaController.text,
        namaPelanggan: _namaPelangganController.text,
        alamatPelanggan: _alamatPelangganController.text,
        tipeIdentitasPelanggan: _tipeIdentitasPelangganController.text,
        nomorIdentitasPelanggan: _nomorIdentitasPelangganController.text,
        nomorLayanan: _nomorLayananController.text,
        tipeModifikasi: _tipeModifikasi,
        namaTransaksi: _namaTransaksiController.text,
        keterangan: _keteranganController.text.isEmpty
            ? '-'
            : _keteranganController.text,
        tagihan: _tagihanController.text.isEmpty
            ? '-'
            : _tagihanController.text,
        keteranganTambahanDetail: _keteranganTambahanController.text.isEmpty
            ? '-'
            : _keteranganTambahanController.text,
      );

      // 1. Generate PDF Bytes
      final pdfBytes = await UpgradeDowngradePdfService.generatePdf(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'Surat_Modifikasi_${_namaPelangganController.text.replaceAll(' ', '_')}_$timestamp.pdf';

      if (!mounted) return;

      // 2. Navigasi ke Halaman Preview Surat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewSuratPage(
            jenisSurat: 'Surat Permintaan Modifikasi Layanan',
            pdfBytes: pdfBytes,
            fileName: fileName,
            onCetakPdf: (bytes, name) async {
              await UpgradeDowngradePdfService.saveAndOpenFile(bytes, name);
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

  // Helper Widget dengan desain Outlined Border
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
                'Data Surat Modifikasi Layanan',
                style: TextStyle(
                    fontSize: 18,
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
              label: 'Alamat Pelanggan *',
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

            const SizedBox(height: 12),
            const Text('DETAIL MODIFIKASI LAYANAN',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF140F47))),
            const SizedBox(height: 12),

            // Radio Pilihan UPGRADE / DOWNGRADE
            // Radio Pilihan UPGRADE / DOWNGRADE
const Text(
  'Tipe Permohonan',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
),
Row(
  children: [
    Expanded(
      child: RadioListTile<String>(
        contentPadding: EdgeInsets.zero, // Menghilangkan padding bawaan
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4), // Merapatkan radio button dengan teks
        title: const Text(
          'UPGRADE',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), // Ukuran font dikecilkan
        ),
        value: 'UPGRADE',
        groupValue: _tipeModifikasi,
        onChanged: (val) => setState(() => _tipeModifikasi = val!),
      ),
    ),
    Expanded(
      child: RadioListTile<String>(
        contentPadding: EdgeInsets.zero, // Menghilangkan padding bawaan
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4), // Merapatkan radio button dengan teks
        title: const Text(
          'DOWNGRADE',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), // Ukuran font dikecilkan
        ),
        value: 'DOWNGRADE',
        groupValue: _tipeModifikasi,
        onChanged: (val) => setState(() => _tipeModifikasi = val!),
      ),
    ),
  ],
),
const SizedBox(height: 12),

            _buildInputField(
              label: 'Nama Transaksi *',
              controller: _namaTransaksiController,
            ),
            _buildInputField(
              label: 'Keterangan (Opsional)',
              controller: _keteranganController,
              maxLines: 2,
            ),
            _buildInputField(
              label: 'Informasi Tagihan (Opsional)',
              controller: _tagihanController,
            ),
            _buildInputField(
              label: 'Catatan Tambahan (Opsional)',
              controller: _keteranganTambahanController,
            ),

            ExpansionTile(
              title: const Text('Isi Data Pemberi Kuasa (Opsional)',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54)),
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
                  label: 'Nomor Identitas Pemberi Kuasa',
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
                    : const Text('Lanjutkan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}