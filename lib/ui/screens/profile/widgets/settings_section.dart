import 'package:flutter/cupertino.dart';

class SettingsSection extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? margin;

  const SettingsSection({
    super.key,
    required this.children,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: _buildChildrenWithSeparators(),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenWithSeparators() {
    final List<Widget> separatedChildren = [];
    
    for (int i = 0; i < children.length; i++) {
      separatedChildren.add(children[i]);
      
      // Add separator except for the last item
      if (i < children.length - 1) {
        separatedChildren.add(
          Container(
            margin: const EdgeInsets.only(left: 72), // Align with text, not icon
            height: 0.5,
            color: CupertinoColors.separator,
          ),
        );
      }
    }
    
    return separatedChildren;
  }
}
