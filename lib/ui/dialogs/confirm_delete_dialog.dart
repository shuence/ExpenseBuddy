import 'package:flutter/cupertino.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  
  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          isDestructiveAction: true,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
