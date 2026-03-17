import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/services/subscription_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';

class UpgradeBottomSheet extends StatelessWidget {
  final String featureName;

  const UpgradeBottomSheet({super.key, required this.featureName});

  static Future<void> show(BuildContext context, {required String featureName}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SubscriptionBloc>(),
        child: UpgradeBottomSheet(featureName: featureName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state.isPro) {
          Navigator.of(context).pop();
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.error_generic),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Feature name
                Text(
                  l10n.upgrade_unlock(featureName),
                  style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Free vs Pro comparison
                _buildComparisonRow(l10n.upgrade_feature_history, false, true),
                _buildComparisonRow(l10n.upgrade_feature_export, false, true),
                _buildComparisonRow(l10n.upgrade_feature_reports, false, true),
                _buildComparisonRow(l10n.upgrade_feature_properties, false, true),
                const SizedBox(height: 24),

                // Annual plan (highlighted)
                _buildPlanCard(
                  context: context,
                  title: l10n.upgrade_annual,
                  price: l10n.upgrade_annual_price,
                  badge: l10n.upgrade_best_value,
                  isHighlighted: true,
                  onTap: state.isLoading
                      ? null
                      : () => context.read<SubscriptionBloc>().add(const PurchaseAnnual()),
                ),
                const SizedBox(height: 12),

                // Monthly plan
                _buildPlanCard(
                  context: context,
                  title: l10n.upgrade_monthly,
                  price: l10n.upgrade_monthly_price,
                  isHighlighted: false,
                  onTap: state.isLoading
                      ? null
                      : () => context.read<SubscriptionBloc>().add(const PurchaseMonthly()),
                ),
                const SizedBox(height: 16),

                // Loading indicator
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                // Start free trial CTA
                if (!state.isLoading)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.read<SubscriptionBloc>().add(const PurchaseAnnual()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.upgrade_start_trial,
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                // Restore + dismiss
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          context.read<SubscriptionBloc>().add(const RestorePurchases()),
                      child: Text(
                        l10n.upgrade_restore,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.upgrade_maybe_later,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonRow(String feature, bool free, bool pro) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: Icon(
              free ? Icons.check_circle : Icons.cancel,
              color: free ? AppColors.success : Colors.white24,
              size: 20,
            ),
          ),
          Expanded(
            child: Icon(
              pro ? Icons.check_circle : Icons.cancel,
              color: pro ? AppColors.success : Colors.white24,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required String price,
    String? badge,
    required bool isHighlighted,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isHighlighted ? AppColors.primary : Colors.white24,
            width: isHighlighted ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isHighlighted ? AppColors.primary.withValues(alpha: 0.15) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: Colors.white,
                fontSize: isHighlighted ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
