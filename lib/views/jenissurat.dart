import 'package:flutter/material.dart';
// 1. Import kedua file form yang sudah kita buat
import 'form_buka_isolir_page.dart'; 
import 'form_pda_page.dart';    
import 'form_gno_page.dart';    
import 'form_bna_page.dart'; 
import 'form_do_page.dart';
import 'form_isolir_page.dart';
import 'form_upgrade_downgrade_page.dart';

class PilihJenisSuratScreen extends StatelessWidget {
  const PilihJenisSuratScreen({super.key});

  final List<String> jenisSuratList = const [
    'Surat Permintaan Buka Isolir',
    'Surat PDA',
    'Surat GNO',
    'Surat BNA',
    'Surat Permintaan DO',
    'Surat Permintaan Isolir',
    'Surat Upgrade-Downgrade',
  ];

  // 2. Perbarui fungsi navigasi _pilihSurat
  void _pilihSurat(BuildContext context, String jenisSurat) {
  if (jenisSurat == 'Surat Permintaan Buka Isolir') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormBukaIsolirPage()),
    );
  } else if (jenisSurat == 'Surat PDA') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormPdaPage()),
    );
  } else if (jenisSurat == 'Surat GNO') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormGnoPage()),
    );
  } else if (jenisSurat == 'Surat BNA') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormBnaPage()),
    );
  } else if (jenisSurat == 'Surat Permintaan DO') {
    // 👈 Tambahkan kondisi ini
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormDoPage()),
    );
  } else if (jenisSurat == 'Surat Permintaan Isolir') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormIsolirPage()),
    );
  } else if (jenisSurat == 'Surat Upgrade-Downgrade') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FormUpgradeDowngradePage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Form untuk $jenisSurat belum tersedia')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pilih Jenis Surat',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: jenisSuratList.length,
        itemBuilder: (context, index) {
          final title = jenisSuratList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDCDCDC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 40,
                  color: Color(0xFF140F47),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF140F47),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _pilihSurat(context, title),
                        child: const Text(
                          'Pilih',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}