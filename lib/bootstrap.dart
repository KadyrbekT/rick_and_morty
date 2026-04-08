import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/di/injection_container.dart';

/// BLoC observer for debug-mode logging
class _AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('[BLoC Error] ${bloc.runtimeType}: $error');
  }

  @override
  void onTransition(
      Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    debugPrint(
        '[BLoC] ${bloc.runtimeType}: ${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}');
  }
}

Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Force portrait orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Register BLoC observer in debug builds
      assert(() {
        Bloc.observer = _AppBlocObserver();
        return true;
      }());

      // Initialize all dependencies
      await initDependencies();

      runApp(const App());
    },
    (error, stackTrace) {
      debugPrint('[Unhandled Error] $error\n$stackTrace');
    },
  );
}
