class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class Currencies {
  static const ngn = Currency(code: 'NGN', symbol: '₦', name: 'Nigerian Naira');
  static const usd = Currency(code: 'USD', symbol: '\$', name: 'US Dollar');
  static const gbp = Currency(code: 'GBP', symbol: '£', name: 'British Pound');
  static const eur = Currency(code: 'EUR', symbol: '€', name: 'Euro');
  static const ghs = Currency(code: 'GHS', symbol: '₵', name: 'Ghanaian Cedi');
  static const kes = Currency(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling');
  static const zar = Currency(code: 'ZAR', symbol: 'R', name: 'South African Rand');

  static const List<Currency> all = [ngn, usd, gbp, eur, ghs, kes, zar];

  static Currency fromCode(String code) {
    return all.firstWhere(
      (c) => c.code == code,
      orElse: () => ngn,
    );
  }
}
