import 'package:flutter/material.dart';

enum BillCategory {
  food,
  transport,
  shopping,
  entertainment,
  home,
  health,
  travel,
  drinks,
  utilities,
  misc
}

class CategoryPredictor {
  static final Map<BillCategory, List<String>> _lexicon = {
    BillCategory.food: [
      'food',
      'dinner',
      'lunch',
      'breakfast',
      'pizza',
      'burger',
      'swiggy',
      'zomato',
      'restaurant',
      'cafe',
      'mcdonalds',
      'kfc',
      'meal',
      'snacks',
      'eat',
      'delivery',
      'grocery',
      'veggies',
      'meat',
      'chicken',
      'paneer',
      'maggi',
      'subway'
    ],
    BillCategory.transport: [
      'uber',
      'ola',
      'taxi',
      'auto',
      'rickshaw',
      'petrol',
      'fuel',
      'diesel',
      'gas',
      'parking',
      'toll',
      'bus',
      'train',
      'metro',
      'flight',
      'ticket',
      'bike',
      'rapido',
      'cab'
    ],
    BillCategory.shopping: [
      'shopping',
      'amazon',
      'flipkart',
      'myntra',
      'clothes',
      'shoes',
      'gift',
      'iphone',
      'laptop',
      'electronics',
      'gadget',
      'shirt',
      'jeans',
      'mall',
      'zara',
      'h&m'
    ],
    BillCategory.entertainment: [
      'movie',
      'netflix',
      'theatre',
      'cinema',
      'booking',
      'show',
      'concert',
      'game',
      'gaming',
      'ps5',
      'xbox',
      'steam',
      'club',
      'party',
      'event',
      'hotstar'
    ],
    BillCategory.home: [
      'rent',
      'maid',
      'maintenance',
      'furniture',
      'kitchen',
      'repair',
      'cleaning',
      'fan',
      'ac',
      'bed',
      'room',
      'flat',
      'electricity',
      'water'
    ],
    BillCategory.health: [
      'doctor',
      'medicine',
      'hospital',
      'pharmacy',
      'gym',
      'workout',
      'fitness',
      'protein',
      'dental',
      'clinic',
      'medical',
      'test',
      'yoga',
      'med'
    ],
    BillCategory.travel: [
      'hotel',
      'resort',
      'stay',
      'airbnb',
      'vacation',
      'trip',
      'mountain',
      'beach',
      'trek',
      'luggage',
      'passport',
      'visa',
      'booking'
    ],
    BillCategory.drinks: [
      'beer',
      'alcohol',
      'whiskey',
      'wine',
      'bar',
      'pub',
      'cocktail',
      'party',
      'coke',
      'pepsi',
      'coffee',
      'starbucks',
      'tea',
      'juice',
      'daaru'
    ],
    BillCategory.utilities: [
      'wifi',
      'internet',
      'recharge',
      'mobile',
      'bill',
      'jio',
      'airtel',
      'subscription',
      'gas',
      'cylinder',
      'broadband'
    ],
  };

  static BillCategory predict(String description) {
    if (description.isEmpty) return BillCategory.misc;

    final words = description.toLowerCase().split(RegExp(r'\s+'));
    Map<BillCategory, int> scores = {};

    for (var word in words) {
      _lexicon.forEach((category, keywords) {
        for (var keyword in keywords) {
          if (word == keyword) {
            scores[category] = (scores[category] ?? 0) + 10; // Exact match
          } else if (word.contains(keyword) || keyword.contains(word)) {
            if (word.length > 3 && keyword.length > 3) {
              scores[category] = (scores[category] ?? 0) + 3; // Partial match
            }
          }
        }
      });
    }

    if (scores.isEmpty) return BillCategory.misc;

    return scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  static IconData getIcon(BillCategory category) {
    switch (category) {
      case BillCategory.food:
        return Icons.restaurant_rounded;
      case BillCategory.transport:
        return Icons.directions_car_rounded;
      case BillCategory.shopping:
        return Icons.shopping_bag_rounded;
      case BillCategory.entertainment:
        return Icons.movie_filter_rounded;
      case BillCategory.home:
        return Icons.home_work_rounded;
      case BillCategory.health:
        return Icons.medical_services_rounded;
      case BillCategory.travel:
        return Icons.landscape_rounded;
      case BillCategory.drinks:
        return Icons.local_bar_rounded;
      case BillCategory.utilities:
        return Icons.electrical_services_rounded;
      case BillCategory.misc:
        return Icons.receipt_long_rounded;
    }
  }

  static Color getColor(BillCategory category) {
    switch (category) {
      case BillCategory.food:
        return Colors.orange;
      case BillCategory.transport:
        return Colors.blue;
      case BillCategory.shopping:
        return Colors.purple;
      case BillCategory.entertainment:
        return Colors.pink;
      case BillCategory.home:
        return Colors.brown;
      case BillCategory.health:
        return Colors.red;
      case BillCategory.travel:
        return Colors.teal;
      case BillCategory.drinks:
        return Colors.amber;
      case BillCategory.utilities:
        return Colors.cyan;
      case BillCategory.misc:
        return Colors.blueGrey;
    }
  }
}
