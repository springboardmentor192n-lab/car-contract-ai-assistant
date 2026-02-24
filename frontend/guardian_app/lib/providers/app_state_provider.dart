import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppState {
  final bool isSidebarCollapsed;
  final ThemeMode themeMode;

  const AppState({
    this.isSidebarCollapsed = false,
    this.themeMode = ThemeMode.dark,
  });

  AppState copyWith({
    bool? isSidebarCollapsed,
    ThemeMode? themeMode,
  }) {
    return AppState(
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void toggleSidebar() {
    state = state.copyWith(isSidebarCollapsed: !state.isSidebarCollapsed);
  }

  void toggleTheme() {
    state = state.copyWith(
      themeMode: state.themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
