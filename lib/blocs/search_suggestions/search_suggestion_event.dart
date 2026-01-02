part of 'search_suggestion_bloc.dart';



sealed class SearchSuggestionEvent extends Equatable {
  final String query;

  const SearchSuggestionEvent(
    this.query,
  );
  @override
  List<Object> get props => [query];
}

final class SearchSuggestionFetch extends SearchSuggestionEvent {
  const SearchSuggestionFetch(String query) : super(query);
}

final class SearchSuggestionClear extends SearchSuggestionEvent {
  const SearchSuggestionClear(String query) : super(query);
}

final class SearchSuggestionAddRich extends SearchSuggestionEvent {
  final MediaItemModel item;
  const SearchSuggestionAddRich(this.item) : super('');
  @override
  List<Object> get props => [item];
}

final class SearchSuggestionRemoveRich extends SearchSuggestionEvent {
  final String id;
  const SearchSuggestionRemoveRich(this.id) : super(id);
}
