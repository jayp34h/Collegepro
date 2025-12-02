import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import 'offline_dialog.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final bool showDialogOnOffline;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.showDialogOnOffline = true,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        // Show offline dialog when connection is lost and dialog hasn't been shown yet
        if (!connectivityProvider.isConnected && 
            widget.showDialogOnOffline && 
            !connectivityProvider.hasShownOfflineDialog) {
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            connectivityProvider.markOfflineDialogShown();
            OfflineDialog.show(
              context,
              onRetry: () {
                connectivityProvider.resetOfflineDialogFlag();
              },
            );
          });
        }

        // Return child wrapped with offline overlay if needed
        return Stack(
          children: [
            widget.child,
            if (!connectivityProvider.isConnected)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Card(
                    margin: EdgeInsets.all(20),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Internet Connection',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please check your internet connection',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
