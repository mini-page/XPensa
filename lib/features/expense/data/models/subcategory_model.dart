import 'dart:convert';

import 'package:uuid/uuid.dart';

class SubcategoryModel {
  const SubcategoryModel({
    required this.id,
    required this.name,
    required this.parentCategoryName,
    this.isEnabled = true,
    this.usageCount = 0,
    this.isDefault = false,
  });

  factory SubcategoryModel.create({
    required String name,
    required String parentCategoryName,
    bool isEnabled = true,
    int usageCount = 0,
    bool isDefault = false,
  }) =>
      SubcategoryModel(
        id: const Uuid().v4(),
        name: name.trim(),
        parentCategoryName: parentCategoryName.trim(),
        isEnabled: isEnabled,
        usageCount: usageCount,
        isDefault: isDefault,
      );

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) =>
      SubcategoryModel(
        id: (json['id'] as String?) ?? '',
        name: ((json['name'] as String?) ?? '').trim(),
        parentCategoryName: ((json['parentCategoryName'] as String?) ?? '')
            .trim(),
        isEnabled: (json['isEnabled'] as bool?) ?? true,
        usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
        isDefault: (json['isDefault'] as bool?) ?? false,
      );

  final String id;
  final String name;
  final String parentCategoryName;
  final bool isEnabled;
  final int usageCount;
  final bool isDefault;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'parentCategoryName': parentCategoryName,
        'isEnabled': isEnabled,
        'usageCount': usageCount,
        'isDefault': isDefault,
      };

  SubcategoryModel copyWith({
    String? id,
    String? name,
    String? parentCategoryName,
    bool? isEnabled,
    int? usageCount,
    bool? isDefault,
  }) =>
      SubcategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        parentCategoryName: parentCategoryName ?? this.parentCategoryName,
        isEnabled: isEnabled ?? this.isEnabled,
        usageCount: usageCount ?? this.usageCount,
        isDefault: isDefault ?? this.isDefault,
      );
}

List<SubcategoryModel> subcategoriesFromJson(String json) {
  if (json.isEmpty) return <SubcategoryModel>[];
  try {
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => SubcategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return <SubcategoryModel>[];
  }
}

String subcategoriesToJson(List<SubcategoryModel> subcategories) =>
    jsonEncode(subcategories.map((subcategory) => subcategory.toJson()).toList());

const Map<String, List<SubcategoryModel>> defaultSubcategories =
    <String, List<SubcategoryModel>>{
  'Food & Dining': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-food-breakfast',
      name: 'Breakfast',
      parentCategoryName: 'Food & Dining',
      isDefault: true,
    ),
    SubcategoryModel(
      id: 'default-food-lunch',
      name: 'Lunch',
      parentCategoryName: 'Food & Dining',
      isDefault: true,
    ),
    SubcategoryModel(
      id: 'default-food-dinner',
      name: 'Dinner',
      parentCategoryName: 'Food & Dining',
      isDefault: true,
    ),
  ],
  'Transportation': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-transport-fuel',
      name: 'Fuel',
      parentCategoryName: 'Transportation',
      isDefault: true,
    ),
    SubcategoryModel(
      id: 'default-transport-public',
      name: 'Public Transit',
      parentCategoryName: 'Transportation',
      isDefault: true,
    ),
  ],
  'Shopping': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-shopping-groceries',
      name: 'Groceries',
      parentCategoryName: 'Shopping',
      isDefault: true,
    ),
    SubcategoryModel(
      id: 'default-shopping-clothing',
      name: 'Clothing',
      parentCategoryName: 'Shopping',
      isDefault: true,
    ),
  ],
  'Beauty & Care': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-beauty-skincare',
      name: 'Skincare',
      parentCategoryName: 'Beauty & Care',
      isDefault: true,
    ),
    SubcategoryModel(
      id: 'default-beauty-salon',
      name: 'Salon',
      parentCategoryName: 'Beauty & Care',
      isDefault: true,
    ),
  ],
  'Social': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-social-party',
      name: 'Parties',
      parentCategoryName: 'Social',
      isDefault: true,
    ),
    SubcategoryModel(
      id: 'default-social-gifts',
      name: 'Gifts',
      parentCategoryName: 'Social',
      isDefault: true,
    ),
  ],
  'Travel': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-travel-flight',
      name: 'Flights',
      parentCategoryName: 'Travel',
      isDefault: true,
    ),
    SubcategoryModel(
      id: 'default-travel-hotel',
      name: 'Hotels',
      parentCategoryName: 'Travel',
      isDefault: true,
    ),
  ],
  'Other': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-other-misc',
      name: 'Miscellaneous',
      parentCategoryName: 'Other',
      isDefault: true,
    ),
  ],
  'Accessories': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-accessories-watches',
      name: 'Watches',
      parentCategoryName: 'Accessories',
      isDefault: true,
    ),
    SubcategoryModel(
      id: 'default-accessories-jewelry',
      name: 'Jewelry',
      parentCategoryName: 'Accessories',
      isDefault: true,
    ),
  ],
  'Salary': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-salary-primary',
      name: 'Primary Job',
      parentCategoryName: 'Salary',
      isDefault: true,
    ),
    SubcategoryModel(
      id: 'default-salary-bonus',
      name: 'Bonus',
      parentCategoryName: 'Salary',
      isDefault: true,
    ),
  ],
  'Award': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-award-performance',
      name: 'Performance',
      parentCategoryName: 'Award',
      isDefault: true,
    ),
  ],
  'Coupon': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-coupon-cashback',
      name: 'Cashback',
      parentCategoryName: 'Coupon',
      isDefault: true,
    ),
  ],
  'Grant': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-grant-family',
      name: 'Family Support',
      parentCategoryName: 'Grant',
      isDefault: true,
    ),
  ],
  'Lottery': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-lottery-prize',
      name: 'Prize',
      parentCategoryName: 'Lottery',
      isDefault: true,
    ),
  ],
  'Refund': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-refund-purchase',
      name: 'Purchase Return',
      parentCategoryName: 'Refund',
      isDefault: true,
    ),
  ],
  'Sale': <SubcategoryModel>[
    SubcategoryModel(
      id: 'default-sale-items',
      name: 'Sold Items',
      parentCategoryName: 'Sale',
      isDefault: true,
    ),
  ],
};
