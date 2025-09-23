import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';

part 'faq_event.dart';
part 'faq_state.dart';

class FaqBloc extends Bloc<FaqEvent, FaqState> {
  FaqBloc() : super(const FaqState()) {
    on<FaqLoaded>(_onFaqLoaded);
    on<FaqSearchChanged>(_onFaqSearchChanged);
    on<FaqCategoryChanged>(_onFaqCategoryChanged);
    on<FaqItemExpanded>(_onFaqItemExpanded);
    on<FaqItemCollapsed>(_onFaqItemCollapsed);
    on<FaqItemHelpful>(_onFaqItemHelpful);
    on<FaqItemNotHelpful>(_onFaqItemNotHelpful);
    on<FaqContactSupport>(_onFaqContactSupport);
  }

  Future<void> _onFaqLoaded(
    FaqLoaded event,
    Emitter<FaqState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    
    try {
      // In a real implementation, this would load FAQ data from API
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load FAQ: ${error.toString()}',
      ));
    }
  }

  void _onFaqSearchChanged(
    FaqSearchChanged event,
    Emitter<FaqState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: event.query,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onFaqCategoryChanged(
    FaqCategoryChanged event,
    Emitter<FaqState> emit,
  ) {
    emit(state.copyWith(
      selectedCategory: event.category,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onFaqItemExpanded(
    FaqItemExpanded event,
    Emitter<FaqState> emit,
  ) {
    final expandedItems = Set<String>.from(state.expandedItems);
    expandedItems.add(event.itemId);
    
    emit(state.copyWith(
      expandedItems: expandedItems,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onFaqItemCollapsed(
    FaqItemCollapsed event,
    Emitter<FaqState> emit,
  ) {
    final expandedItems = Set<String>.from(state.expandedItems);
    expandedItems.remove(event.itemId);
    
    emit(state.copyWith(
      expandedItems: expandedItems,
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onFaqItemHelpful(
    FaqItemHelpful event,
    Emitter<FaqState> emit,
  ) {
    // In a real implementation, this would track helpful feedback
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onFaqItemNotHelpful(
    FaqItemNotHelpful event,
    Emitter<FaqState> emit,
  ) {
    // In a real implementation, this would track not helpful feedback
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }

  void _onFaqContactSupport(
    FaqContactSupport event,
    Emitter<FaqState> emit,
  ) {
    // In a real implementation, this would open contact support
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
      clearError: true,
    ));
  }
}