import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/observers/app_bloc_observer.dart';

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
        Bloc.observer = AppBlocObserver();
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
