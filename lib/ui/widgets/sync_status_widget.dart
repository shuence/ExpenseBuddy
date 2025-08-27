import 'package:flutter/cupertino.dart';
import '../../services/sync_service.dart';

class SyncStatusWidget extends StatelessWidget {
  final double size;
  final bool showBackground;

  const SyncStatusWidget({
    super.key,
    this.size = 16,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: SyncService().syncStatusStream,
      builder: (context, snapshot) {
        final isSyncing = snapshot.data ?? false;
        
        Widget icon = Icon(
          isSyncing ? CupertinoIcons.arrow_clockwise : CupertinoIcons.checkmark_circle,
          color: isSyncing ? CupertinoColors.systemOrange : CupertinoColors.systemGreen,
          size: size,
        );

        if (showBackground) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSyncing 
                  ? CupertinoColors.systemOrange.withOpacity(0.1)
                  : CupertinoColors.systemGreen.withOpacity(0.1),
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
