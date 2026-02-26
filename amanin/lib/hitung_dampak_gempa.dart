import 'package:flutter/material.dart';

class HitungDampakGempaPage extends StatefulWidget {
  const HitungDampakGempaPage({super.key});

  @override
  State<HitungDampakGempaPage> createState() => _HitungDampakGempaPageState();
}

class _HitungDampakGempaPageState extends State<HitungDampakGempaPage> {
  final _formKey = GlobalKey<FormState>();
  final _magnitudoController = TextEditingController();
  final _jarakController = TextEditingController();
  String _jenisTanah = 'Tanah Sedang';

  final List<String> _kategoriTanah = [
    'Batuan Keras',
    'Tanah Keras',
    'Tanah Sedang',
    'Tanah Lunak',
  ];

  String? _hasilDampak;
  Color _warnaDampak = Colors.grey;
  String _deskripsiDampak = '';
  String _skalaMMI = '';

  @override
  void dispose() {
    _magnitudoController.dispose();
    _jarakController.dispose();
    super.dispose();
  }

  void _hitungDampak() {
    if (_formKey.currentState!.validate()) {
      // Hilangkan keyboard
      FocusScope.of(context).unfocus();

      double magnitudo = double.parse(
        _magnitudoController.text.replaceAll(',', '.'),
      );
      double jarak = double.parse(_jarakController.text.replaceAll(',', '.'));

      // Hitungan simulasi sederhana
      double factorTanah = 1.0;
      if (_jenisTanah == 'Tanah Lunak') factorTanah = 1.5;
      if (_jenisTanah == 'Tanah Keras') factorTanah = 0.9;
      if (_jenisTanah == 'Batuan Keras') factorTanah = 0.7;

      // Formula skala dampak
      double skorDampak =
          (magnitudo * 15) / (jarak > 0 ? jarak : 1) * factorTanah;

      setState(() {
        if (skorDampak < 0.5) {
          _hasilDampak = 'Tidak Terasa';
          _warnaDampak = Colors.green;
          _deskripsiDampak =
              'Guncangan umumnya tidak terasa oleh manusia, kecuali dalam keadaan luar biasa.';
          _skalaMMI = 'I - II MMI';
        } else if (skorDampak < 2.5) {
          _hasilDampak = 'Ringan';
          _warnaDampak = Colors.lightBlue;
          _deskripsiDampak =
              'Dirasakan oleh beberapa orang di dalam bangunan. Benda yang digantung mungkin bergoyang.';
          _skalaMMI = 'III MMI';
        } else if (skorDampak < 5.0) {
          _hasilDampak = 'Sedang';
          _warnaDampak = Colors.orange;
          _deskripsiDampak =
              'Dirasakan banyak orang. Jendela, pintu bergetar. Dinding terkadang berbunyi.';
          _skalaMMI = 'IV - V MMI';
        } else if (skorDampak < 10.0) {
          _hasilDampak = 'Kuat';
          _warnaDampak = Colors.deepOrange;
          _deskripsiDampak =
              'Orang-orang bisa panik berlari keluar. Terjadi kerusakan ringan pada bangunan.';
          _skalaMMI = 'VI - VII MMI';
        } else {
          _hasilDampak = 'Sangat Kuat / Merusak';
          _warnaDampak = Colors.red;
          _deskripsiDampak =
              'Kerusakan pada struktur bangunan, roboh, dan membahayakan keselamatan.';
          _skalaMMI = 'VIII+ MMI';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Hitung Dampak Guncangan'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Estimasi Dampak Guncangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Alat ini menggunakan formula simulasi sederhana untuk mengestimasi tingkat kekuatan guncangan yang dirasakan berdasarkan parameter gempa.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  height: 1.5,
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
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _magnitudoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Magnitudo Gempa (M)',
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
                          if (double.tryParse(value.replaceAll(',', '.')) ==
                              null) {
                            return 'Harap masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jarakController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Jarak dari Pusat Gempa (km)',
                          hintText: 'Contoh: 30',
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFFEF5350),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harap masukkan jarak';
                          }
                          if (double.tryParse(value.replaceAll(',', '.')) ==
                              null) {
                            return 'Harap masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _jenisTanah,
                        decoration: InputDecoration(
                          labelText: 'Kondisi Tanah Sekitar',
                          prefixIcon: const Icon(
                            Icons.landscape_outlined,
                            color: Color(0xFF66BB6A),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _kategoriTanah.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _jenisTanah = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _hitungDampak,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Hitung Dampak',
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
              if (_hasilDampak != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _warnaDampak.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _warnaDampak, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: _warnaDampak,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tingkat Guncangan: $_hasilDampak',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _warnaDampak,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estimasi Skala: $_skalaMMI',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _deskripsiDampak,
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
