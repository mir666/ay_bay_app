import 'package:flutter/material.dart';

class CategoryIcons {
  static const Map<int, IconData> map = {
    0: Icons.account_balance_wallet,
    1: Icons.card_giftcard,
    2: Icons.school,
    3: Icons.attach_money,
    4: Icons.business,
    5: Icons.more_horiz,

    10: Icons.restaurant,
    11: Icons.directions_bus,
    12: Icons.shopping_bag,
    13: Icons.receipt_long,
    14: Icons.wifi,
    15: Icons.gas_meter_outlined,
    16: Icons.shopping_cart_outlined,
    17: Icons.local_hospital_outlined,
    18: Icons.school_outlined,
  };

  static IconData fromId(int id) {
    return map[id] ?? Icons.category;
  }
}
