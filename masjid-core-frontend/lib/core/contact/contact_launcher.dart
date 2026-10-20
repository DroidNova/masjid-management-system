import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the phone's own apps to reach a person: a message already
/// written (WhatsApp when it is installed, otherwise SMS), or the dialer.
/// Returns false when nothing could open.
class ContactLauncher {
  const ContactLauncher._();

  /// Digits only, with India's 91 in front of a bare 10-digit number, as
  /// WhatsApp links need.
  static String waDigits(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 10 ? '91$digits' : digits;
  }

  /// WhatsApp if the phone has it, else the SMS app, with [message] typed
  /// in. Nothing is sent until the person presses send. On the website,
  /// the wa.me link (WhatsApp Web or the app).
  static Future<bool> message(String phone, String message) async {
    final text = Uri.encodeComponent(message);
    if (kIsWeb) {
      return _open(Uri.parse('https://wa.me/${waDigits(phone)}?text=$text'));
    }
    final whatsApp = Uri.parse(
      'whatsapp://send?phone=${waDigits(phone)}&text=$text',
    );
    if (await _can(whatsApp) && await _open(whatsApp)) return true;
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return _open(Uri.parse('sms:$digits?body=$text'));
  }

  /// [message] ready to send to anyone the person picks: WhatsApp if the
  /// phone has it, else the SMS app. On the website, WhatsApp's share link.
  static Future<bool> share(String message) async {
    final text = Uri.encodeComponent(message);
    if (kIsWeb) return _open(Uri.parse('https://wa.me/?text=$text'));
    final whatsApp = Uri.parse('whatsapp://send?text=$text');
    if (await _can(whatsApp) && await _open(whatsApp)) return true;
    return _open(Uri.parse('sms:?body=$text'));
  }

  static Future<bool> _can(Uri uri) async {
    try {
      return await canLaunchUrl(uri);
    } on Object {
      return false;
    }
  }

  static Future<bool> call(String phone) =>
      _open(Uri(scheme: 'tel', path: phone.replaceAll(' ', '')));

  static Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
