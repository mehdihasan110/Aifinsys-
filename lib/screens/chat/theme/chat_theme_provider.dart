import 'package:flutter/material.dart';

import '../../../data/command/chat_theme/chat_theme_command.dart';
import 'chat_theme.dart';

/// Provider to manage the current chat theme state.
/// Persists theme selection using Hive stringBox via ChatThemeCommand.
class ChatThemeProvider extends ChangeNotifier {
  ChatTheme _currentTheme = ChatThemes.ocean;
  ChatTheme get theme => _currentTheme;

  ChatThemeProvider(bool isAppDarkMode) {
    _loadTheme(isAppDarkMode);
  }

  /// Load saved theme from Hive stringBox via command
  void _loadTheme(bool isAppDarkMode) {
    final savedId = ChatThemeCommand().getThemeId();
    if (savedId != null) {
      _currentTheme = ChatThemes.getById(savedId);
    } else if (isAppDarkMode) {
      _currentTheme = ChatThemes.midnight;
    }
    notifyListeners();
  }

  /// Set and persist a new theme
  Future<void> setTheme(ChatTheme theme) async {
    if (_currentTheme.id == theme.id) return;

    _currentTheme = theme;
    notifyListeners();

    await ChatThemeCommand().setThemeId(theme.id);
  }

  /// Get all available themes
  List<ChatTheme> get availableThemes => ChatThemes.all;
}
