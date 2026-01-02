import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationSuccess extends RecommendationState {
  final List<MediaItem> recommendations;

  const RecommendationSuccess(this.recommendations);

  @override
  List<Object?> get props => [recommendations];
}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);

  @override
  List<Object?> get props => [message];
}
