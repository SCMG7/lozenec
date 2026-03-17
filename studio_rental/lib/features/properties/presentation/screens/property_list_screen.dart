import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/utils/currency_formatter.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import 'package:studio_rental/core/widgets/error_state_widget.dart';
import 'package:studio_rental/core/widgets/empty_state_widget.dart';
import 'package:studio_rental/core/widgets/pro_gate.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';
import 'add_edit_property_screen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(const LoadProperties());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.property_list_title),
      ),
      floatingActionButton: _buildFab(context, l10n),
      body: BlocConsumer<PropertyBloc, PropertyState>(
        listener: (context, state) {
          if (state.saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.property_saved)),
            );
          }
          if (state.deleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.property_deleted)),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error == 'network_error'
                      ? l10n.error_network
                      : state.error!,
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.properties.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.error != null && state.properties.isEmpty) {
            return ErrorStateWidget(
              message: l10n.error_network,
              buttonText: l10n.action_retry,
              onRetry: () {
                context.read<PropertyBloc>().add(const LoadProperties());
              },
            );
          }

          if (state.properties.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.home_work_outlined,
              message: l10n.property_list_title,
              actionText: l10n.property_add,
              onAction: () => _navigateToAdd(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PropertyBloc>().add(const LoadProperties());
              await context.read<PropertyBloc>().stream.firstWhere(
                    (s) => !s.isLoading,
                  );
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.properties.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final property = state.properties[index];
                final isActive = state.activeProperty?.id == property.id;
                return _PropertyCard(
                  property: property,
                  isActive: isActive,
                  onTap: () => _navigateToEdit(context, property),
                  onSelect: () {
                    context
                        .read<PropertyBloc>()
                        .add(SelectProperty(property: property));
                  },
                  onDelete: () => _confirmDelete(context, property, l10n),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFab(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<PropertyBloc, PropertyState>(
      buildWhen: (prev, curr) => prev.properties.length != curr.properties.length,
      builder: (context, state) {
        final fab = FloatingActionButton(
          heroTag: 'property_fab',
          onPressed: () => _navigateToAdd(context),
          child: const Icon(Icons.add),
        );

        // Gate the FAB for free users who already have 1+ property
        if (state.properties.isNotEmpty) {
          return ProGate(
            featureName: l10n.upgrade_feature_properties,
            child: fab,
          );
        }

        return fab;
      },
    );
  }

  void _navigateToAdd(BuildContext context) async {
    final bloc = context.read<PropertyBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const AddEditPropertyScreen(),
        ),
      ),
    );
    if (result == true && mounted) {
      bloc.add(const LoadProperties());
    }
  }

  void _navigateToEdit(BuildContext context, Property property) async {
    final bloc = context.read<PropertyBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AddEditPropertyScreen(property: property),
        ),
      ),
    );
    if (result == true && mounted) {
      bloc.add(const LoadProperties());
    }
  }

  void _confirmDelete(
      BuildContext context, Property property, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.action_delete),
        content: Text('${property.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.action_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<PropertyBloc>()
                  .add(DeleteProperty(id: property.id));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.action_delete),
          ),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Property property;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const _PropertyCard({
    required this.property,
    required this.isActive,
    required this.onTap,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final priceFormatted =
        CurrencyFormatter.format(property.defaultPricePerNight, currency: property.currency);

    return Card(
      elevation: isActive ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _propertyTypeIcon(property.propertyType),
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.name,
                          style: AppTextStyles.titleMedium,
                        ),
                        if (property.address != null &&
                            property.address!.isNotEmpty)
                          Text(
                            property.address!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.property_active,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'select') onSelect();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      if (!isActive)
                        PopupMenuItem(
                          value: 'select',
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(l10n.property_set_active),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(l10n.action_delete,
                                style: const TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    label: priceFormatted,
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.login,
                    label: property.checkInTime,
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.logout,
                    label: property.checkOutTime,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _propertyTypeIcon(String type) {
    switch (type) {
      case 'apartment':
        return Icons.apartment;
      case 'house':
        return Icons.house;
      case 'villa':
        return Icons.villa;
      case 'room':
        return Icons.bed;
      case 'studio':
      default:
        return Icons.home_work;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
