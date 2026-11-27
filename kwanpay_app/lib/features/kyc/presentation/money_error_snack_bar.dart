import 'package:flutter/material.dart';

import '../../../core/utils/money_error.dart';
import 'limits_screen.dart';

/// The snack bar a money screen shows when an action fails. A limit
/// refusal comes with a way to see and raise the limit.
SnackBar moneyErrorSnackBar(BuildContext context, Object error) {
  final navigator = Navigator.of(context);
  return SnackBar(
    content: Text(moneyErrorMessage(error)),
    duration: const Duration(seconds: 6),
    action: isLimitError(error)
        ? SnackBarAction(
            label: 'Raise limit',
            onPressed: () => navigator.push(
              MaterialPageRoute(builder: (_) => const LimitsScreen()),
            ),
          )
        : null,
  );
}
