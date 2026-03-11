import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_strings.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import 'package:studio_rental/features/auth/domain/entities/user.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/settings_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _defaultPriceController = TextEditingController();
  final _checkInTimeController = TextEditingController();
  final _checkOutTimeController = TextEditingController();

  String _selectedCurrency = 'EUR';
  bool _notifyCheckIn = true;
  bool _notifyCheckOut = true;
  bool _notifyPaymentDue = true;
  bool _notificationsEnabled = true;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _defaultPriceController.dispose();
    _checkInTimeController.dispose();
    _checkOutTimeController.dispose();
    super.dispose();
  }

  void _initFromUser(User user) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = user.fullName;
    _emailController.text = user.email;
    _defaultPriceController.text = user.defaultPricePerNight != 0
        ? (user.defaultPricePerNight / 100).toStringAsFixed(2)
        : '';
    _checkInTimeController.text = user.checkInTime;
    _checkOutTimeController.text = user.checkOutTime;
    _selectedCurrency = user.currency;
    _notifyCheckIn = user.notifyCheckIn;
    _notifyCheckOut = user.notifyCheckOut;
    _notifyPaymentDue = user.notifyPaymentDue;
    _notificationsEnabled = user.notificationsEnabled;
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty || email.isEmpty) return;
    context.read<SettingsBloc>().add(UpdateProfile(
          fullName: name,
          email: email,
        ));
  }

  void _saveStudioSettings() {
    final priceText = _defaultPriceController.text.trim();
    final priceInCents =
        priceText.isNotEmpty ? (double.tryParse(priceText) ?? 0) * 100 : null;

    context.read<SettingsBloc>().add(UpdateSettings(fields: {
          if (priceInCents != null) 'default_price_per_night': priceInCents.toInt(),
          'currency': _selectedCurrency,
          'check_in_time': _checkInTimeController.text.trim(),
          'check_out_time': _checkOutTimeController.text.trim(),
        }));
  }

  void _saveNotificationSettings() {
    context.read<SettingsBloc>().add(UpdateSettings(fields: {
          'notifications_enabled': _notificationsEnabled,
          'notify_check_in': _notifyCheckIn,
          'notify_check_out': _notifyCheckOut,
          'notify_payment_due': _notifyPaymentDue,
        }));
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final parts = controller.text.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '14') ?? 14,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      controller.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _saveStudioSettings();
    }
  }

  Future<void> _showClearDataDialog(AppLocalizations l10n) async {
    final confirmController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settings_clear_data),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settings_clear_data_warning),
            const SizedBox(height: 16),
            Text(l10n.settings_clear_data_type_delete),
            const SizedBox(height: 8),
            TextField(
              controller: confirmController,
              decoration: InputDecoration(
                hintText: 'DELETE',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.button_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.settings_clear_data),
          ),
        ],
      ),
    );
    if (result == true && confirmController.text == 'DELETE' && mounted) {
      context
          .read<SettingsBloc>()
          .add(ClearData(confirmation: confirmController.text));
    }
    confirmController.dispose();
  }

  Future<void> _showExportDialog(AppLocalizations l10n) async {
    final format = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.settings_export_data),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'csv'),
            child: const Text('CSV'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'json'),
            child: const Text('JSON'),
          ),
        ],
      ),
    );
    if (format != null && mounted) {
      context.read<SettingsBloc>().add(ExportData(format: format));
    }
  }

  void _logout(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settings_logout),
        content: Text(l10n.settings_logout_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.button_cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SettingsBloc>().add(const SettingsLogout());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.settings_logout),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.user != null) {
          _initFromUser(state.user!);
        }
        if (state.profileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settings_profile_saved)),
          );
        }
        if (state.saveError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.saveError == 'network_error'
                  ? l10n.error_network
                  : state.saveError!),
              backgroundColor: AppColors.error,
            ),
          );
        }
        if (state.exportUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settings_export_success)),
          );
        }
        if (state.dataCleared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settings_data_cleared)),
          );
        }
        if (state.loggedOut) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state.user == null && state.isLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.settings_title)),
            body: const LoadingIndicator(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.settings_title),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(l10n, state),
                const SizedBox(height: 24),
                _buildStudioSection(l10n),
                const SizedBox(height: 24),
                _buildNotificationsSection(l10n),
                const SizedBox(height: 24),
                _buildDataSection(l10n, state),
                const SizedBox(height: 24),
                _buildAboutSection(l10n),
                const SizedBox(height: 24),
                _buildLogoutButton(l10n),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.headlineSmall),
    );
  }

  Widget _buildProfileSection(AppLocalizations l10n, SettingsState state) {
    final user = state.user;
    final initials = user != null
        ? user.fullName
            .split(' ')
            .where((p) => p.isNotEmpty)
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join()
        : '';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.settings_profile),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  initials,
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.settings_full_name,
                border: const OutlineInputBorder(),
              ),
              onEditingComplete: _saveProfile,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.settings_email,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              onEditingComplete: _saveProfile,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _saveProfile,
                child: state.isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.settings_save_profile),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.settings_change_password),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.changePassword),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioSection(AppLocalizations l10n) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.settings_studio),
            TextField(
              controller: _defaultPriceController,
              decoration: InputDecoration(
                labelText: l10n.settings_default_price,
                border: const OutlineInputBorder(),
                suffixText: AppStrings.currencySymbol,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onEditingComplete: _saveStudioSettings,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checkInTimeController,
                    decoration: InputDecoration(
                      labelText: l10n.settings_check_in_time,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () => _pickTime(_checkInTimeController),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _checkOutTimeController,
                    decoration: InputDecoration(
                      labelText: l10n.settings_check_out_time,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () => _pickTime(_checkOutTimeController),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(AppLocalizations l10n) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.settings_notifications),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settings_notify_push),
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                _saveNotificationSettings();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settings_notify_checkin),
              value: _notifyCheckIn,
              onChanged: (val) {
                setState(() => _notifyCheckIn = val);
                _saveNotificationSettings();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settings_notify_checkout),
              value: _notifyCheckOut,
              onChanged: (val) {
                setState(() => _notifyCheckOut = val);
                _saveNotificationSettings();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settings_notify_unpaid),
              value: _notifyPaymentDue,
              onChanged: (val) {
                setState(() => _notifyPaymentDue = val);
                _saveNotificationSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(AppLocalizations l10n, SettingsState state) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.settings_data),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    state.isExporting ? null : () => _showExportDialog(l10n),
                icon: state.isExporting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(l10n.settings_export_data),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showClearDataDialog(l10n),
                icon: const Icon(Icons.delete_forever, color: AppColors.error),
                label: Text(
                  l10n.settings_clear_data,
                  style: const TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(AppLocalizations l10n) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.settings_about),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settings_version),
              trailing: Text('1.0.0', style: AppTextStyles.bodySmall),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.star_outline),
              title: Text(l10n.settings_rate_app),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Platform-specific app store link
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.settings_privacy_policy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final uri = Uri.parse('https://example.com/privacy');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.settings_terms),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final uri = Uri.parse('https://example.com/terms');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _logout(l10n),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(l10n.settings_logout, style: AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
