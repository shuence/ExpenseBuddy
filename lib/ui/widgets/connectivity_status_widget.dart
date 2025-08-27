import 'package:flutter/cupertino.dart';
import '../../services/connectivity_service.dart';

class ConnectivityStatusWidget extends StatelessWidget {
  final double size;
  final bool showBackground;

  const ConnectivityStatusWidget({
    super.key,
    this.size = 16,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: ConnectivityService().connectionStatusStream,
      builder: (context, snapshot) {
        // Default to connected if there's an error
        final isConnected = snapshot.data == ConnectionStatus.connected || 
                           snapshot.hasError || 
                           !snapshot.hasData;
        
        Widget icon = Icon(
          isConnected ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash,
          color: isConnected ? CupertinoColors.systemGreen : CupertinoColors.systemRed,
          size: size,
        );

        if (showBackground) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isConnected 
                  ? CupertinoColors.systemGreen.withOpacity(0.1)
                  : CupertinoColors.systemRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: icon,
          );
        }

        return icon;
      },
    );
  }
}
