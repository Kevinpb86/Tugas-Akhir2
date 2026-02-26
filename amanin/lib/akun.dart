import 'package:flutter/material.dart';
import 'login.dart';
import 'utils/localization.dart';
import 'main.dart'; // Import main.dart to access localeNotifier

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          Localization.of(context).get('account_title'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                // image removed to fallback to Icons.person
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.grey,
              ), // Fallback
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'John Doe',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'johndoe@example.com',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localization.of(context).get('account_section_general'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9E9E9E),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingsItem(
          Icons.person_outline,
          'Ubah Profil',
        ), // "Ubah Profil" might not be in localization keys, using raw string for now based on walkthrough
        _buildSettingsItem(
          Icons.notifications_outlined,
          Localization.of(context).get('account_menu_notif'),
        ),
        _buildSettingsItem(
          Icons.language,
          Localization.of(context).get('account_menu_lang'),
          onTap: () => _showLanguageSelector(context),
        ),
        _buildSettingsItem(
          Icons.help_outline,
          Localization.of(context).get('account_menu_help'),
        ),
        _buildSettingsItem(
          Icons.info_outline,
          Localization.of(context).get('account_menu_about'),
        ),
        const SizedBox(height: 32),
        _buildSettingsItem(
          Icons.logout,
          'Keluar', // "Keluar" might not be in localization keys
          isDestructive: true,
          onTap: () {
            isLoggedInNotifier.value = false;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFEBEE) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? const Color(0xFFEF5350)
              : const Color(0xFF1A1A1A),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDestructive
              ? const Color(0xFFEF5350)
              : const Color(0xFF1A1A1A),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFE0E0E0),
        size: 20,
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                Localization.of(context).get('account_popup_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 24),
              _buildLanguageOption(context, 'Bahasa Indonesia', 'id'),
              const SizedBox(height: 16),
              _buildLanguageOption(context, 'English', 'en'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String label, String code) {
    final isSelected = localeNotifier.value.languageCode == code;

    return InkWell(
      onTap: () {
        localeNotifier.value = Locale(code);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${Localization.of(context).get('account_lang_changed')} $label',
            ),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF00BCD4)
                    : const Color(0xFF1A1A1A),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00BCD4),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
