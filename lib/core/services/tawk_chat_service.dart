import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TawkChatService {
  static const String _tawkChatUrl = 'https://tawk.to/chat/68ba50b7721af15d8752fa7d/1j4bsmjf7';

  /// Launch Tawk.to chat with platform-specific handling
  static Future<void> launchTawkChat() async {
    final Uri chatUri = Uri.parse(_tawkChatUrl);
    
    try {
      if (await canLaunchUrl(chatUri)) {
        // Use different launch modes based on platform
        if (kIsWeb) {
          // Web: Open in new tab
          await launchUrl(
            chatUri,
            mode: LaunchMode.platformDefault,
            webOnlyWindowName: '_blank',
          );
        } else {
          // Mobile: Try in-app browser first, fallback to external
          try {
            await launchUrl(
              chatUri,
              mode: LaunchMode.inAppBrowserView,
              browserConfiguration: const BrowserConfiguration(
                showTitle: true,
              ),
            );
          } catch (inAppError) {
            if (kDebugMode) {
              print('In-app browser failed, trying external: $inAppError');
            }
            // Fallback to external browser
            await launchUrl(
              chatUri,
              mode: LaunchMode.externalApplication,
            );
          }
        }
      } else {
        throw Exception('Could not launch Tawk.to chat - URL not supported');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching Tawk.to chat: $e');
      }
      rethrow;
    }
  }

  /// Show Tawk.to chat options dialog with platform-specific messaging
  static void showTawkChatDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Color(0xFF2E5BBA),
            ),
            SizedBox(width: 8),
            Text('Live Chat Support'),
          ],
        ),
        content: Text(
          kIsWeb 
            ? 'We\'ll open the live chat in a new tab where our support team is ready to help you.'
            : 'We\'ll open the live chat in your browser where our support team is ready to help you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await launchTawkChat();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Failed to open chat: ${e.toString()}'),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () => launchTawkChat(),
                      ),
                    ),
                  );
                }
              }
            },
            icon: Icon(kIsWeb ? Icons.open_in_new : Icons.open_in_browser),
            label: Text(kIsWeb ? 'Open in New Tab' : 'Open Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5BBA),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Alternative method for Android devices with better error handling
  static Future<void> launchTawkChatForAndroid(BuildContext context) async {
    try {
      await launchTawkChat();
    } catch (e) {
      if (context.mounted) {
        // Show fallback options for Android
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Chat Unavailable'),
            content: const Text(
              'Unable to open live chat. You can contact support via:\n\n'
              '• Email: support@collegepro.com\n'
              '• Phone: +91-XXXXXXXXXX\n'
              '• Or try again later',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  launchTawkChat(); // Retry
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    }
  }
}
