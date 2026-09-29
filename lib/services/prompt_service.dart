import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Sends agent prompts to WhatsApp or Email.
class PromptService {
  /// Opens WhatsApp with a pre-filled message to [phone] (with country code, digits only).
  /// If [phone] is empty, opens WhatsApp's share picker so the user picks a chat.
  static Future<void> sendWhatsApp({required String message, String phone = ''}) async {
    Uri uri;
    if (phone.isNotEmpty) {
      uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    } else {
      uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Opens the default mail app with subject + body prefilled.
  static Future<void> sendEmail({
    required String email,
    required String subject,
    required String body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
