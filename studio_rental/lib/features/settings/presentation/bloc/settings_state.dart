part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final User? user;
  final bool isLoading;
  final bool isSaving;
  final bool isExporting;
  final String? passwordError;
  final String? saveError;
  final bool profileSaved;
  final bool passwordChanged;
  final String? exportUrl;
  final bool dataCleared;
  final bool loggedOut;

  const SettingsState({
    this.user,
    this.isLoading = false,
    this.isSaving = false,
    this.isExporting = false,
    this.passwordError,
    this.saveError,
    this.profileSaved = false,
    this.passwordChanged = false,
    this.exportUrl,
    this.dataCleared = false,
    this.loggedOut = false,
  });

  SettingsState copyWith({
    User? user,
    bool? isLoading,
    bool? isSaving,
    bool? isExporting,
    String? passwordError,
    String? saveError,
    bool? profileSaved,
    bool? passwordChanged,
    String? exportUrl,
    bool? dataCleared,
    bool? loggedOut,
  }) {
    return SettingsState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isExporting: isExporting ?? this.isExporting,
      passwordError: passwordError,
      saveError: saveError,
      profileSaved: profileSaved ?? this.profileSaved,
      passwordChanged: passwordChanged ?? this.passwordChanged,
      exportUrl: exportUrl,
      dataCleared: dataCleared ?? this.dataCleared,
      loggedOut: loggedOut ?? this.loggedOut,
    );
  }

  @override
  List<Object?> get props => [
        user,
        isLoading,
        isSaving,
        isExporting,
        passwordError,
        saveError,
        profileSaved,
        passwordChanged,
        exportUrl,
        dataCleared,
        loggedOut,
      ];
}
