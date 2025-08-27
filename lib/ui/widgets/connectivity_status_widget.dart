import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/connectivity_service.dart';

class ConnectivityStatusWidget extends StatefulWidget {
  final double size;
  final bool showBackground;

  const ConnectivityStatusWidget({
    super.key,
    this.size = 16,
    this.showBackground = false,
  });

  @override
  State<ConnectivityStatusWidget> createState() => _ConnectivityStatusWidgetState();
}

class _ConnectivityStatusWidgetState extends State<ConnectivityStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: ConnectivityService().connectionStatusStream,
      builder: (context, snapshot) {
        // Get the actual connection status from the stream
        final connectionStatus = snapshot.data;
        bool isConnected;
        
        if (connectionStatus != null) {
          isConnected = connectionStatus == ConnectionStatus.connected;
        } else {
          // If stream hasn't provided data yet, check the service directly
          isConnected = ConnectivityService().isConnected;
          debugPrint('🌐 [WIDGET] Stream no data, using service directly: $isConnected');
        }
        
        // Log the status for debugging
        debugPrint('🌐 [WIDGET] Stream status: $connectionStatus, isConnected: $isConnected');
        
        // Start/stop animation based on connection status
        if (!isConnected) {
          _animationController.repeat(reverse: true);
        } else {
          _animationController.stop();
        }
        
        Widget icon = Icon(
          isConnected ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash,
          color: isConnected ? CupertinoColors.systemGreen : CupertinoColors.systemRed,
          size: widget.size,
        );
        
        // Apply animation when offline
        if (!isConnected) {
          icon = ScaleTransition(
            scale: _pulseAnimation,
            child: icon,
          );
        }

        if (widget.showBackground) {
          return Tooltip(
            message: isConnected ? 'Online - Connected to internet' : 'Offline - No internet connection',
            child: icon,
          );
        }

        return Tooltip(
          message: isConnected ? 'Online' : 'Offline',
          child: icon,
        );
      },
    );
  }
}
