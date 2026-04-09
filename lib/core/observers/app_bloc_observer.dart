import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs BLoC transitions and errors in debug builds.
class AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('[BLoC Error] ${bloc.runtimeType}: $error');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    debugPrint(
      '[BLoC] ${bloc.runtimeType}: '
      '${transition.currentState.runtimeType} → '
      '${transition.nextState.runtimeType}',
    );
  }
}
