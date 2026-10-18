part of 'search_suggestion_bloc.dart';

sealed class SearchSuggestionEvent extends Equatable {
  final String query;

  const SearchSuggestionEvent(
    this.query,
  );
  @override
  List<Object?> get props => [query];
}

final class SearchSuggestionFetch extends SearchSuggestionEvent {
  const SearchSuggestionFetch(String query) : super(query);
}

final class SearchSuggestionClear extends SearchSuggestionEvent {
  const SearchSuggestionClear(String query) : super(query);
}

final class SearchSuggestionSave extends SearchSuggestionEvent {
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final String? type;

  const SearchSuggestionSave(
    String query, {
    this.title,
    this.subtitle,
    this.imageUrl,
    this.type,
  }) : super(query);

  @override
  List<Object?> get props => [query, title, subtitle, imageUrl, type];
}
