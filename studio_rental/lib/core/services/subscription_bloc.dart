import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'subscription_service.dart';

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

class CheckSubscription extends SubscriptionEvent {
  const CheckSubscription();
}

class PurchaseMonthly extends SubscriptionEvent {
  const PurchaseMonthly();
}

class PurchaseAnnual extends SubscriptionEvent {
  const PurchaseAnnual();
}

class RestorePurchases extends SubscriptionEvent {
  const RestorePurchases();
}

// State
class SubscriptionState extends Equatable {
  final bool isPro;
  final DateTime? expiresAt;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.isPro = false,
    this.expiresAt,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isPro,
    DateTime? expiresAt,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SubscriptionState(
      isPro: isPro ?? this.isPro,
      expiresAt: expiresAt ?? this.expiresAt,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [isPro, expiresAt, isLoading, error];
}

// BLoC
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc() : super(const SubscriptionState()) {
    on<CheckSubscription>(_onCheck);
    on<PurchaseMonthly>(_onPurchaseMonthly);
    on<PurchaseAnnual>(_onPurchaseAnnual);
    on<RestorePurchases>(_onRestore);
  }

  Future<void> _onCheck(
    CheckSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    await SubscriptionService.instance.checkEntitlements();
    emit(state.copyWith(
      isPro: SubscriptionService.instance.isPro,
      expiresAt: SubscriptionService.instance.proExpiresAt,
    ));
  }

  Future<void> _onPurchaseMonthly(
    PurchaseMonthly event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await SubscriptionService.instance.purchaseMonthly();
    emit(state.copyWith(
      isLoading: false,
      isPro: SubscriptionService.instance.isPro,
      expiresAt: SubscriptionService.instance.proExpiresAt,
      error: result == PurchaseResult.error ? 'purchase_failed' : null,
    ));
  }

  Future<void> _onPurchaseAnnual(
    PurchaseAnnual event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await SubscriptionService.instance.purchaseAnnual();
    emit(state.copyWith(
      isLoading: false,
      isPro: SubscriptionService.instance.isPro,
      expiresAt: SubscriptionService.instance.proExpiresAt,
      error: result == PurchaseResult.error ? 'purchase_failed' : null,
    ));
  }

  Future<void> _onRestore(
    RestorePurchases event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await SubscriptionService.instance.restorePurchases();
    emit(state.copyWith(
      isLoading: false,
      isPro: SubscriptionService.instance.isPro,
      expiresAt: SubscriptionService.instance.proExpiresAt,
    ));
  }
}
