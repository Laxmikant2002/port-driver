part of 'faq_bloc.dart';

/// FAQ state containing FAQ data and UI state
final class FaqState extends Equatable {
  const FaqState({
    this.status = FormzSubmissionStatus.initial,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.expandedItems = const {},
    this.categories = const [
      'All',
      'Getting Started',
      'Account & Profile',
      'Rides & Bookings',
      'Payments & Earnings',
      'Documents & Verification',
      'Technical Issues',
      'Safety & Security',
    ],
    this.faqItems = const [],
    this.errorMessage,
  });

  final FormzSubmissionStatus status;
  final String searchQuery;
  final String selectedCategory;
  final Set<String> expandedItems;
  final List<String> categories;
  final List<FaqItem> faqItems;
  final String? errorMessage;

  /// Returns true if FAQ is currently being loaded
  bool get isLoading => status == FormzSubmissionStatus.inProgress;

  /// Returns true if FAQ was loaded successfully
  bool get isSuccess => status == FormzSubmissionStatus.success;

  /// Returns true if FAQ operation failed
  bool get isFailure => status == FormzSubmissionStatus.failure;

  /// Returns true if there's an error message
  bool get hasError => isFailure && errorMessage != null;

  /// Returns filtered FAQ items based on search and category
  List<FaqItem> get filteredFaqItems {
    List<FaqItem> filtered = faqItems;
    
    // Filter by category
    if (selectedCategory != 'All') {
      filtered = filtered.where((item) => item.category == selectedCategory).toList();
    }
    
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((item) => 
        item.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
        item.answer.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  /// Returns true if an FAQ item is expanded
  bool isItemExpanded(String itemId) => expandedItems.contains(itemId);

  FaqState copyWith({
    FormzSubmissionStatus? status,
    String? searchQuery,
    String? selectedCategory,
    Set<String>? expandedItems,
    List<String>? categories,
    List<FaqItem>? faqItems,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FaqState(
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      expandedItems: expandedItems ?? this.expandedItems,
      categories: categories ?? this.categories,
      faqItems: faqItems ?? this.faqItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        searchQuery,
        selectedCategory,
        expandedItems,
        categories,
        faqItems,
        errorMessage,
      ];

  @override
  String toString() {
    return 'FaqState('
        'status: $status, '
        'searchQuery: $searchQuery, '
        'selectedCategory: $selectedCategory, '
        'expandedItems: ${expandedItems.length}, '
        'faqItems: ${faqItems.length}, '
        'errorMessage: $errorMessage'
        ')';
  }
}

/// Model representing an FAQ item
class FaqItem extends Equatable {
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.tags = const [],
    this.isHelpful = false,
    this.isNotHelpful = false,
  });

  final String id;
  final String question;
  final String answer;
  final String category;
  final List<String> tags;
  final bool isHelpful;
  final bool isNotHelpful;

  FaqItem copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    List<String>? tags,
    bool? isHelpful,
    bool? isNotHelpful,
  }) {
    return FaqItem(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isHelpful: isHelpful ?? this.isHelpful,
      isNotHelpful: isNotHelpful ?? this.isNotHelpful,
    );
  }

  @override
  List<Object?> get props => [id, question, answer, category, tags, isHelpful, isNotHelpful];

  @override
  String toString() {
    return 'FaqItem(id: $id, question: $question, category: $category)';
  }
}