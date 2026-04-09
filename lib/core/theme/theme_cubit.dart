import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../local/local_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final LocalStorageService _storage;
  static const _key = 'theme_mode';

  ThemeCubit(this._storage, {bool initialDark = true})
      : super(initialDark ? ThemeMode.dark : ThemeMode.light);

  /// Loads persisted theme preference before emitting initial state.
  static Future<ThemeCubit> create(LocalStorageService storage) async {
    final raw = await storage.getString(_key);
    final isDark = raw != null ? raw == 'dark' : true;
    return ThemeCubit(storage, initialDark: isDark);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _storage.setString(_key, next == ThemeMode.dark ? 'dark' : 'light');
    emit(next);
  }
}
