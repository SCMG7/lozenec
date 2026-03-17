import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import '../../domain/entities/property.dart';
import '../bloc/property_bloc.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final Property? property;

  const AddEditPropertyScreen({super.key, this.property});

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();

  String _selectedType = 'studio';

  bool get isEditMode => widget.property != null;

  static const _propertyTypes = [
    'apartment',
    'studio',
    'house',
    'villa',
    'room',
  ];

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final p = widget.property!;
      _nameController.text = p.name;
      _addressController.text = p.address ?? '';
      _selectedType = p.propertyType;
      _priceController.text = p.defaultPricePerNight != 0
          ? (p.defaultPricePerNight / 100).toStringAsFixed(2)
          : '';
      _checkInController.text = p.checkInTime;
      _checkOutController.text = p.checkOutTime;
    } else {
      _checkInController.text = '14:00';
      _checkOutController.text = '10:00';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    super.dispose();
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
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final priceText = _priceController.text.trim();
    final priceInCents =
        priceText.isNotEmpty ? ((double.tryParse(priceText) ?? 0) * 100).toInt() : 0;

    if (isEditMode) {
      context.read<PropertyBloc>().add(UpdateProperty(
            id: widget.property!.id,
            name: _nameController.text.trim(),
            address: _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
            propertyType: _selectedType,
            defaultPricePerNight: priceInCents,
            checkInTime: _checkInController.text.trim(),
            checkOutTime: _checkOutController.text.trim(),
          ));
    } else {
      context.read<PropertyBloc>().add(CreateProperty(
            name: _nameController.text.trim(),
            address: _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
            propertyType: _selectedType,
            defaultPricePerNight: priceInCents,
            checkInTime: _checkInController.text.trim(),
            checkOutTime: _checkOutController.text.trim(),
          ));
    }
  }

  String _localizedType(String type, AppLocalizations l10n) {
    switch (type) {
      case 'apartment':
        return l10n.onboarding_type_apartment;
      case 'studio':
        return l10n.onboarding_type_studio;
      case 'house':
        return l10n.onboarding_type_house;
      case 'villa':
        return l10n.onboarding_type_villa;
      case 'room':
        return l10n.onboarding_type_room;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<PropertyBloc, PropertyState>(
      listener: (context, state) {
        if (state.saved) {
          Navigator.pop(context, true);
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditMode ? l10n.property_edit : l10n.property_add,
          ),
        ),
        body: BlocBuilder<PropertyBloc, PropertyState>(
          buildWhen: (prev, curr) => prev.isSaving != curr.isSaving,
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.property_name_label,
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.error_required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: l10n.property_address_label,
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        labelText: l10n.property_type_label,
                        border: const OutlineInputBorder(),
                      ),
                      items: _propertyTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(_localizedType(type, l10n)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: l10n.property_price_label,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _checkInController,
                            decoration: InputDecoration(
                              labelText: l10n.property_checkin_label,
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () => _pickTime(_checkInController),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _checkOutController,
                            decoration: InputDecoration(
                              labelText: l10n.property_checkout_label,
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.access_time),
                            ),
                            readOnly: true,
                            onTap: () => _pickTime(_checkOutController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state.isSaving ? null : _save,
                        child: state.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(l10n.property_save),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
