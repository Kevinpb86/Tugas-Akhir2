import 'package:flutter/material.dart';

class DeteksiAnomaliPage extends StatelessWidget {
  const DeteksiAnomaliPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Deteksi Anomali Gempa'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: const SizedBox(), // Halaman dikosongkan sesuai permintaan
    );
  }
}
