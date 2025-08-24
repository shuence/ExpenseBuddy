// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:expensebuddy/providers/onboarding_provider.dart' as _i160;
import 'package:expensebuddy/providers/theme_provider.dart' as _i1067;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i160.OnboardingBloc>(
      () => _i160.OnboardingBloc(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i1067.ThemeBloc>(
      () => _i1067.ThemeBloc(gh<_i460.SharedPreferences>()),
    );
    return this;
  }
}
