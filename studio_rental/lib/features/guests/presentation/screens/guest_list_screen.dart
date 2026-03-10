import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/empty_state_widget.dart';
import 'package:studio_rental/core/widgets/error_state_widget.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import '../../domain/repositories/guest_repository.dart';
import '../bloc/guest_list_bloc.dart';
import '../widgets/guest_list_tile.dart';

class GuestListScreen extends StatefulWidget {
  const GuestListScreen({super.key});

  @override
  State<GuestListScreen> createState() => _GuestListScreenState();
}

class _GuestListScreenState extends State<GuestListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<GuestListBloc>().add(const LoadGuests());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<GuestListBloc>().state;
      if (state.hasMore && !state.isLoading) {
        context.read<GuestListBloc>().add(const LoadMore());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.guest_list_title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.addGuest);
          if (result == true && mounted) {
            context.read<GuestListBloc>().add(const RefreshGuests());
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          _buildFilterTabs(l10n),
          _buildSortDropdown(l10n),
          Expanded(child: _buildGuestList(l10n)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.guest_list_search_hint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: BlocBuilder<GuestListBloc, GuestListState>(
            buildWhen: (prev, curr) =>
                prev.searchQuery != curr.searchQuery,
            builder: (context, state) {
              if (state.searchQuery.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<GuestListBloc>()
                        .add(const SearchGuests(query: ''));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          context.read<GuestListBloc>().add(SearchGuests(query: value));
        },
      ),
    );
  }

  Widget _buildFilterTabs(AppLocalizations l10n) {
    final filters = <GuestFilter, String>{
      GuestFilter.all: l10n.guest_list_filter_all,
      GuestFilter.upcoming: l10n.guest_list_filter_upcoming,
      GuestFilter.past: l10n.guest_list_filter_past,
      GuestFilter.cancelled: l10n.guest_list_filter_cancelled,
    };

    return BlocBuilder<GuestListBloc, GuestListState>(
      buildWhen: (prev, curr) => prev.activeFilter != curr.activeFilter,
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: filters.entries.map((entry) {
              final isActive = state.activeFilter == entry.key;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(entry.value),
                  selected: isActive,
                  onSelected: (_) {
                    context
                        .read<GuestListBloc>()
                        .add(ChangeFilter(filter: entry.key));
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSortDropdown(AppLocalizations l10n) {
    final sortOptions = <GuestSort, String>{
      GuestSort.nameAsc: l10n.guest_list_sort_name,
      GuestSort.mostRecent: l10n.guest_list_sort_recent,
      GuestSort.mostNights: l10n.guest_list_sort_nights,
    };

    return BlocBuilder<GuestListBloc, GuestListState>(
      buildWhen: (prev, curr) => prev.sortBy != curr.sortBy,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.sort, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              DropdownButton<GuestSort>(
                value: state.sortBy,
                underline: const SizedBox.shrink(),
                style: AppTextStyles.bodySmall,
                items: sortOptions.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<GuestListBloc>()
                        .add(ChangeSort(sort: value));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuestList(AppLocalizations l10n) {
    return BlocBuilder<GuestListBloc, GuestListState>(
      builder: (context, state) {
        if (state.isLoading && state.guests.isEmpty) {
          return const LoadingIndicator();
        }

        if (state.error != null && state.guests.isEmpty) {
          return ErrorStateWidget(
            message: l10n.guest_list_error_load,
            buttonText: l10n.action_retry,
            onRetry: () {
              context.read<GuestListBloc>().add(const LoadGuests());
            },
          );
        }

        if (state.guests.isEmpty) {
          final isEmpty = state.searchQuery.isEmpty;
          return EmptyStateWidget(
            icon: Icons.people_outline,
            message: isEmpty
                ? l10n.guest_list_empty
                : l10n.guest_list_empty_search,
            actionText: isEmpty ? l10n.guest_list_add_guest : null,
            onAction: isEmpty
                ? () async {
                    final result = await Navigator.pushNamed(
                        context, AppRoutes.addGuest);
                    if (result == true && mounted) {
                      context
                          .read<GuestListBloc>()
                          .add(const RefreshGuests());
                    }
                  }
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<GuestListBloc>().add(const RefreshGuests());
            await context.read<GuestListBloc>().stream.firstWhere(
                  (s) => !s.isRefreshing,
                );
          },
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.guests.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 72,
              color: AppColors.divider,
            ),
            itemBuilder: (context, index) {
              if (index >= state.guests.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: LoadingIndicator(size: 20),
                );
              }
              final guest = state.guests[index];
              return GuestListTile(
                guest: guest,
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.guestDetail,
                    arguments: guest.id,
                  );
                  if (result == true && mounted) {
                    context
                        .read<GuestListBloc>()
                        .add(const RefreshGuests());
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
