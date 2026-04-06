import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../provider/account_providers.dart';
import '../provider/preferences_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late String _selectedLocale;
  late String _selectedCurrency;
  late String _selectedThemeKey;
  late bool _smartReminders;
  late String _accountName;
  late double _initialBalance;

  final List<Map<String, String>> _languages = [
    {'name': 'English (India)', 'locale': 'en_IN'},
    {'name': 'English (US)', 'locale': 'en_US'},
    {'name': 'हिन्दी (Hindi)', 'locale': 'hi_IN'},
  ];

  final List<Map<String, String>> _currencies = [
    {'name': 'Rupee (\u20B9)', 'symbol': '\u20B9'},
    {'name': 'Dollar (\$)', 'symbol': '\$'},
    {'name': 'Euro (\u20AC)', 'symbol': '\u20AC'},
    {'name': 'Pound (\u00A3)', 'symbol': '\u00A3'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocale = 'en_IN';
    _selectedCurrency = '₹';
    _selectedThemeKey = 'light';
    _smartReminders = true;
    _accountName = 'Main Account';
    _initialBalance = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to XPensa',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s set up your preferences to get started.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSubtle,
                    ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Language'),
                      _buildDropdown<String>(
                        value: _selectedLocale,
                        items: _languages.map((lang) {
                          return DropdownMenuItem(
                            value: lang['locale'],
                            child: Text(lang['name']!),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedLocale = val!),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Currency'),
                      _buildDropdown<String>(
                        value: _selectedCurrency,
                        items: _currencies.map((curr) {
                          return DropdownMenuItem(
                            value: curr['symbol'],
                            child: Text(curr['name']!),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCurrency = val!),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('First Account'),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              label: 'Account Name',
                              initialValue: _accountName,
                              onChanged: (val) => _accountName = val,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: 'Balance',
                              initialValue: _initialBalance.toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (val) =>
                                  _initialBalance = double.tryParse(val) ?? 0.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Theme'),
                      Row(
                        children: [
                          _buildThemeOption(
                              'Light', 'light', Icons.light_mode_outlined),
                          const SizedBox(width: 12),
                          _buildThemeOption(
                              'Dark', 'dark', Icons.dark_mode_outlined),
                          const SizedBox(width: 12),
                          _buildThemeOption('System', 'system',
                              Icons.settings_brightness_outlined),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Preferences'),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Smart Reminders'),
                        subtitle: const Text('Get notified for pending bills'),
                        value: _smartReminders,
                        activeThumbColor: AppColors.primaryBlue,
                        onChanged: (val) =>
                            setState(() => _smartReminders = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Get Started',
                onPressed: _completeOnboarding,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSubtle),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.backgroundLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.backgroundLight),
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.backgroundLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, String key, IconData icon) {
    final isSelected = _selectedThemeKey == key;
    return Expanded(
      child: Semantics(
        button: true,
        label: 'Select $label theme',
        selected: isSelected,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => setState(() => _selectedThemeKey = key),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryBlue.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.backgroundLight,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.textSubtle,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textSubtle,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    // Create the first account
    await ref.read(accountControllerProvider).saveAccount(
          name: _accountName,
          iconKey: 'wallet',
          balance: _initialBalance,
        );

    // Update preferences and complete onboarding
    await ref.read(appPreferencesControllerProvider).updateAll(
          themeModeKey: _selectedThemeKey,
          locale: _selectedLocale,
          currencySymbol: _selectedCurrency,
          smartRemindersEnabled: _smartReminders,
          isOnboardingCompleted: true,
        );
  }
}
