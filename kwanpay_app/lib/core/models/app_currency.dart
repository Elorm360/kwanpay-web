class AppCurrency {
  final String code;
  final String name;
  final String symbol;

  const AppCurrency({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class AppCurrencies {
  static const usd = AppCurrency(
    code: 'USD',
    name: 'US Dollar',
    symbol: r'$',
  );

  static const ghs = AppCurrency(
    code: 'GHS',
    name: 'Ghana Cedi',
    symbol: 'GH₵',
  );

  static const kes = AppCurrency(
    code: 'KES',
    name: 'Kenyan Shilling',
    symbol: 'KSh',
  );

  static const zar = AppCurrency(
    code: 'ZAR',
    name: 'South African Rand',
    symbol: 'R',
  );

  static const ngn = AppCurrency(
    code: 'NGN',
    name: 'Nigerian Naira',
    symbol: '₦',
  );

  /// The currency KwanPay actually holds for Ghana users.
  static const home = ghs;

  /// Currencies the home card can display. Switching does not move money.
  static const List<AppCurrency> display = [ghs, usd, kes, zar, ngn];

  static const List<AppCurrency> supported = display;

  static AppCurrency byCode(String? code) {
    final normalized = (code ?? '').trim().toUpperCase();

    for (final currency in display) {
      if (currency.code == normalized) {
        return currency;
      }
    }

    return home;
  }

  static bool isSupported(String? code) {
    final normalized = (code ?? '').trim().toUpperCase();
    return display.any((currency) => currency.code == normalized);
  }

  static AppCurrency defaultForCountry(String? country) {
    final normalized = (country ?? '').trim().toLowerCase();

    if (normalized.contains('kenya')) {
      return kes;
    }

    if (normalized.contains('south africa')) {
      return zar;
    }

    if (normalized.contains('nigeria')) {
      return ngn;
    }

    return ghs;
  }

  static AppCurrency resolve({
    String? preferredCurrency,
    String? country,
  }) {
    if (isSupported(preferredCurrency)) {
      return byCode(preferredCurrency);
    }

    return defaultForCountry(country);
  }
}
