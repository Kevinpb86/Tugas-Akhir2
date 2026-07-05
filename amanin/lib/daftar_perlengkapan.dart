import 'package:flutter/material.dart';
import 'dart:ui';

class DaftarPerlengkapanPage extends StatefulWidget {
  const DaftarPerlengkapanPage({super.key});

  @override
  State<DaftarPerlengkapanPage> createState() => _DaftarPerlengkapanPageState();
}

class _DaftarPerlengkapanPageState extends State<DaftarPerlengkapanPage> {
  final Map<String, bool> _checkedItems = {};

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Dokumen & Identitas',
      'icon': Icons.folder_copy_rounded,
      'color': Color(0xFF2196F3),
      'items': [
        'Fotokopi KTP / SIM',
        'Fotokopi Kartu Keluarga',
        'Fotokopi BPJS / Asuransi',
        'Fotokopi Akta Kelahiran',
        'Daftar kontak darurat keluarga',
      ],
    },
    {
      'title': 'Makanan & Minuman',
      'icon': Icons.fastfood_rounded,
      'color': Color(0xFFFF9800),
      'items': [
        'Air mineral kemasan (3 liter/orang)',
        'Makanan kaleng siap saji',
        'Biskuit / roti kering',
        'Mie instan & makanan instant',
        'Susu bubuk / UHT',
        'Gula, garam, kopi sachet',
      ],
    },
    {
      'title': 'Kesehatan & P3K',
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFFE53935),
      'items': [
        'Kotak P3K lengkap',
        'Obat pribadi / resep dokter',
        'Masker medis & hand sanitizer',
        'Perban, plester, kapas, betadine',
        'Termometer digital',
        'Obat diare, pusing, demam',
      ],
    },
    {
      'title': 'Peralatan Darurat',
      'icon': Icons.flashlight_on_rounded,
      'color': Color(0xFF4CAF50),
      'items': [
        'Senter LED & baterai cadangan',
        'Peluit darurat (whistle)',
        'Radio portabel (baterai/engkol)',
        'Power bank terisi penuh',
        'Korek api tahan air',
        'Tali tambang (minimal 5 meter)',
        'Pisau lipat multifungsi',
      ],
    },
    {
      'title': 'Pakaian & Perlindungan',
      'icon': Icons.checkroom_rounded,
      'color': Color(0xFF9C27B0),
      'items': [
        'Pakaian ganti (2 set)',
        'Jas hujan / ponco',
        'Selimut darurat (emergency blanket)',
        'Sarung tangan kerja',
        'Sepatu tertutup yang kokoh',
        'Helm / pelindung kepala',
      ],
    },
    {
      'title': 'Kebersihan & Sanitasi',
      'icon': Icons.clean_hands_rounded,
      'color': Color(0xFF00BCD4),
      'items': [
        'Sabun batang / cair',
        'Sikat gigi & pasta gigi',
        'Tisu basah & tisu kering',
        'Kantong plastik besar (sampah)',
        'Pembalut wanita / popok bayi',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    int totalItems = _categories.fold(0, (sum, cat) => sum + (cat['items'] as List).length);
    int checkedCount = _checkedItems.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Perlengkapan Siaga',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _checkedItems.clear();
              });
            },
            child: const Text(
              'Reset',
              style: TextStyle(fontSize: 12, color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progres Persiapan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: checkedCount == totalItems
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$checkedCount / $totalItems item',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: checkedCount == totalItems
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF757575),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalItems > 0 ? checkedCount / totalItems : 0,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      checkedCount == totalItems
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF2196F3),
                    ),
                    minHeight: 8,
                  ),
                ),
                if (checkedCount == totalItems && totalItems > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Tas siaga Anda sudah lengkap!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Category List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryCard(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final items = category['items'] as List;
    final color = category['color'] as Color;
    int catChecked = items.where((item) => _checkedItems[item] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['title'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$catChecked dari ${items.length} item siap',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (catChecked == items.length)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_rounded, color: Color(0xFF4CAF50), size: 16),
                  ),
              ],
            ),
          ),
          // Checklist Items
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Column(
              children: items.map<Widget>((item) {
                final isChecked = _checkedItems[item] ?? false;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _checkedItems[item] = !isChecked;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isChecked ? color : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isChecked ? color : const Color(0xFFD0D0D0),
                              width: 2,
                            ),
                          ),
                          child: isChecked
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              color: isChecked ? Colors.grey[400] : const Color(0xFF424242),
                              fontWeight: FontWeight.w500,
                              decoration: isChecked ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
