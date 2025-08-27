import 'package:flutter/cupertino.dart';
import '../../services/theme_service.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.instance.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return CupertinoButton(
          padding: const EdgeInsets.all(8),
          onPressed: () {
            ThemeService.instance.toggle();
          },
          child: Icon(
            isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
            color: CupertinoTheme.of(context).primaryColor,
            size: 24,
          ),
        );
      },
    );
  }
}
