import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kbm_model.dart';
import '../services/kbm_pdf_service.dart';
import 'preview_surat_page.dart';

class KbmFormView extends StatefulWidget {
  const KbmFormView({Key? key}) : super(key: key);

  @override
  State<KbmFormView> createState() => _KbmFormViewState();
}

class _KbmFormViewState extends State<KbmFormView> {
  final _formKey = GlobalKey<FormState>();

  String _selectedPengaju = 'Ericha Septyan Dinata';
  final List<String> _daftarPengaju = [
    'Ericha Septyan Dinata',
    'Azki Zarkasi Muhammad', // 👈 Nama lengkap Azki
    'Yustika Monita',          // 👈 Nama lengkap Yustika
  ];

  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _bbmController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  
  final TextEditingController _kotaController = TextEditingController(text: 'Banyuwangi');
  final TextEditingController _tanggalController = TextEditingController(
    text: DateFormat('dd/MM/yyyy', 'id_ID').format(DateTime.now()),
  );

  bool _isLoading = false;

  Future<void> _lanjutkanKePreview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final model = KbmModel(
        namaPengaju: _selectedPengaju,
        unitLoker: _unitController.text,
        lokasiTujuan: _lokasiController.text,
        jenisBbm: _bbmController.text,
        deskripsiKegiatan: _deskripsiController.text,
        kotaLokasi: _kotaController.text,
        tanggalSurat: _tanggalController.text,
      );

      final pdfBytes = await KbmPdfService.generatePdf(model);

      if (!mounted) return;

      final fileName = 'Surat_Tugas_KBM_${_selectedPengaju.replaceAll(' ', '_')}.pdf';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewSuratPage(
            jenisSurat: 'Surat Tugas KBM & BBM',
            pdfBytes: pdfBytes,
            fileName: fileName,
            onCetakPdf: (bytes, name) async {
              await KbmPdfService.saveAndOpenFile(bytes, name);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat preview: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Form Surat Tugas KBM & BBM',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedPengaju,
                decoration: InputDecoration(
                  labelText: 'Pilih Nama Pengaju (TTD Kiri) *',
                  labelStyle: const TextStyle(color: Color(0xFF140F47), fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _daftarPengaju.map((String nama) {
                  return DropdownMenuItem<String>(
                    value: nama,
                    child: Text(nama),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedPengaju = newValue);
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: 'Unit / Loker *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
                validator: (val) => val!.isEmpty ? 'Unit tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _lokasiController,
                decoration: InputDecoration(
                  labelText: 'Lokasi Tujuan *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
                validator: (val) => val!.isEmpty ? 'Lokasi tujuan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bbmController,
                decoration: InputDecoration(
                  labelText: 'Jenis BBM *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val!.isEmpty ? 'Jenis BBM tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Kegiatan *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 4,
                validator: (val) => val!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kotaController,
                      decoration: InputDecoration(
                        labelText: 'Kota *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _tanggalController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Surat *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _lanjutkanKePreview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF140F47),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Lanjutkan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}