class GhanaFundingRail {
  final String id;
  final String name;
  final List<String> prefixes;

  const GhanaFundingRail({
    required this.id,
    required this.name,
    required this.prefixes,
  });

  static const mtn = GhanaFundingRail(
    id: 'mtn',
    name: 'MTN MoMo',
    prefixes: ['024', '025', '053', '054', '055', '059'],
  );

  static const telecel = GhanaFundingRail(
    id: 'telecel',
    name: 'Telecel Cash',
    prefixes: ['020', '050'],
  );

  static const airtelTigo = GhanaFundingRail(
    id: 'airteltigo',
    name: 'AirtelTigo Money',
    prefixes: ['026', '027', '056', '057'],
  );

  static const List<GhanaFundingRail> all = [
    mtn,
    telecel,
    airtelTigo,
  ];

  static String? normalizeMsisdn(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length == 10 && digits.startsWith('0')) {
      digits = '233${digits.substring(1)}';
    } else if (digits.length == 9) {
      digits = '233$digits';
    }

    if (digits.length != 12 || !digits.startsWith('233')) {
      return null;
    }

    return digits;
  }

  bool matchesMsisdn(String msisdn) {
    final normalized = normalizeMsisdn(msisdn);
    if (normalized == null) return false;

    final localPrefix = '0${normalized.substring(3, 5)}';
    return prefixes.contains(localPrefix);
  }

  static GhanaFundingRail? fromMsisdn(String raw) {
    final normalized = normalizeMsisdn(raw);
    if (normalized == null) return null;

    for (final rail in all) {
      if (rail.matchesMsisdn(normalized)) return rail;
    }
    return null;
  }

  static GhanaFundingRail byId(String id) {
    for (final rail in all) {
      if (rail.id == id) return rail;
    }
    return mtn;
  }

  static String displayMsisdn(String raw) {
    final normalized = normalizeMsisdn(raw);
    if (normalized == null) return raw.trim();

    final local = '0${normalized.substring(3)}';
    if (local.length != 10) return local;
    return '${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
  }
}
