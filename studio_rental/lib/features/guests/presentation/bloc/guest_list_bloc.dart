import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/guest_list_item.dart';
import '../../domain/repositories/guest_repository.dart';

// --- Events ---

abstract class GuestListEvent extends Equatable {
  const GuestListEvent();

  @override
  List<Object?> get props => [];
}

class LoadGuests extends GuestListEvent {
  const LoadGuests();
}

class RefreshGuests extends GuestListEvent {
  const RefreshGuests();
}

class SearchGuests extends GuestListEvent {
  final String query;

  const SearchGuests({required this.query});

  @override
  List<Object?> get props => [query];
}

class ChangeFilter extends GuestListEvent {
  final GuestFilter filter;

  const ChangeFilter({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class ChangeSort extends GuestListEvent {
  final GuestSort sort;

  const ChangeSort({required this.sort});

  @override
  List<Object?> get props => [sort];
}

class LoadMore extends GuestListEvent {
  const LoadMore();
}

// --- State ---

class GuestListState extends Equatable {
  final List<GuestListItem> guests;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String searchQuery;
  final GuestFilter activeFilter;
  final GuestSort sortBy;
  final int currentPage;
  final bool hasMore;

  const GuestListState({
    this.guests = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.searchQuery = '',
    this.activeFilter = GuestFilter.all,
    this.sortBy = GuestSort.nameAsc,
    this.currentPage = 1,
    this.hasMore = true,
  });

  GuestListState copyWith({
    List<GuestListItem>? guests,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    String? searchQuery,
    GuestFilter? activeFilter,
    GuestSort? sortBy,
    int? currentPage,
    bool? hasMore,
  }) {
    return GuestListState(
      guests: guests ?? this.guests,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      sortBy: sortBy ?? this.sortBy,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [
        guests,
        isLoading,
        isRefreshing,
        error,
        searchQuery,
        activeFilter,
        sortBy,
        currentPage,
        hasMore,
      ];
}

// --- BLoC ---

class GuestListBloc extends Bloc<GuestListEvent, GuestListState> {
  final GuestRepository guestRepository;

  static const int _pageSize = 20;

  GuestListBloc({required this.guestRepository})
      : super(const GuestListState()) {
    on<LoadGuests>(_onLoadGuests);
    on<RefreshGuests>(_onRefreshGuests);
    on<SearchGuests>(_onSearchGuests);
    on<ChangeFilter>(_onChangeFilter);
    on<ChangeSort>(_onChangeSort);
    on<LoadMore>(_onLoadMore);
  }

  Future<void> _onLoadGuests(
      LoadGuests event, Emitter<GuestListState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final guests = await guestRepository.getGuests(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        filter: state.activeFilter,
        sort: state.sortBy,
        page: 1,
      );
      emit(state.copyWith(
        guests: guests,
        isLoading: false,
        currentPage: 1,
        hasMore: guests.length >= _pageSize,
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

  Future<void> _onRefreshGuests(
      RefreshGuests event, Emitter<GuestListState> emit) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));
    try {
      final guests = await guestRepository.getGuests(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        filter: state.activeFilter,
        sort: state.sortBy,
        page: 1,
      );
      emit(state.copyWith(
        guests: guests,
        isRefreshing: false,
        currentPage: 1,
        hasMore: guests.length >= _pageSize,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        error: _extractErrorMessage(e),
      ));
    } catch (_) {
      emit(state.copyWith(
        isRefreshing: false,
        error: 'network_error',
      ));
    }
  }

  Future<void> _onSearchGuests(
      SearchGuests event, Emitter<GuestListState> emit) async {
    emit(state.copyWith(
      searchQuery: event.query,
      isLoading: true,
      clearError: true,
    ));
    try {
      final guests = await guestRepository.getGuests(
        search: event.query.isNotEmpty ? event.query : null,
        filter: state.activeFilter,
        sort: state.sortBy,
        page: 1,
      );
      emit(state.copyWith(
        guests: guests,
        isLoading: false,
        currentPage: 1,
        hasMore: guests.length >= _pageSize,
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

  Future<void> _onChangeFilter(
      ChangeFilter event, Emitter<GuestListState> emit) async {
    emit(state.copyWith(
      activeFilter: event.filter,
      isLoading: true,
      clearError: true,
    ));
    try {
      final guests = await guestRepository.getGuests(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        filter: event.filter,
        sort: state.sortBy,
        page: 1,
      );
      emit(state.copyWith(
        guests: guests,
        isLoading: false,
        currentPage: 1,
        hasMore: guests.length >= _pageSize,
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

  Future<void> _onChangeSort(
      ChangeSort event, Emitter<GuestListState> emit) async {
    emit(state.copyWith(
      sortBy: event.sort,
      isLoading: true,
      clearError: true,
    ));
    try {
      final guests = await guestRepository.getGuests(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        filter: state.activeFilter,
        sort: event.sort,
        page: 1,
      );
      emit(state.copyWith(
        guests: guests,
        isLoading: false,
        currentPage: 1,
        hasMore: guests.length >= _pageSize,
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

  Future<void> _onLoadMore(
      LoadMore event, Emitter<GuestListState> emit) async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoading: true));
    try {
      final guests = await guestRepository.getGuests(
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        filter: state.activeFilter,
        sort: state.sortBy,
        page: nextPage,
      );
      emit(state.copyWith(
        guests: [...state.guests, ...guests],
        isLoading: false,
        currentPage: nextPage,
        hasMore: guests.length >= _pageSize,
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
