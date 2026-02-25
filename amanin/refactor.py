import os
import re

# UPDATE MAIN.DART
with open('lib/main.dart', 'r', encoding='utf-8') as f:
    code = f.read()
code = code.replace("import 'beranda.dart';", "import 'main_screen.dart';")
code = code.replace("home: const BerandaPage(),", "home: const MainScreen(),")
with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(code)

# UPDATE BERANDA.DART
with open('lib/beranda.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# remove extendBody and bottomNavigationBar
code = re.sub(r'      extendBody: true,\n      bottomNavigationBar: _buildFloatingBottomNavigationBar\(\),\n', '', code)
# remove the methods
methods_regex = re.compile(r'  Widget _buildFloatingBottomNavigationBar\(\) \{.*?  Widget _buildEarthquakeCard\(\)', re.DOTALL)
code = methods_regex.sub('  Widget _buildEarthquakeCard()', code)

with open('lib/beranda.dart', 'w', encoding='utf-8') as f:
    f.write(code)

# UPDATE CUACA.DART
with open('lib/cuaca.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Add onBack parameter
code = code.replace('class CuacaPage extends StatelessWidget {\n  const CuacaPage({super.key});', 'class CuacaPage extends StatelessWidget {\n  final VoidCallback? onBack;\n  const CuacaPage({super.key, this.onBack});')
# change Navigator.pop to onBack if available
code = code.replace('onPressed: () => Navigator.pop(context),', 'onPressed: () { if (onBack != null) onBack!(); else Navigator.pop(context); },')
# remove bottomNavigationBar
code = re.sub(r'      // Use existing bottom nav structure or similar look\n      bottomNavigationBar: _buildBottomNavigationBar\(context\),\n', '', code)
# remove the methods at the bottom
methods_bottom_regex = re.compile(r'  // Bottom Nav Elements \(Replicated from Beranda for consistency/demo\).*?\n}\n', re.DOTALL)
code = methods_bottom_regex.sub('}\n', code)

# Cuaca bg color from white to very light grey #F8F9FA
code = code.replace('backgroundColor: Colors.white,', 'backgroundColor: const Color(0xFFF8F9FA),')
code = code.replace('backgroundColor: const Color(0xFFF8F9FA),\n        elevation: 0,\n', 'backgroundColor: const Color(0xFFF8F9FA),\n        elevation: 0,\n')

with open('lib/cuaca.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print("Done Refactoring Navigation")
