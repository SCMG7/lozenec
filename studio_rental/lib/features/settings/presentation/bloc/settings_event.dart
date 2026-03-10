part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  final User user;

  const LoadSettings({required this.user});

  @override
  List<Object?> get props => [user];
}

class UpdateProfile extends SettingsEvent {
  final String fullName;
  final String email;

  const UpdateProfile({required this.fullName, required this.email});

  @override
  List<Object?> get props => [fullName, email];
}

class UpdateSettings extends SettingsEvent {
  final Map<String, dynamic> fields;

  const UpdateSettings({required this.fields});

  @override
  List<Object?> get props => [fields];
}

class ChangePassword extends SettingsEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmPassword];
}

class ExportData extends SettingsEvent {
  final String format;

  const ExportData({required this.format});

  @override
  List<Object?> get props => [format];
}

class ClearData extends SettingsEvent {
  final String confirmation;

  const ClearData({required this.confirmation});

  @override
  List<Object?> get props => [confirmation];
}

class SettingsLogout extends SettingsEvent {
  const SettingsLogout();
}
