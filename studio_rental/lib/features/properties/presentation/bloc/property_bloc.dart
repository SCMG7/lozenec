import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';

// --- Events ---

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class LoadProperties extends PropertyEvent {
  const LoadProperties();
}

class CreateProperty extends PropertyEvent {
  final String name;
  final String? address;
  final String propertyType;
  final int defaultPricePerNight;
  final String checkInTime;
  final String checkOutTime;
  final String currency;

  const CreateProperty({
    required this.name,
    this.address,
    required this.propertyType,
    required this.defaultPricePerNight,
    required this.checkInTime,
    required this.checkOutTime,
    this.currency = 'EUR',
  });

  @override
  List<Object?> get props => [
        name,
        address,
        propertyType,
        defaultPricePerNight,
        checkInTime,
        checkOutTime,
        currency,
      ];
}

class UpdateProperty extends PropertyEvent {
  final String id;
  final String name;
  final String? address;
  final String propertyType;
  final int defaultPricePerNight;
  final String checkInTime;
  final String checkOutTime;
  final String currency;

  const UpdateProperty({
    required this.id,
    required this.name,
    this.address,
    required this.propertyType,
    required this.defaultPricePerNight,
    required this.checkInTime,
    required this.checkOutTime,
    this.currency = 'EUR',
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        propertyType,
        defaultPricePerNight,
        checkInTime,
        checkOutTime,
        currency,
      ];
}

class DeleteProperty extends PropertyEvent {
  final String id;

  const DeleteProperty({required this.id});

  @override
  List<Object?> get props => [id];
}

class SelectProperty extends PropertyEvent {
  final Property? property;

  const SelectProperty({this.property});

  @override
  List<Object?> get props => [property];
}

// --- State ---

class PropertyState extends Equatable {
  final List<Property> properties;
  final Property? activeProperty;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool saved;
  final bool deleted;

  const PropertyState({
    this.properties = const [],
    this.activeProperty,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.saved = false,
    this.deleted = false,
  });

  PropertyState copyWith({
    List<Property>? properties,
    Property? activeProperty,
    bool clearActiveProperty = false,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
    bool? saved,
    bool? deleted,
  }) {
    return PropertyState(
      properties: properties ?? this.properties,
      activeProperty: clearActiveProperty
          ? null
          : (activeProperty ?? this.activeProperty),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      saved: saved ?? false,
      deleted: deleted ?? false,
    );
  }

  @override
  List<Object?> get props => [
        properties,
        activeProperty,
        isLoading,
        isSaving,
        error,
        saved,
        deleted,
      ];
}

// --- BLoC ---

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final PropertyRepository propertyRepository;

  PropertyBloc({required this.propertyRepository})
      : super(const PropertyState()) {
    on<LoadProperties>(_onLoadProperties);
    on<CreateProperty>(_onCreateProperty);
    on<UpdateProperty>(_onUpdateProperty);
    on<DeleteProperty>(_onDeleteProperty);
    on<SelectProperty>(_onSelectProperty);
  }

  Future<void> _onLoadProperties(
      LoadProperties event, Emitter<PropertyState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final properties = await propertyRepository.getProperties();
      Property? active = state.activeProperty;
      if (active == null && properties.isNotEmpty) {
        active = properties.first;
      } else if (active != null) {
        // Make sure active property still exists in the list
        final found = properties.where((p) => p.id == active!.id);
        if (found.isEmpty && properties.isNotEmpty) {
          active = properties.first;
        } else if (found.isNotEmpty) {
          active = found.first;
        }
      }
      emit(state.copyWith(
        properties: properties,
        activeProperty: active,
        isLoading: false,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        error: 'network_error',
      ));
    }
  }

  Future<void> _onCreateProperty(
      CreateProperty event, Emitter<PropertyState> emit) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final property = await propertyRepository.createProperty(
        name: event.name,
        address: event.address,
        propertyType: event.propertyType,
        defaultPricePerNight: event.defaultPricePerNight,
        checkInTime: event.checkInTime,
        checkOutTime: event.checkOutTime,
        currency: event.currency,
      );
      final updatedList = [...state.properties, property];
      emit(state.copyWith(
        properties: updatedList,
        activeProperty: state.activeProperty ?? property,
        isSaving: false,
        saved: true,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: _extractErrorMessage(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        isSaving: false,
        error: 'network_error',
      ));
    }
  }

  Future<void> _onUpdateProperty(
      UpdateProperty event, Emitter<PropertyState> emit) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final property = await propertyRepository.updateProperty(
        event.id,
        name: event.name,
        address: event.address,
        propertyType: event.propertyType,
        defaultPricePerNight: event.defaultPricePerNight,
        checkInTime: event.checkInTime,
        checkOutTime: event.checkOutTime,
        currency: event.currency,
      );
      final updatedList = state.properties
          .map((p) => p.id == event.id ? property : p)
          .toList();
      final updatedActive =
          state.activeProperty?.id == event.id ? property : state.activeProperty;
      emit(state.copyWith(
        properties: updatedList,
        activeProperty: updatedActive,
        isSaving: false,
        saved: true,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: _extractErrorMessage(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        isSaving: false,
        error: 'network_error',
      ));
    }
  }

  Future<void> _onDeleteProperty(
      DeleteProperty event, Emitter<PropertyState> emit) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await propertyRepository.deleteProperty(event.id);
      final updatedList =
          state.properties.where((p) => p.id != event.id).toList();
      Property? newActive = state.activeProperty;
      if (state.activeProperty?.id == event.id) {
        newActive = updatedList.isNotEmpty ? updatedList.first : null;
      }
      emit(state.copyWith(
        properties: updatedList,
        activeProperty: newActive,
        clearActiveProperty: newActive == null,
        isSaving: false,
        deleted: true,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: _extractErrorMessage(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        isSaving: false,
        error: 'network_error',
      ));
    }
  }

  void _onSelectProperty(
      SelectProperty event, Emitter<PropertyState> emit) {
    emit(state.copyWith(
      activeProperty: event.property,
      clearActiveProperty: event.property == null,
    ));
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
