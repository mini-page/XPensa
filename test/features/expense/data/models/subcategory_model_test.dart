import 'package:flutter_test/flutter_test.dart';
import 'package:xpens/features/expense/data/models/subcategory_model.dart';

void main() {
  group('SubcategoryModel', () {
    test('create trims inputs and generates id', () {
      final model = SubcategoryModel.create(
        name: '  Breakfast  ',
        parentCategoryName: '  Food & Dining  ',
      );

      expect(model.id, isNotEmpty);
      expect(model.name, 'Breakfast');
      expect(model.parentCategoryName, 'Food & Dining');
      expect(model.isEnabled, isTrue);
      expect(model.usageCount, 0);
      expect(model.isDefault, isFalse);
    });

    test('toJson/fromJson round-trip preserves fields', () {
      const model = SubcategoryModel(
        id: 'sub-1',
        name: 'Fuel',
        parentCategoryName: 'Transportation',
        isEnabled: false,
        usageCount: 10,
        isDefault: true,
      );

      final json = model.toJson();
      final restored = SubcategoryModel.fromJson(json);

      expect(restored.id, 'sub-1');
      expect(restored.name, 'Fuel');
      expect(restored.parentCategoryName, 'Transportation');
      expect(restored.isEnabled, isFalse);
      expect(restored.usageCount, 10);
      expect(restored.isDefault, isTrue);
    });

    test('copyWith updates only supplied fields', () {
      const model = SubcategoryModel(
        id: 'sub-1',
        name: 'Fuel',
        parentCategoryName: 'Transportation',
      );

      final updated = model.copyWith(name: 'Taxi', usageCount: 3);

      expect(updated.id, 'sub-1');
      expect(updated.name, 'Taxi');
      expect(updated.parentCategoryName, 'Transportation');
      expect(updated.usageCount, 3);
      expect(updated.isEnabled, isTrue);
      expect(updated.isDefault, isFalse);
    });
  });

  group('subcategories json helpers', () {
    test('returns empty list for empty json', () {
      expect(subcategoriesFromJson(''), isEmpty);
    });

    test('returns empty list for invalid json', () {
      expect(subcategoriesFromJson('{invalid-json'), isEmpty);
    });

    test('encodes and decodes list correctly', () {
      const list = <SubcategoryModel>[
        SubcategoryModel(
          id: 'sub-1',
          name: 'Breakfast',
          parentCategoryName: 'Food & Dining',
          isDefault: true,
        ),
        SubcategoryModel(
          id: 'sub-2',
          name: 'Lunch',
          parentCategoryName: 'Food & Dining',
        ),
      ];

      final json = subcategoriesToJson(list);
      final decoded = subcategoriesFromJson(json);

      expect(decoded.length, 2);
      expect(decoded.first.name, 'Breakfast');
      expect(decoded.last.name, 'Lunch');
      expect(decoded.first.parentCategoryName, 'Food & Dining');
    });
  });

  group('defaultSubcategories', () {
    test('contains expected built-in categories', () {
      expect(defaultSubcategories, contains('Food & Dining'));
      expect(defaultSubcategories, contains('Transportation'));
      expect(defaultSubcategories, contains('Salary'));
      expect(defaultSubcategories, contains('Sale'));
    });

    test('every subcategory matches parent category key', () {
      defaultSubcategories.forEach((parent, subcategories) {
        for (final subcategory in subcategories) {
          expect(subcategory.parentCategoryName, parent);
          expect(subcategory.isDefault, isTrue);
        }
      });
    });
  });
}
