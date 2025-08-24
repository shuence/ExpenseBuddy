import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_preferences_model.dart';
import '../services/user_preferences_service.dart';

// Events
abstract class UserPreferencesEvent extends Equatable {
  const UserPreferencesEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserPreferences extends UserPreferencesEvent {
  final String userId;

  const LoadUserPreferences(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateNotificationSettings extends UserPreferencesEvent {
  final String userId;
  final NotificationSettings notificationSettings;

  const UpdateNotificationSettings(this.userId, this.notificationSettings);

  @override
  List<Object?> get props => [userId, notificationSettings];
}

class UpdatePermissionStatus extends UserPreferencesEvent {
  final String userId;
  final String permissionType;
  final bool status;

  const UpdatePermissionStatus(this.userId, this.permissionType, this.status);

  @override
  List<Object?> get props => [userId, permissionType, status];
}

class MarkSetupComplete extends UserPreferencesEvent {
  final String userId;

  const MarkSetupComplete(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CheckPreferencesExist extends UserPreferencesEvent {
  final String userId;

  const CheckPreferencesExist(this.userId);

  @override
  List<Object?> get props => [userId];
}

// States
abstract class UserPreferencesState extends Equatable {
  const UserPreferencesState();

  @override
  List<Object?> get props => [];
}

class UserPreferencesInitial extends UserPreferencesState {}

class UserPreferencesLoading extends UserPreferencesState {}

class UserPreferencesLoaded extends UserPreferencesState {
  final UserPreferencesModel preferences;

  const UserPreferencesLoaded(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class UserPreferencesError extends UserPreferencesState {
  final String message;

  const UserPreferencesError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserPreferencesUpdated extends UserPreferencesState {
  final UserPreferencesModel preferences;

  const UserPreferencesUpdated(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

class UserPreferencesNotFound extends UserPreferencesState {
  final String userId;

  const UserPreferencesNotFound(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Bloc
class UserPreferencesBloc extends Bloc<UserPreferencesEvent, UserPreferencesState> {
  final UserPreferencesService _preferencesService;

  UserPreferencesBloc(this._preferencesService) : super(UserPreferencesInitial()) {
    on<LoadUserPreferences>(_onLoadUserPreferences);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<UpdatePermissionStatus>(_onUpdatePermissionStatus);
    on<MarkSetupComplete>(_onMarkSetupComplete);
    on<CheckPreferencesExist>(_onCheckPreferencesExist);
  }

  Future<void> _onLoadUserPreferences(
    LoadUserPreferences event,
    Emitter<UserPreferencesState> emit,
  ) async {
    try {
      emit(UserPreferencesLoading());
      
      final preferences = await _preferencesService.getUserPreferences(event.userId);
      
      if (preferences != null) {
        emit(UserPreferencesLoaded(preferences));
      } else {
        emit(const UserPreferencesError('No preferences found'));
      }
    } catch (e) {
      emit(UserPreferencesError(e.toString()));
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<UserPreferencesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserPreferencesLoaded) {
        final updatedPreferences = currentState.preferences.copyWith(
          notificationSettings: event.notificationSettings,
        );
        
        await _preferencesService.updatePreferences(
          event.userId,
          {'notificationSettings': event.notificationSettings.toJson()},
        );
        
        emit(UserPreferencesUpdated(updatedPreferences));
      }
    } catch (e) {
      emit(UserPreferencesError(e.toString()));
    }
  }

  Future<void> _onUpdatePermissionStatus(
    UpdatePermissionStatus event,
    Emitter<UserPreferencesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserPreferencesLoaded) {
        final updates = <String, dynamic>{};
        
        switch (event.permissionType) {
          case 'location':
            updates['locationPermission'] = event.status;
            break;
          case 'camera':
            updates['cameraPermission'] = event.status;
            break;
          case 'storage':
            updates['storagePermission'] = event.status;
            break;
          case 'sms':
            updates['smsPermission'] = event.status;
            break;
          case 'biometric':
            updates['biometricPermission'] = event.status;
            break;
          case 'notification':
            updates['notificationPermission'] = event.status;
            break;
        }
        
        await _preferencesService.updatePermissionStatus(
          userId: event.userId,
          permission: event.permissionType,
          status: event.status,
        );
        
        final updatedPreferences = currentState.preferences.copyWith(
          locationPermission: updates['locationPermission'] ?? currentState.preferences.locationPermission,
          cameraPermission: updates['cameraPermission'] ?? currentState.preferences.cameraPermission,
          storagePermission: updates['storagePermission'] ?? currentState.preferences.storagePermission,
          smsPermission: updates['smsPermission'] ?? currentState.preferences.smsPermission,
          biometricPermission: updates['biometricPermission'] ?? currentState.preferences.biometricPermission,
          notificationPermission: updates['notificationPermission'] ?? currentState.preferences.notificationPermission,
        );
        
        emit(UserPreferencesUpdated(updatedPreferences));
      }
    } catch (e) {
      emit(UserPreferencesError(e.toString()));
    }
  }

  Future<void> _onMarkSetupComplete(
    MarkSetupComplete event,
    Emitter<UserPreferencesState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is UserPreferencesLoaded) {
        await _preferencesService.markSetupComplete(event.userId);
        
        final updatedPreferences = currentState.preferences.copyWith(
          isFirstTimeSetup: false,
        );
        
        emit(UserPreferencesUpdated(updatedPreferences));
      }
    } catch (e) {
      emit(UserPreferencesError(e.toString()));
    }
  }

  Future<void> _onCheckPreferencesExist(
    CheckPreferencesExist event,
    Emitter<UserPreferencesState> emit,
  ) async {
    try {
      emit(UserPreferencesLoading());
      
      final exists = await _preferencesService.preferencesExist(event.userId);
      
      if (exists) {
        final preferences = await _preferencesService.getUserPreferences(event.userId);
        if (preferences != null) {
          emit(UserPreferencesLoaded(preferences));
        } else {
          emit(UserPreferencesNotFound(event.userId));
        }
      } else {
        emit(UserPreferencesNotFound(event.userId));
      }
    } catch (e) {
      emit(UserPreferencesError(e.toString()));
    }
  }
}
