import 'package:flutter/material.dart';

class KlasifikasiSeismikPage extends StatefulWidget {
  const KlasifikasiSeismikPage({super.key});

  @override
  State<KlasifikasiSeismikPage> createState() => _KlasifikasiSeismikPageState();
}

class _KlasifikasiSeismikPageState extends State<KlasifikasiSeismikPage> {
  final _formKey = GlobalKey<FormState>();
  final _magnitudoController = TextEditingController();
  final _kedalamanController = TextEditingController();
  final _lintangController = TextEditingController();
  final _bujurController = TextEditingController();

  String? _hasilKlasifikasi;
  Color _warnaKlasifikasi = Colors.grey;
  String _deskripsiKlasifikasi = '';

  @override
  void dispose() {
    _magnitudoController.dispose();
    _kedalamanController.dispose();
    _lintangController.dispose();
    _bujurController.dispose();
    super.dispose();
  }

  void _hitungKlasifikasi() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      double magnitudo = double.parse(
        _magnitudoController.text.replaceAll(',', '.'),
      );
      double kedalaman = double.parse(
        _kedalamanController.text.replaceAll(',', '.'),
      );

      // Simulasi Model Support Vector Machine (SVM)
      // Pada implementasi sebenarnya, input (magnitudo, kedalaman, lokasi)
      // akan diforward ke model machine learning / API Python.
      // Untuk versi demo, kita gunakan rule-based sederhana mendekati SVM.
      
      double skorSVM = 0;
      
      // Bobot magnitudo
      if (magnitudo >= 6.5) {
        skorSVM += 50;
      } else if (magnitudo >= 5.0) skorSVM += 30;
      else skorSVM += 10;
      
      // Bobot kedalaman (semakin dangkal, semakin berbahaya)
      if (kedalaman <= 30) {
        skorSVM += 40;
      } else if (kedalaman <= 70) skorSVM += 20;
      else skorSVM += 5;

      setState(() {
        if (skorSVM >= 80) {
          _hasilKlasifikasi = 'Tinggi';
          _warnaKlasifikasi = Colors.red;
          _deskripsiKlasifikasi =
              'Kerentanan seismik tinggi. Sangat berpotensi menimbulkan kerusakan struktural bangunan dan membahayakan keselamatan.';
        } else if (skorSVM >= 50) {
          _hasilKlasifikasi = 'Sedang';
          _warnaKlasifikasi = Colors.orange;
          _deskripsiKlasifikasi =
              'Kerentanan seismik sedang. Berpotensi menimbulkan kerusakan ringan hingga sedang pada bangunan.';
        } else {
          _hasilKlasifikasi = 'Rendah';
          _warnaKlasifikasi = Colors.green;
          _deskripsiKlasifikasi =
              'Kerentanan seismik rendah. Guncangan umumnya tidak menimbulkan kerusakan yang signifikan.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Klasifikasi Kerentanan Seismik'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.memory, color: Color(0xFF1976D2), size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Support Vector Machine (SVM)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Model memproses data magnitudo, kedalaman, dan episenter secara otomatis menganalisis pola spatial gempabumi.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E88E5),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Parameter Gempa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _magnitudoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Magnitudo',
                          hintText: 'Contoh: 5.6',
                          prefixIcon: const Icon(
                            Icons.waves,
                            color: Color(0xFF42A5F5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap masukkan magnitudo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _kedalamanController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Kedalaman (km)',
                          hintText: 'Contoh: 30',
                          prefixIcon: const Icon(
                            Icons.arrow_downward,
                            color: Color(0xFFEF5350),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap masukkan kedalaman';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _lintangController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Lintang Episenter',
                                hintText: 'Contoh: -6.82',
                                prefixIcon: const Icon(
                                  Icons.language,
                                  color: Color(0xFF66BB6A),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _bujurController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Bujur Episenter',
                                hintText: 'Contoh: 107.60',
                                prefixIcon: const Icon(
                                  Icons.explore,
                                  color: Color(0xFFA1887F),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Harap diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _hitungKlasifikasi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Klasifikasikan (SVM)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_hasilKlasifikasi != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _warnaKlasifikasi.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _warnaKlasifikasi, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: _warnaKlasifikasi,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hasil Prediksi Kerentanan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hasilKlasifikasi!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _warnaKlasifikasi,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _deskripsiKlasifikasi,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF424242),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
