part of 'faq_bloc.dart';

/// Base class for all FAQ events
sealed class FaqEvent extends Equatable {
  const FaqEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when FAQ data is loaded
final class FaqLoaded extends FaqEvent {
  const FaqLoaded();

  @override
  String toString() => 'FaqLoaded()';
}

/// Event triggered when search query is changed
final class FaqSearchChanged extends FaqEvent {
  const FaqSearchChanged(this.query);

  final String query;

  @override
  List<Object> get props => [query];

  @override
  String toString() => 'FaqSearchChanged(query: $query)';
}

/// Event triggered when FAQ category is changed
final class FaqCategoryChanged extends FaqEvent {
  const FaqCategoryChanged(this.category);

  final String category;

  @override
  List<Object> get props => [category];

  @override
  String toString() => 'FaqCategoryChanged(category: $category)';
}

/// Event triggered when FAQ item is expanded
final class FaqItemExpanded extends FaqEvent {
  const FaqItemExpanded(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];

  @override
  String toString() => 'FaqItemExpanded(itemId: $itemId)';
}

/// Event triggered when FAQ item is collapsed
final class FaqItemCollapsed extends FaqEvent {
  const FaqItemCollapsed(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];

  @override
  String toString() => 'FaqItemCollapsed(itemId: $itemId)';
}

/// Event triggered when FAQ item is marked as helpful
final class FaqItemHelpful extends FaqEvent {
  const FaqItemHelpful(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];

  @override
  String toString() => 'FaqItemHelpful(itemId: $itemId)';
}

/// Event triggered when FAQ item is marked as not helpful
final class FaqItemNotHelpful extends FaqEvent {
  const FaqItemNotHelpful(this.itemId);

  final String itemId;

  @override
  List<Object> get props => [itemId];

  @override
  String toString() => 'FaqItemNotHelpful(itemId: $itemId)';
}

/// Event triggered when contact support is requested
final class FaqContactSupport extends FaqEvent {
  const FaqContactSupport();

  @override
  String toString() => 'FaqContactSupport()';
}