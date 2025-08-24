import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state is ThemeLoaded ? state.isDarkMode : false;
        
        return CupertinoButton(
          padding: const EdgeInsets.all(8),
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleTheme());
          },
          child: Icon(
            isDarkMode ? CupertinoIcons.sun_max : CupertinoIcons.moon,
            color: CupertinoTheme.of(context).primaryColor,
            size: 24,
          ),
        );
      },
    );
  }
}
