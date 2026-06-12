import '../data/market_goods.dart';

class MarketLogic {
  const MarketLogic._();

  /// Deterministic daily price wobble of roughly ±20 percent, so prices
  /// shift every day without needing to be stored in the save.
  static int priceFor(MarketGood good, int day) {
    final seed = good.id.codeUnits.fold(0, (sum, unit) => sum + unit);
    final wobble = ((day * 13 + seed * 7) % 41) - 20;
    final price = (good.basePrice * (100 + wobble) / 100).round();
    return price < 1 ? 1 : price;
  }

  /// Merchants buy back below market rate.
  static int sellPriceFor(MarketGood good, int day) {
    final price = (priceFor(good, day) * 6) ~/ 10;
    return price < 1 ? 1 : price;
  }
}
