import 'package:flutter/material.dart';
import 'services/bmkg_service.dart';
import 'services/ml_service.dart';

class DeteksiAnomaliPage extends StatefulWidget {
  const DeteksiAnomaliPage({super.key});

  @override
  State<DeteksiAnomaliPage> createState() => _DeteksiAnomaliPageState();
}

class _DeteksiAnomaliPageState extends State<DeteksiAnomaliPage> {
  List<GempaModel> _gempaList = [];
  bool _isLoadingList = true;
  String? _errorList;

  // Hasil deteksi per gempa (index -> hasil)
  final Map<int, AnomalyPredictionModel?> _hasilMap = {};
  final Map<int, bool> _loadingMap = {};

  @override
  void initState() {
    super.initState();
    _fetchGempa();
  }

  Future<void> _fetchGempa() async {
    setState(() {
      _isLoadingList = true;
      _errorList = null;
    });
    try {
      final list = await BmkgService.fetchEarthquakeList();
      setState(() => _gempaList = list);
    } catch (e) {
      setState(() => _errorList = e.toString());
    } finally {
      setState(() => _isLoadingList = false);
    }
  }

  Future<void> _deteksi(int index, GempaModel gempa) async {
    setState(() => _loadingMap[index] = true);
    try {
      final lat = double.tryParse(gempa.lintang.replaceAll(' LU', '').replaceAll(' LS', '').replaceAll(',', '.')) ?? 0.0;
      final lon = double.tryParse(gempa.bujur.replaceAll(' BT', '').replaceAll(' BB', '').replaceAll(',', '.')) ?? 0.0;
      final depth = double.tryParse(gempa.kedalaman.replaceAll(' Km', '').replaceAll(' km', '').replaceAll(',', '.')) ?? 10.0;

      // Kolom gap, dmin, nst tidak ada di BMKG → pakai nilai rata-rata dataset training
      final hasil = await MlService.predictAnomali(
        latitude: lat,
        longitude: lon,
        depth: depth,
        gap: 105.53,
        dmin: 2.21,
        nst: 33.0,
        bulan: DateTime.now().month,
        jam: DateTime.now().hour,
      );

      setState(() => _hasilMap[index] = hasil);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loadingMap[index] = false);
    }
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchGempa,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Color(0xFF388E3C), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pilih salah satu gempa dari daftar berikut untuk mendeteksi apakah gempa tersebut merupakan anomali seismik.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingList) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorList != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Gagal memuat data gempa',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchGempa,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _gempaList.length,
      itemBuilder: (context, index) {
        final gempa = _gempaList[index];
        final hasil = _hasilMap[index];
        final isLoading = _loadingMap[index] ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: hasil != null
                ? Border.all(
                    color: hasil.isAnomali ? Colors.red : Colors.green,
                    width: 1.5,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _magColor(gempa.magnitude),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'M ${gempa.magnitude}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        gempa.wilayah,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 12, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 4),
                    Text(
                      '${gempa.tanggal}  ${gempa.jam}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_downward,
                        size: 12, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 4),
                    Text(
                      gempa.kedalaman,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
                if (hasil != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (hasil.isAnomali ? Colors.red : Colors.green)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasil.isAnomali
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline,
                          color: hasil.isAnomali ? Colors.red : Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasil.isAnomali
                              ? 'Anomali Terdeteksi'
                              : 'Tidak Ada Anomali',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color:
                                hasil.isAnomali ? Colors.red : Colors.green,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(hasil.confidence * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                hasil.isAnomali ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _deteksi(index, gempa),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasil != null
                          ? const Color(0xFF757575)
                          : const Color(0xFF388E3C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            hasil != null ? 'Deteksi Ulang' : 'Deteksi Anomali',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _magColor(String mag) {
    final m = double.tryParse(mag) ?? 0;
    if (m >= 6.0) return Colors.red;
    if (m >= 5.0) return Colors.orange;
    return const Color(0xFF42A5F5);
  }
}
