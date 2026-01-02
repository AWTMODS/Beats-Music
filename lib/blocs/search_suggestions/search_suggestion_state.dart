// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'search_suggestion_bloc.dart';

class SearchSuggestionState extends Equatable {
  final List<String> suggestionList;
  final List<Map<String, String>> dbSuggestionList;
  final List<MediaItemModel> richSuggestionList;
  
  const SearchSuggestionState(this.suggestionList, this.dbSuggestionList, {this.richSuggestionList = const []});

  @override
  List<Object> get props => [
        suggestionList,
        dbSuggestionList,
        richSuggestionList,
        dbSuggestionList.length,
        suggestionList.length,
        richSuggestionList.length
      ];

  SearchSuggestionState copyWith({
    List<String>? suggestionList,
    List<Map<String, String>>? dbSuggestionList,
    List<MediaItemModel>? richSuggestionList,
  }) {
    return SearchSuggestionState(
      suggestionList ?? this.suggestionList,
      dbSuggestionList ?? this.dbSuggestionList,
      richSuggestionList: richSuggestionList ?? this.richSuggestionList,
    );
  }
}

final class SearchSuggestionLoading extends SearchSuggestionState {
  const SearchSuggestionLoading() : super(const [], const []);
}

final class SearchSuggestionLoaded extends SearchSuggestionState {
  const SearchSuggestionLoaded(
      List<String> suggestionList, 
      List<Map<String, String>> dbSuggestionList,
      {List<MediaItemModel> richSuggestionList = const []})
      : super(suggestionList, dbSuggestionList, richSuggestionList: richSuggestionList);
}
