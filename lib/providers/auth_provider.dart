import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/remote/auth_service.dart';
import '../models/user_model.dart';

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

class AuthCheckRequested extends AuthEvent {}

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

class UnAuthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
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
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }
  
  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithEmailAndPassword(event.email, event.password);
      final userModel = await _authService.getUserModel();
      if (userModel != null) {
        emit(Authenticated(userModel));
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
        emit(Authenticated(userModel));
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
        emit(Authenticated(userModel));
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
        emit(Authenticated(userModel));
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
      emit(UnAuthenticated());
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
          emit(Authenticated(userModel));
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
}
