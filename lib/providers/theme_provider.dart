import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import '../core/theme/app_theme.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}

class LoadTheme extends ThemeEvent {
  const LoadTheme();
}

// States
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;
  final CupertinoThemeData theme;

  const ThemeLoaded({
    required this.isDarkMode,
    required this.theme,
  });

  @override
  List<Object?> get props => [isDarkMode, theme];
}

class ThemeLoading extends ThemeState {
  const ThemeLoading();
}

// BLoC
@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;
  
  ThemeBloc(this._prefs) : super(const ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    emit(const ThemeLoading());
    
    try {
      final isDarkMode = _prefs.getBool(_themeKey) ?? false; // Default to false (light mode/white)
      
      final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
      
      emit(ThemeLoaded(isDarkMode: isDarkMode, theme: theme));
    } catch (e) {
      // Fallback to light theme (white mode)
      emit(ThemeLoaded(isDarkMode: false, theme: AppTheme.lightTheme));
    }
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) async {
    if (state is ThemeLoaded) {
      final currentState = state as ThemeLoaded;
      final newIsDarkMode = !currentState.isDarkMode;
      
      try {
        await _prefs.setBool(_themeKey, newIsDarkMode);
        
        final newTheme = newIsDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        emit(ThemeLoaded(isDarkMode: newIsDarkMode, theme: newTheme));
      } catch (e) {
        // Keep current state if save fails
        emit(currentState);
      }
    }
  }

  bool get isDarkMode {
    if (state is ThemeLoaded) {
      return (state as ThemeLoaded).isDarkMode;
    }
    return false; // Default to light mode (white)
  }

  CupertinoThemeData get currentTheme {
    if (state is ThemeLoaded) {
      return (state as ThemeLoaded).theme;
    }
    return AppTheme.lightTheme; // Default to light theme (white mode)
  }
}
