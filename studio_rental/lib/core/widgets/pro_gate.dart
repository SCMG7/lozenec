import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/core/services/subscription_bloc.dart';
import 'upgrade_bottom_sheet.dart';

/// Wraps any Pro-only UI. If the user is on the free tier,
/// tapping triggers the upgrade bottom sheet instead.
class ProGate extends StatelessWidget {
  final Widget child;
  final String featureName;

  /// If true, shows the child but grayed out when not Pro.
  /// If false, shows nothing when not Pro.
  final bool showDisabled;

  const ProGate({
    super.key,
    required this.child,
    required this.featureName,
    this.showDisabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state.isPro) {
          return child;
        }

        if (!showDisabled) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => UpgradeBottomSheet.show(context, featureName: featureName),
          child: Opacity(
            opacity: 0.5,
            child: AbsorbPointer(child: child),
          ),
        );
      },
    );
  }
}
