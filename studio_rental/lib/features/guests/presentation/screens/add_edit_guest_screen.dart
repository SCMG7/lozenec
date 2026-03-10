import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import '../bloc/guest_form_bloc.dart';

class AddEditGuestScreen extends StatefulWidget {
  final String? guestId;

  const AddEditGuestScreen({super.key, this.guestId});

  @override
  State<AddEditGuestScreen> createState() => _AddEditGuestScreenState();
}

class _AddEditGuestScreenState extends State<AddEditGuestScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _notesController = TextEditingController();
  bool _controllersInitialized = false;

  bool get isEditMode => widget.guestId != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      context.read<GuestFormBloc>().add(LoadGuest(id: widget.guestId!));
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nationalityController.dispose();
    _idNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncControllers(GuestFormState state) {
    if (!_controllersInitialized && isEditMode && !state.isLoading) {
      _firstNameController.text = state.firstName;
      _lastNameController.text = state.lastName;
      _phoneController.text = state.phone;
      _emailController.text = state.email;
      _nationalityController.text = state.nationality;
      _idNumberController.text = state.idNumber;
      _notesController.text = state.notes;
      _controllersInitialized = true;
    }
  }

  String _resolveFieldError(String errorKey, AppLocalizations l10n) {
    switch (errorKey) {
      case 'guest_form_error_first_name_required':
        return l10n.guest_form_error_first_name_required;
      case 'guest_form_error_first_name_min':
        return l10n.guest_form_error_first_name_min;
      case 'guest_form_error_last_name_required':
        return l10n.guest_form_error_last_name_required;
      case 'guest_form_error_last_name_min':
        return l10n.guest_form_error_last_name_min;
      case 'guest_form_error_email_invalid':
        return l10n.guest_form_error_email_invalid;
      case 'guest_form_error_phone_invalid':
        return l10n.guest_form_error_phone_invalid;
      default:
        return errorKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<GuestFormBloc, GuestFormState>(
      listener: (context, state) {
        _syncControllers(state);
        if (state.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditMode
                    ? l10n.guest_form_updated
                    : l10n.guest_form_created,
              ),
            ),
          );
          Navigator.pop(context, true);
        }
        if (state.serverError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.serverError == 'network_error'
                    ? l10n.guest_form_error_network
                    : state.serverError!,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isEditMode ? l10n.edit_guest_title : l10n.add_guest_title,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.guest_form_cancel),
              ),
            ],
          ),
          body: state.isLoading
              ? const LoadingIndicator()
              : _buildForm(context, state, l10n),
        );
      },
    );
  }

  Widget _buildForm(
      BuildContext context, GuestFormState state, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _firstNameController,
            label: l10n.guest_form_first_name,
            hint: l10n.guest_form_first_name_hint,
            field: 'firstName',
            error: state.fieldErrors['firstName'],
            l10n: l10n,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _lastNameController,
            label: l10n.guest_form_last_name,
            hint: l10n.guest_form_last_name_hint,
            field: 'lastName',
            error: state.fieldErrors['lastName'],
            l10n: l10n,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: l10n.guest_form_phone,
            hint: l10n.guest_form_phone_hint,
            field: 'phone',
            error: state.fieldErrors['phone'],
            l10n: l10n,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: l10n.guest_form_email,
            hint: l10n.guest_form_email_hint,
            field: 'email',
            error: state.fieldErrors['email'],
            l10n: l10n,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nationalityController,
            label: l10n.guest_form_nationality,
            hint: l10n.guest_form_nationality_hint,
            field: 'nationality',
            error: state.fieldErrors['nationality'],
            l10n: l10n,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _idNumberController,
            label: l10n.guest_form_id_number,
            hint: l10n.guest_form_id_number_hint,
            field: 'idNumber',
            error: state.fieldErrors['idNumber'],
            l10n: l10n,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _notesController,
            label: l10n.guest_form_notes,
            hint: l10n.guest_form_notes_hint,
            field: 'notes',
            error: state.fieldErrors['notes'],
            l10n: l10n,
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: state.isSaving
                  ? null
                  : () {
                      context.read<GuestFormBloc>().add(const SaveGuest());
                    },
              child: state.isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.guest_form_saving),
                      ],
                    )
                  : Text(l10n.guest_form_save),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String field,
    required String? error,
    required AppLocalizations l10n,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error != null ? _resolveFieldError(error, l10n) : null,
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        context
            .read<GuestFormBloc>()
            .add(UpdateField(field: field, value: value));
      },
    );
  }
}
