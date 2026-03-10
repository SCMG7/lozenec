import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/guest_repository.dart';

// --- Events ---

abstract class GuestFormEvent extends Equatable {
  const GuestFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadGuest extends GuestFormEvent {
  final String id;

  const LoadGuest({required this.id});

  @override
  List<Object?> get props => [id];
}

class SaveGuest extends GuestFormEvent {
  const SaveGuest();
}

class UpdateField extends GuestFormEvent {
  final String field;
  final String value;

  const UpdateField({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

// --- State ---

class GuestFormState extends Equatable {
  final String? guestId;
  final bool isEditMode;
  final bool isLoading;
  final bool isSaving;
  final bool isSaved;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String nationality;
  final String idNumber;
  final String notes;
  final Map<String, String> fieldErrors;
  final String? serverError;

  const GuestFormState({
    this.guestId,
    this.isEditMode = false,
    this.isLoading = false,
    this.isSaving = false,
    this.isSaved = false,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.nationality = '',
    this.idNumber = '',
    this.notes = '',
    this.fieldErrors = const {},
    this.serverError,
  });

  GuestFormState copyWith({
    String? guestId,
    bool? isEditMode,
    bool? isLoading,
    bool? isSaving,
    bool? isSaved,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? nationality,
    String? idNumber,
    String? notes,
    Map<String, String>? fieldErrors,
    String? serverError,
    bool clearServerError = false,
  }) {
    return GuestFormState(
      guestId: guestId ?? this.guestId,
      isEditMode: isEditMode ?? this.isEditMode,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      nationality: nationality ?? this.nationality,
      idNumber: idNumber ?? this.idNumber,
      notes: notes ?? this.notes,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      serverError: clearServerError ? null : (serverError ?? this.serverError),
    );
  }

  @override
  List<Object?> get props => [
        guestId,
        isEditMode,
        isLoading,
        isSaving,
        isSaved,
        firstName,
        lastName,
        phone,
        email,
        nationality,
        idNumber,
        notes,
        fieldErrors,
        serverError,
      ];
}

// --- BLoC ---

class GuestFormBloc extends Bloc<GuestFormEvent, GuestFormState> {
  final GuestRepository guestRepository;

  GuestFormBloc({required this.guestRepository})
      : super(const GuestFormState()) {
    on<LoadGuest>(_onLoadGuest);
    on<UpdateField>(_onUpdateField);
    on<SaveGuest>(_onSaveGuest);
  }

  Future<void> _onLoadGuest(
      LoadGuest event, Emitter<GuestFormState> emit) async {
    emit(state.copyWith(isLoading: true, isEditMode: true, guestId: event.id));
    try {
      final detail = await guestRepository.getGuest(event.id);
      emit(state.copyWith(
        isLoading: false,
        firstName: detail.firstName,
        lastName: detail.lastName,
        phone: detail.phone ?? '',
        email: detail.email ?? '',
        nationality: detail.nationality ?? '',
        idNumber: detail.idNumber ?? '',
        notes: detail.notes ?? '',
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        serverError: _extractErrorMessage(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        serverError: 'network_error',
      ));
    }
  }

  void _onUpdateField(UpdateField event, Emitter<GuestFormState> emit) {
    final updatedErrors = Map<String, String>.from(state.fieldErrors);
    updatedErrors.remove(event.field);

    switch (event.field) {
      case 'firstName':
        emit(state.copyWith(
          firstName: event.value,
          fieldErrors: updatedErrors,
          clearServerError: true,
        ));
      case 'lastName':
        emit(state.copyWith(
          lastName: event.value,
          fieldErrors: updatedErrors,
          clearServerError: true,
        ));
      case 'phone':
        emit(state.copyWith(
          phone: event.value,
          fieldErrors: updatedErrors,
          clearServerError: true,
        ));
      case 'email':
        emit(state.copyWith(
          email: event.value,
          fieldErrors: updatedErrors,
          clearServerError: true,
        ));
      case 'nationality':
        emit(state.copyWith(
          nationality: event.value,
          fieldErrors: updatedErrors,
          clearServerError: true,
        ));
      case 'idNumber':
        emit(state.copyWith(
          idNumber: event.value,
          fieldErrors: updatedErrors,
          clearServerError: true,
        ));
      case 'notes':
        emit(state.copyWith(
          notes: event.value,
          fieldErrors: updatedErrors,
          clearServerError: true,
        ));
    }
  }

  Future<void> _onSaveGuest(
      SaveGuest event, Emitter<GuestFormState> emit) async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: errors));
      return;
    }

    emit(state.copyWith(isSaving: true, clearServerError: true));

    try {
      if (state.isEditMode && state.guestId != null) {
        await guestRepository.updateGuest(
          state.guestId!,
          firstName: state.firstName.trim(),
          lastName: state.lastName.trim(),
          phone: state.phone.trim().isNotEmpty ? state.phone.trim() : null,
          email: state.email.trim().isNotEmpty ? state.email.trim() : null,
          nationality: state.nationality.trim().isNotEmpty
              ? state.nationality.trim()
              : null,
          idNumber:
              state.idNumber.trim().isNotEmpty ? state.idNumber.trim() : null,
          notes: state.notes.trim().isNotEmpty ? state.notes.trim() : null,
        );
      } else {
        await guestRepository.createGuest(
          firstName: state.firstName.trim(),
          lastName: state.lastName.trim(),
          phone: state.phone.trim().isNotEmpty ? state.phone.trim() : null,
          email: state.email.trim().isNotEmpty ? state.email.trim() : null,
          nationality: state.nationality.trim().isNotEmpty
              ? state.nationality.trim()
              : null,
          idNumber:
              state.idNumber.trim().isNotEmpty ? state.idNumber.trim() : null,
          notes: state.notes.trim().isNotEmpty ? state.notes.trim() : null,
        );
      }
      emit(state.copyWith(isSaving: false, isSaved: true));
    } on DioException catch (e) {
      emit(state.copyWith(
        isSaving: false,
        serverError: _extractErrorMessage(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        isSaving: false,
        serverError: 'network_error',
      ));
    }
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};

    if (state.firstName.trim().isEmpty) {
      errors['firstName'] = 'guest_form_error_first_name_required';
    } else if (state.firstName.trim().length < 2) {
      errors['firstName'] = 'guest_form_error_first_name_min';
    }

    if (state.lastName.trim().isEmpty) {
      errors['lastName'] = 'guest_form_error_last_name_required';
    } else if (state.lastName.trim().length < 2) {
      errors['lastName'] = 'guest_form_error_last_name_min';
    }

    if (state.email.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[\w\-.+]+@([\w-]+\.)+[\w-]{2,}$');
      if (!emailRegex.hasMatch(state.email.trim())) {
        errors['email'] = 'guest_form_error_email_invalid';
      }
    }

    if (state.phone.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,}$');
      if (!phoneRegex.hasMatch(state.phone.trim())) {
        errors['phone'] = 'guest_form_error_phone_invalid';
      }
    }

    return errors;
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        return data['error'] as String;
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'network_error';
    }
    return 'unknown_error';
  }
}
