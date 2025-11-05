import 'package:flutter/services.dart' show rootBundle;

import 'dao/foods_dao.dart';

class SeedService {
  SeedService._();
  static final SeedService instance = SeedService._();

  bool _seeded = false;

  Future<void> seedIfNeeded() async {
    if (_seeded) return;
    final existing = await FoodsDao.instance.all(limit: 1);
    if (existing.isNotEmpty) {
      _seeded = true;
      return;
    }
    try {
      final jsonString = await rootBundle.loadString(
        'assets/foods_seed_ar.json',
      );
      await FoodsDao.instance.seedFromJsonString(jsonString);
    } catch (_) {
      // ignore seed failures
    }
    _seeded = true;
  }
}
