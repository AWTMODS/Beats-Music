import 'package:beats_music/services/recommendation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'recommendation_state.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  final RecommendationService _recommendationService = RecommendationService();

  RecommendationCubit() : super(RecommendationInitial()) {
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    emit(RecommendationLoading());
    try {
      final recommendations = await _recommendationService.getRecommendations();
      if (recommendations.isEmpty) {
        emit(const RecommendationError("No recommendations found. Keep listening to get personalized suggestions!"));
      } else {
        emit(RecommendationSuccess(recommendations));
      }
    } catch (e) {
      emit(RecommendationError(e.toString()));
    }
  }
}
