import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider for the app's theme mode (Light / Dark / System).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

