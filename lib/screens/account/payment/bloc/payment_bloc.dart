import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_repo/finance_repo.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({required this.financeRepo}) : super(const PaymentState()) {
    on<PaymentAmountChanged>(_onAmountChanged);
    on<PaymentDescriptionChanged>(_onDescriptionChanged);
    on<PaymentMethodChanged>(_onPaymentMethodChanged);
    on<PaymentSubmitted>(_onSubmitted);
    on<PaymentHistoryLoaded>(_onHistoryLoaded);
    on<PaymentRefreshRequested>(_onRefreshRequested);
  }

  final FinanceRepo financeRepo;

  void _onAmountChanged(
    PaymentAmountChanged event,
    Emitter<PaymentState> emit,
  ) {
    final amount = Amount.dirty(event.amount);
    emit(
      state.copyWith(
        amount: amount,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onDescriptionChanged(
    PaymentDescriptionChanged event,
    Emitter<PaymentState> emit,
  ) {
    final description = Description.dirty(event.description);
    emit(
      state.copyWith(
        description: description,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onPaymentMethodChanged(
    PaymentMethodChanged event,
    Emitter<PaymentState> emit,
  ) {
    final paymentMethod = PaymentMethod.dirty(event.paymentMethod);
    emit(
      state.copyWith(
        paymentMethod: paymentMethod,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    PaymentSubmitted event,
    Emitter<PaymentState> emit,
  ) async {
    // Validate all fields before submission
    final amount = Amount.dirty(state.amount.value);
    final description = Description.dirty(state.description.value);
    final paymentMethod = PaymentMethod.dirty(state.paymentMethod.value);

    emit(state.copyWith(
      amount: amount,
      description: description,
      paymentMethod: paymentMethod,
      status: FormzSubmissionStatus.initial,
    ));

    if (!state.isValid) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Please complete all required fields correctly',
      ));
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      // Create payment request
      final paymentRequest = PaymentRequest(
        amount: double.tryParse(amount.value) ?? 0.0,
        description: description.value,
        paymentMethod: paymentMethod.value,
        metadata: event.metadata,
      );

      // Process payment using finance repo
      final response = await financeRepo.processPayment(paymentRequest);
      
      if (response.success) {
        emit(state.copyWith(status: FormzSubmissionStatus.success));
        // Reload history after successful payment
        add(const PaymentHistoryLoaded());
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to process payment. Please try again.',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error. Please try again.',
      ));
    }
  }

  Future<void> _onHistoryLoaded(
    PaymentHistoryLoaded event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // Get payment history
      final response = await financeRepo.getPaymentHistory(
        limit: event.limit ?? 50,
        offset: event.offset ?? 0,
      );
      
      if (response.success && response.payments != null) {
        emit(state.copyWith(
          paymentHistory: response.payments!,
          status: FormzSubmissionStatus.success,
          clearError: true,
        ));
      } else {
        emit(state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: response.message ?? 'Failed to load payment history',
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Network error: ${error.toString()}',
      ));
    }
  }

  Future<void> _onRefreshRequested(
    PaymentRefreshRequested event,
    Emitter<PaymentState> emit,
  ) async {
    // Refresh payment history
    add(const PaymentHistoryLoaded());
  }
}
