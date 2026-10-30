import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LauncherService {
  LauncherService._();

  /// Nomor Indonesia 08xx diubah menjadi format internasional 628xx.
  static String normalizePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) digits = digits.substring(1);
    if (digits.startsWith('0')) {
      digits = '62${digits.substring(1)}';
    } else if (digits.startsWith('8')) {
      digits = '62$digits';
    }
    return digits;
  }

  static bool get isNativeMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<bool> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      // Sebagian platform tetap bisa membuka skema walau canLaunchUrl false.
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Launcher error ($url): $e');
      return false;
    }
  }

  static Future<bool> makePhoneCall(String phone) => openUrl('tel:$phone');

  static Future<bool> sendSms(String phone, String message) => openUrl(
        'sms:$phone?body=${Uri.encodeComponent(message)}',
      );

  static Future<bool> openMaps(String query) => openUrl(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
      );

  static Future<bool> openWhatsApp(String phone, String message) => openUrl(
        'https://wa.me/${normalizePhone(phone)}'
        '?text=${Uri.encodeComponent(message)}',
      );

  static Future<void> copyPhone(String phone) async {
    await Clipboard.setData(ClipboardData(text: phone));
  }
}
