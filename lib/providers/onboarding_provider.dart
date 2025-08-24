import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import '../models/onboarding_model.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOnboardingStatus extends OnboardingEvent {
  const LoadOnboardingStatus();
}

class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

class NextPage extends OnboardingEvent {
  const NextPage();
}

class PreviousPage extends OnboardingEvent {
  const PreviousPage();
}

class GoToPage extends OnboardingEvent {
  final int pageIndex;
  
  const GoToPage(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

// States
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingLoaded extends OnboardingState {
  final bool hasSeenOnboarding;
  final int currentPageIndex;
  final List<OnboardingPage> pages;

  const OnboardingLoaded({
    required this.hasSeenOnboarding,
    required this.currentPageIndex,
    required this.pages,
  });

  @override
  List<Object?> get props => [hasSeenOnboarding, currentPageIndex, pages];

  OnboardingLoaded copyWith({
    bool? hasSeenOnboarding,
    int? currentPageIndex,
    List<OnboardingPage>? pages,
  }) {
    return OnboardingLoaded(
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      pages: pages ?? this.pages,
    );
  }
}

// BLoC
@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  static const String _onboardingKey = 'has_seen_onboarding';
  final SharedPreferences _prefs;

  OnboardingBloc(this._prefs) : super(const OnboardingInitial()) {
    on<LoadOnboardingStatus>(_onLoadOnboardingStatus);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<NextPage>(_onNextPage);
    on<PreviousPage>(_onPreviousPage);
    on<GoToPage>(_onGoToPage);
  }

  Future<void> _onLoadOnboardingStatus(
    LoadOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());

    try {
      final hasSeenOnboarding = _prefs.getBool(_onboardingKey) ?? false;
      
      emit(OnboardingLoaded(
        hasSeenOnboarding: hasSeenOnboarding,
        currentPageIndex: 0,
        pages: OnboardingData.pages,
      ));
    } catch (e) {
      // Fallback to showing onboarding
      emit(const OnboardingLoaded(
        hasSeenOnboarding: false,
        currentPageIndex: 0,
        pages: OnboardingData.pages,
      ));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state is OnboardingLoaded) {
      try {
        await _prefs.setBool(_onboardingKey, true);
        
        emit((state as OnboardingLoaded).copyWith(
          hasSeenOnboarding: true,
        ));
      } catch (e) {
        // Keep current state if save fails
      }
    }
  }

  void _onNextPage(NextPage event, Emitter<OnboardingState> emit) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      final nextPageIndex = currentState.currentPageIndex + 1;
      
      if (nextPageIndex < currentState.pages.length) {
        emit(currentState.copyWith(currentPageIndex: nextPageIndex));
      }
    }
  }

  void _onPreviousPage(PreviousPage event, Emitter<OnboardingState> emit) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      final previousPageIndex = currentState.currentPageIndex - 1;
      
      if (previousPageIndex >= 0) {
        emit(currentState.copyWith(currentPageIndex: previousPageIndex));
      }
    }
  }

  void _onGoToPage(GoToPage event, Emitter<OnboardingState> emit) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      
      if (event.pageIndex >= 0 && event.pageIndex < currentState.pages.length) {
        emit(currentState.copyWith(currentPageIndex: event.pageIndex));
      }
    }
  }

  // Getters
  bool get hasSeenOnboarding {
    if (state is OnboardingLoaded) {
      return (state as OnboardingLoaded).hasSeenOnboarding;
    }
    return false;
  }

  int get currentPageIndex {
    if (state is OnboardingLoaded) {
      return (state as OnboardingLoaded).currentPageIndex;
    }
    return 0;
  }

  List<OnboardingPage> get pages {
    if (state is OnboardingLoaded) {
      return (state as OnboardingLoaded).pages;
    }
    return OnboardingData.pages;
  }

  bool get isLastPage {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      return currentState.currentPageIndex == currentState.pages.length - 1;
    }
    return false;
  }

  bool get isFirstPage {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      return currentState.currentPageIndex == 0;
    }
    return true;
  }
}
