import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/features/auth/domain/entities/user.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository})
      : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateSettings>(_onUpdateSettings);
    on<ChangePassword>(_onChangePassword);
    on<ExportData>(_onExportData);
    on<ClearData>(_onClearData);
    on<SettingsLogout>(_onLogout);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(user: event.user, isLoading: false));
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveError: null));
    try {
      final user = await settingsRepository.updateProfile(
        fullName: event.fullName,
        email: event.email,
      );
      emit(state.copyWith(user: user, isSaving: false, profileSaved: true));
      emit(state.copyWith(profileSaved: false));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(isSaving: false, saveError: message));
    } catch (e) {
      emit(state.copyWith(isSaving: false, saveError: e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveError: null));
    try {
      final user = await settingsRepository.updateSettings(
        fields: event.fields,
      );
      emit(state.copyWith(user: user, isSaving: false));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(isSaving: false, saveError: message));
    } catch (e) {
      emit(state.copyWith(isSaving: false, saveError: e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, passwordError: null));
    try {
      await settingsRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(isSaving: false, passwordChanged: true));
      emit(state.copyWith(passwordChanged: false));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(isSaving: false, passwordError: message));
    } catch (e) {
      emit(state.copyWith(isSaving: false, passwordError: e.toString()));
    }
  }

  Future<void> _onExportData(
    ExportData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isExporting: true, saveError: null));
    try {
      final url = await settingsRepository.exportData(format: event.format);
      emit(state.copyWith(isExporting: false, exportUrl: url));
      emit(state.copyWith(exportUrl: null));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(isExporting: false, saveError: message));
    } catch (e) {
      emit(state.copyWith(isExporting: false, saveError: e.toString()));
    }
  }

  Future<void> _onClearData(
    ClearData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, saveError: null));
    try {
      await settingsRepository.clearData(confirmation: event.confirmation);
      emit(state.copyWith(isSaving: false, dataCleared: true));
      emit(state.copyWith(dataCleared: false));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(isSaving: false, saveError: message));
    } catch (e) {
      emit(state.copyWith(isSaving: false, saveError: e.toString()));
    }
  }

  Future<void> _onLogout(
    SettingsLogout event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await settingsRepository.logout();
    emit(state.copyWith(isLoading: false, loggedOut: true));
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
