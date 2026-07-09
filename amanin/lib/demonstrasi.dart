import 'package:flutter/material.dart';
import 'services/anomali_service.dart';

class DemonstrasiPage extends StatefulWidget {
  const DemonstrasiPage({super.key});

  @override
  State<DemonstrasiPage> createState() => _DemonstrasiPageState();
}

class _DemonstrasiPageState extends State<DemonstrasiPage> {
  late Future<List<AnomaliGempaModel>> _anomaliFuture;
  bool _isDemoActive = false;

  @override
  void initState() {
    super.initState();
    _anomaliFuture = _fetchAnomaliSaja();
  }

  Future<List<AnomaliGempaModel>> _fetchAnomaliSaja() async {
    // Gunakan data cache jika sudah pernah diload, agar tidak muncul loading lagi
    if (DemoState.cachedAnomaliHistory != null) {
      return DemoState.cachedAnomaliHistory!;
    }
    
    // Ambil gempa anomali asli dari riwayat (deteksi Isolation Forest di backend)
    final data = await AnomaliService.fetchAnomaliHistory(limit: 1);
    
    // Simpan ke cache
    DemoState.cachedAnomaliHistory = data;
    return data;
  }

  void _refresh() {
    setState(() {
      _anomaliFuture = _fetchAnomaliSaja();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Demonstrasi'),
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
            onPressed: _refresh,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Gempa Anomali',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hanya gempa dari riwayat yang terdeteksi sebagai anomali yang ditampilkan.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<AnomaliGempaModel>>(
                    future: _anomaliFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            'Gagal memuat data: ${snapshot.error}',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tidak ada gempa anomali pada riwayat saat ini. Semua gempa terdeteksi normal.',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final anomaliList = snapshot.data!;

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: anomaliList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final gempa = anomaliList[index];
                          final bool isCurrentlySelected = DemoState.selectedDemoGempa.value?.tanggal == gempa.tanggal && 
                                                           DemoState.selectedDemoGempa.value?.jam == gempa.jam;
                                                           
                          return _buildAnomaliCard(
                            gempa: gempa,
                            isSelected: isCurrentlySelected,
                            onTap: () {
                              setState(() {
                                if (isCurrentlySelected) {
                                  DemoState.selectedDemoGempa.value = null;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Mode Demonstrasi dinonaktifkan'),
                                      backgroundColor: const Color(0xFF2C3E50),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  DemoState.selectedDemoGempa.value = gempa;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Mode Demonstrasi aktif: M ${gempa.magnitude}'),
                                      backgroundColor: const Color(0xFF2C3E50),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnomaliCard({
    required AnomaliGempaModel gempa,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.red : Colors.red.shade300,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'M ${gempa.magnitude} - ${gempa.wilayah}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${gempa.tanggal} ${gempa.jam}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          'Anomali Terdeteksi',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Kedalaman: ${gempa.kedalaman}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: isSelected ? Colors.red : Colors.grey.shade300,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }


}
