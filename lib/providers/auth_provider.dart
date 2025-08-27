import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/remote/auth_service.dart';
import '../models/user_model.dart';
import '../services/user_preferences_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  
  SignInRequested(this.email, this.password);
  
  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  
  SignUpRequested(this.email, this.password, this.name);
  
  @override
  List<Object?> get props => [email, password, name];
}

class GoogleSignInRequested extends AuthEvent {}

class AppleSignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  
  ForgotPasswordRequested(this.email);
  
  @override
  List<Object?> get props => [email];
}

class ResetAuthState extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class CheckUserPreferences extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  
  Authenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

class AuthenticatedButNoPreferences extends AuthState {
  final UserModel user;
  
  AuthenticatedButNoPreferences(this.user);
  
  @override
  List<Object?> get props => [user];
}

class UnAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class ForgotPasswordSent extends AuthState {
  final String email;
  
  ForgotPasswordSent(this.email);
  
  @override
  List<Object?> get props => [email];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  
  AuthBloc(this._authService) : super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AppleSignInRequested>(_onAppleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetAuthState>(_onResetAuthState);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<CheckUserPreferences>(_onCheckUserPreferences);
  }
  
  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithEmailAndPassword(event.email, event.password);
      final userModel = await _authService.getUserModel();
      if (userModel != null) {
        // Check if user has preferences set
        final preferencesService = UserPreferencesService();
        final preferencesExist = await preferencesService.preferencesExist(userModel.uid);
        
        if (preferencesExist) {
          emit(Authenticated(userModel));
        } else {
          emit(AuthenticatedButNoPreferences(userModel));
        }
      } else {
        emit(AuthError('Failed to get user data'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.createUserWithEmailAndPassword(event.email, event.password, event.name);
      final userModel = await _authService.getUserModel();
      if (userModel != null) {
        // Check if user preferences exist
        final preferencesService = UserPreferencesService();
        final preferencesExist = await preferencesService.preferencesExist(userModel.uid);
        
        if (preferencesExist) {
          emit(Authenticated(userModel));
        } else {
          emit(AuthenticatedButNoPreferences(userModel));
        }
      } else {
        emit(AuthError('Failed to get user data'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithGoogle();
      final userModel = await _authService.getUserModel();
      if (userModel != null) {
        // Check if user has preferences set
        final preferencesService = UserPreferencesService();
        final preferencesExist = await preferencesService.preferencesExist(userModel.uid);
        
        if (preferencesExist) {
          emit(Authenticated(userModel));
        } else {
          emit(AuthenticatedButNoPreferences(userModel));
        }
      } else {
        emit(AuthError('Failed to get user data'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onAppleSignInRequested(AppleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithApple();
      final userModel = await _authService.getUserModel();
      if (userModel != null) {
        // Check if user has preferences set
        final preferencesService = UserPreferencesService();
        final preferencesExist = await preferencesService.preferencesExist(userModel.uid);
        
        if (preferencesExist) {
          emit(Authenticated(userModel));
        } else {
          emit(AuthenticatedButNoPreferences(userModel));
        }
      } else {
        emit(AuthError('Failed to get user data'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      
      // Clear all cached user data
      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.remove('user_data');
      await sharedPrefs.remove('user_cache_timestamp');
      
      emit(UnAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordResetEmail(event.email);
      emit(ForgotPasswordSent(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onResetAuthState(ResetAuthState event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
  
  Future<void> _onCheckUserPreferences(CheckUserPreferences event, Emitter<AuthState> emit) async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userModel = await _authService.getUserModel();
        if (userModel != null) {
          // Check if user has preferences set
          // For now, we'll assume new users need to set preferences
          emit(AuthenticatedButNoPreferences(userModel));
        } else {
          emit(UnAuthenticated());
        }
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userModel = await _authService.getUserModel();
        if (userModel != null) {
          // Check if user preferences exist
          final preferencesService = UserPreferencesService();
          final preferencesExist = await preferencesService.preferencesExist(userModel.uid);
          
          if (preferencesExist) {
            emit(Authenticated(userModel));
          } else {
            emit(AuthenticatedButNoPreferences(userModel));
          }
        } else {
          emit(UnAuthenticated());
        }
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Get current user from state
  UserModel? get currentUser {
    if (state is Authenticated) {
      return (state as Authenticated).user;
    } else if (state is AuthenticatedButNoPreferences) {
      return (state as AuthenticatedButNoPreferences).user;
    }
    return null;
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    return state is Authenticated || state is AuthenticatedButNoPreferences;
  }
}
