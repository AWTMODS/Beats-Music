import 'dart:developer';
import 'package:beats_music/repository/Youtube/youtube_api.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:beats_music/model/songModel.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'search_suggestion_event.dart';
part 'search_suggestion_state.dart';

class SearchSuggestionBloc
    extends Bloc<SearchSuggestionEvent, SearchSuggestionState> {
  SearchSuggestionBloc() : super(const SearchSuggestionLoading()) {
    on<SearchSuggestionFetch>((event, emit) async {
      final res1 = await getPastSearches(event.query);
      final richRes = await BeatsMusicDBService.getRichSearchHistory();
      
      // If query is empty, show history (both text and rich)
      // If query is NOT empty, we currently only show text suggestions (online + db)
      // But we always keep rich history in state just in case
      
      if (event.query.isEmpty) {
         emit(SearchSuggestionLoaded(const [], res1, richSuggestionList: richRes));
      } else {
         emit(SearchSuggestionLoaded(state.suggestionList, res1, richSuggestionList: richRes));
         final res2 = await getOnlineSearchSuggestions(event.query);
         emit(SearchSuggestionLoaded(res2, res1, richSuggestionList: richRes));
      }
    });

    on<SearchSuggestionClear>((event, emit) async {
      if (state is SearchSuggestionLoading) {
        return;
      }
      List<Map<String, String>> res = List.from(state.dbSuggestionList);
      try {
        final e = res.firstWhere((element) => element['query'] == event.query);
        if (e['id'] != null) {
          await BeatsMusicDBService.removeSearchHistory(e['id']!);
          res.remove(e);
          emit(SearchSuggestionLoaded(
            state.suggestionList,
            List<Map<String, String>>.from(res),
            richSuggestionList: state.richSuggestionList,
          ));
        }
      } catch (e) {
        log("Error Clearing Search History: $e", name: "SearchSuggestionBloc");
      }
    });

    on<SearchSuggestionAddRich>((event, emit) async {
      await BeatsMusicDBService.addToRichSearchHistory(event.item);
      final richRes = await BeatsMusicDBService.getRichSearchHistory();
      emit(state.copyWith(richSuggestionList: richRes));
    });

    on<SearchSuggestionRemoveRich>((event, emit) async {
      await BeatsMusicDBService.removeFromRichSearchHistory(event.id);
      final richRes = await BeatsMusicDBService.getRichSearchHistory();
      emit(state.copyWith(richSuggestionList: richRes));
    });
  }

  Future<List<String>> getOnlineSearchSuggestions(String query) async {
    List<String> searchSuggestions;
    if (query.isEmpty || query.replaceAll(" ", "").isEmpty) {
      return [];
    }
    try {
      searchSuggestions = await YouTubeServices()
          .getSearchSuggestions(query: query) as List<String>;
    } catch (e) {
      searchSuggestions = [];
    }
    return searchSuggestions;
  }

  Future<List<Map<String, String>>> getPastSearches(String query) async {
    List<Map<String, String>> searchSuggestions;
    if (query.isEmpty || query.replaceAll(" ", "").isEmpty) {
      List<Map<String, String>> res =
          await BeatsMusicDBService.getLastSearches(limit: 10);
      searchSuggestions = res;
      return searchSuggestions;
    }

    try {
      List<Map<String, String>> res =
          await BeatsMusicDBService.getSimilarSearches(query);
      searchSuggestions = res;
    } catch (e) {
      searchSuggestions = [];
    }
    return searchSuggestions;
  }
}
