import 'package:flutter/material.dart';

class Localization {
  final Locale locale;

  Localization(this.locale);

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization) ?? Localization(const Locale('id'));
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'id': {
      // General
      'app_title': 'Amanin - Bencana',
      'loading': 'Memuat...',
      
      // Bottom Nav
      'nav_home': 'Beranda',
      'nav_weather': 'Cuaca',
      'nav_features': 'Fitur',
      'nav_quake': 'Gempa',
      'nav_education': 'Edukasi',

      // Home Page
      'home_header_title': 'Siaga Bencana',
      'home_location': 'Jakarta Pusat',
      'home_quake_status_safe': 'Tidak ada gempa signifikan',
      'home_quake_status_danger': 'Gempa Baru Saja Terjadi!',
      'home_quake_desc_safe': 'Aman terkendali',
      'home_quake_desc_danger': 'Waspada guncangan susulan',
      'home_menu_report': 'Lapor',
      'home_menu_donate': 'Donasi',
      'home_menu_safe': 'Aman',
      'home_menu_map': 'Peta',
      'home_news_title': 'Berita Terkini',
      'home_news_more': 'Lihat Semua',

      // Account Page
      'account_title': 'Profil Pengguna',
      'account_not_logged_in': 'Belum Login',
      'account_login_desc': 'Silakan login atau daftar untuk mengakses fitur lengkap Amanin.',
      'account_btn_login': 'Masuk',
      'account_btn_register': 'Daftar Akun',
      'account_section_general': 'PENGATURAN UMUM',
      'account_menu_notif': 'Notifikasi',
      'account_menu_lang': 'Bahasa',
      'account_menu_help': 'Bantuan & Dukungan',
      'account_menu_about': 'Tentang Aplikasi',
      'account_popup_title': 'Pilih Bahasa',
      'account_lang_changed': 'Bahasa diubah ke',

      // Auth
      'login_title': 'Masuk',
      'login_welcome': 'Selamat Datang Kembali! 👋',
      'login_subtitle': 'Masuk untuk mengakses semua fitur Amanin.',
      'login_label_email': 'Email',
      'login_hint_email': 'Masukkan email Anda',
      'login_label_pass': 'Kata Sandi',
      'login_hint_pass': 'Masukkan kata sandi',
      'login_forgot_pass': 'Lupa Kata Sandi?',
      'login_or': 'atau masuk dengan',
      'login_no_account': 'Belum punya akun? ',
      'login_register_link': 'Daftar Sekarang',
      
      'register_title': 'Daftar Akun',
      'register_welcome': 'Buat Akun Baru 🚀',
      'register_subtitle': 'Daftar sekarang untuk mendapatkan informasi bencana terkini.',
      'register_label_name': 'Nama Lengkap',
      'register_hint_name': 'Masukkan nama lengkap',
      'register_label_conf_pass': 'Konfirmasi Kata Sandi',
      'register_hint_conf_pass': 'Ulangi kata sandi',
      'register_or': 'atau daftar dengan',
      'register_have_account': 'Sudah punya akun? ',
      'register_btn_submit': 'Daftar Sekarang'
    },
    'en': {
      // General
      'app_title': 'Amanin - Disaster',
      'loading': 'Loading...',
      
      // Bottom Nav
      'nav_home': 'Home',
      'nav_weather': 'Weather',
      'nav_features': 'Features',
      'nav_quake': 'Quake',
      'nav_education': 'Education',

      // Home Page
      'home_header_title': 'Disaster Alert',
      'home_location': 'Central Jakarta',
      'home_quake_status_safe': 'No significant quake',
      'home_quake_status_danger': 'Earthquake Just Happened!',
      'home_quake_desc_safe': 'Safe and controlled',
      'home_quake_desc_danger': 'Beware of aftershocks',
      'home_menu_report': 'Report',
      'home_menu_donate': 'Donate',
      'home_menu_safe': 'Safe',
      'home_menu_map': 'Map',
      'home_news_title': 'Latest News',
      'home_news_more': 'See All',

      // Account Page
      'account_title': 'User Profile',
      'account_not_logged_in': 'Not Logged In',
      'account_login_desc': 'Please login or register to access full features of Amanin.',
      'account_btn_login': 'Login',
      'account_btn_register': 'Register',
      'account_section_general': 'GENERAL SETTINGS',
      'account_menu_notif': 'Notifications',
      'account_menu_lang': 'Language',
      'account_menu_help': 'Help & Support',
      'account_menu_about': 'About App',
      'account_popup_title': 'Select Language',
      'account_lang_changed': 'Language changed to',

      // Auth
      'login_title': 'Login',
      'login_welcome': 'Welcome Back! 👋',
      'login_subtitle': 'Login to access all Amanin features.',
      'login_label_email': 'Email',
      'login_hint_email': 'Enter your email',
      'login_label_pass': 'Password',
      'login_hint_pass': 'Enter password',
      'login_forgot_pass': 'Forgot Password?',
      'login_or': 'or login with',
      'login_no_account': 'Don\'t have an account? ',
      'login_register_link': 'Register Now',
      
      'register_title': 'Register',
      'register_welcome': 'Create New Account 🚀',
      'register_subtitle': 'Register now to get latest disaster updates.',
      'register_label_name': 'Full Name',
      'register_hint_name': 'Enter full name',
      'register_label_conf_pass': 'Confirm Password',
      'register_hint_conf_pass': 'Repeat password',
      'register_or': 'or register with',
      'register_have_account': 'Already have an account? ',
      'register_btn_submit': 'Register Now'
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]![key] ?? key;
  }
}

// Custom Delegate to load Localization
class LocalizationDelegate extends LocalizationsDelegate<Localization> {
  const LocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['id', 'en'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) async {
    return Localization(locale);
  }

  @override
  bool shouldReload(LocalizationDelegate old) => false;
}
