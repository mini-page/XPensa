import 'dart:convert';
import 'dart:ui';

import 'package:uuid/uuid.dart';

class CustomCategoryModel {
  const CustomCategoryModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorHex,
  });

  factory CustomCategoryModel.create({
    required String name,
    required String iconKey,
    required String colorHex,
  }) =>
      CustomCategoryModel(
        id: const Uuid().v4(),
        name: name.trim(),
        iconKey: iconKey,
        colorHex: colorHex,
      );

  factory CustomCategoryModel.fromJson(Map<String, dynamic> json) =>
      CustomCategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        iconKey: json['iconKey'] as String,
        colorHex: json['colorHex'] as String,
      );

  final String id;
  final String name;

  /// Icon key — maps to an [IconData] via [categoryIconFromKey].
  final String iconKey;

  /// 6-char hex colour string, no '#', e.g. `"FF8C7A"`.
  final String colorHex;

  Color get color => Color(int.parse('FF$colorHex', radix: 16));

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        'colorHex': colorHex,
      };

  CustomCategoryModel copyWith({
    String? name,
    String? iconKey,
    String? colorHex,
  }) =>
      CustomCategoryModel(
        id: id,
        name: name ?? this.name,
        iconKey: iconKey ?? this.iconKey,
        colorHex: colorHex ?? this.colorHex,
      );
}

List<CustomCategoryModel> customCategoriesFromJson(String json) {
  if (json.isEmpty) return const [];
  try {
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => CustomCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return const [];
  }
}

String customCategoriesToJson(List<CustomCategoryModel> cats) =>
    jsonEncode(cats.map((c) => c.toJson()).toList());
