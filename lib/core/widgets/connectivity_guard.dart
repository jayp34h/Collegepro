import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import 'offline_dialog.dart';

/// A widget that guards against offline operations and shows appropriate UI
class ConnectivityGuard extends StatelessWidget {
  final Widget child;
  final Widget? offlineWidget;
  final bool showOfflineDialog;
  final VoidCallback? onOffline;

  const ConnectivityGuard({
    super.key,
    required this.child,
    this.offlineWidget,
    this.showOfflineDialog = true,
    this.onOffline,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, _) {
        // Show offline dialog when connection is lost
        if (!connectivityProvider.isConnected && 
            showOfflineDialog && 
            !connectivityProvider.hasShownOfflineDialog) {
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            connectivityProvider.markOfflineDialogShown();
            OfflineDialog.show(
              context,
              onRetry: () {
                connectivityProvider.resetOfflineDialogFlag();
                onOffline?.call();
              },
            );
          });
        }

        // Show offline widget or child based on connection status
        if (!connectivityProvider.isConnected && offlineWidget != null) {
          return offlineWidget!;
        }

        return child;
      },
    );
  }
}

/// A mixin to easily check connectivity in any widget
mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  bool get isConnected {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
    return connectivityProvider.isConnected;
  }

  void showOfflineDialogIfNeeded() {
    final connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
    if (!connectivityProvider.isConnected && !connectivityProvider.hasShownOfflineDialog) {
      connectivityProvider.markOfflineDialogShown();
      OfflineDialog.show(context, onRetry: () {
        connectivityProvider.resetOfflineDialogFlag();
      });
    }
  }
}
