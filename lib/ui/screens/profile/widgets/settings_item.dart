import 'package:flutter/cupertino.dart';

class SettingsItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: icon,
            ),
            
            const SizedBox(width: 16),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: CupertinoColors.label,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Trailing widget or chevron
            if (trailing != null)
              trailing!
            else if (showChevron)
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey2,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
