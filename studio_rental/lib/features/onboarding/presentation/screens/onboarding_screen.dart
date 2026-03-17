import 'package:flutter/material.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/di/service_locator.dart';
import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';
import 'package:studio_rental/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Step 2 fields
  final _propertyNameController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _defaultPriceController = TextEditingController();
  String _propertyType = 'studio';

  // Step 3 fields
  String _checkInTime = '14:00';
  String _checkOutTime = '11:00';

  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _propertyNameController.dispose();
    _propertyAddressController.dispose();
    _defaultPriceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isSaving = true);
    try {
      final apiClient = sl<ApiClient>();
      final priceText = _defaultPriceController.text.trim();
      final priceInCents =
          priceText.isNotEmpty ? ((double.tryParse(priceText) ?? 0) * 100).toInt() : null;

      await apiClient.dio.patch(
        ApiEndpoints.updateSettings,
        data: {
          if (_propertyNameController.text.trim().isNotEmpty)
            'property_name': _propertyNameController.text.trim(),
          if (_propertyAddressController.text.trim().isNotEmpty)
            'property_address': _propertyAddressController.text.trim(),
          'property_type': _propertyType,
          if (priceInCents != null) 'default_price_per_night': priceInCents,
          'check_in_time': _checkInTime,
          'check_out_time': _checkOutTime,
          'onboarding_completed': true,
        },
      );
    } catch (_) {
      // Even if save fails, let user proceed — they can update settings later
    }
    setState(() => _isSaving = false);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false,
      );
    }
  }

  Future<void> _skipToFinish() async {
    // Save onboarding_completed and go to dashboard
    await _completeOnboarding();
  }

  Future<void> _pickTime({required bool isCheckIn}) async {
    final parts = (isCheckIn ? _checkInTime : _checkOutTime).split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '14') ?? 14,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isCheckIn) {
          _checkInTime = formatted;
        } else {
          _checkOutTime = formatted;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(l10n),
                  _buildPropertyPage(l10n),
                  _buildSchedulePage(l10n),
                  _buildReadyPage(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 120,
            color: AppColors.primary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboarding_welcome_title,
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboarding_welcome_subtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.onboarding_get_started,
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyPage(AppLocalizations l10n) {
    final propertyTypes = [
      ('apartment', l10n.onboarding_type_apartment),
      ('studio', l10n.onboarding_type_studio),
      ('house', l10n.onboarding_type_house),
      ('villa', l10n.onboarding_type_villa),
      ('room', l10n.onboarding_type_room),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboarding_property_title, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            l10n.onboarding_property_subtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _propertyNameController,
            decoration: InputDecoration(
              labelText: l10n.onboarding_property_name,
              hintText: l10n.onboarding_property_name_hint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _propertyAddressController,
            decoration: InputDecoration(
              labelText: l10n.onboarding_property_address,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _propertyType,
            decoration: InputDecoration(
              labelText: l10n.onboarding_property_type,
              border: const OutlineInputBorder(),
            ),
            items: propertyTypes
                .map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _propertyType = val);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _defaultPriceController,
            decoration: InputDecoration(
              labelText: l10n.onboarding_default_price,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _skipToFinish,
                  child: Text(l10n.onboarding_skip),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.button_next, style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.onboarding_schedule_title, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(
            l10n.onboarding_schedule_subtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.login),
            title: Text(l10n.onboarding_check_in_time),
            trailing: Text(_checkInTime, style: AppTextStyles.headlineSmall),
            onTap: () => _pickTime(isCheckIn: true),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.divider),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.onboarding_check_out_time),
            trailing: Text(_checkOutTime, style: AppTextStyles.headlineSmall),
            onTap: () => _pickTime(isCheckIn: false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.divider),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _skipToFinish,
                  child: Text(l10n.onboarding_skip),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l10n.button_next, style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadyPage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 120,
            color: AppColors.success,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.onboarding_ready_title,
            style: AppTextStyles.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Summary card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_propertyNameController.text.trim().isNotEmpty)
                    _summaryRow(
                      l10n.onboarding_property_name,
                      _propertyNameController.text.trim(),
                    ),
                  _summaryRow(l10n.onboarding_check_in_time, _checkInTime),
                  _summaryRow(l10n.onboarding_check_out_time, _checkOutTime),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.onboarding_go_to_dashboard,
                      style: AppTextStyles.button,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
