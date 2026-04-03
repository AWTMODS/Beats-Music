import 'package:equatable/equatable.dart';
import 'package:beats_music/core/models/exported.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();

  @override
  List<Object?> get props => [];
}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<Track> tracks;
  final String title;

  const RecommendationLoaded({required this.tracks, required this.title});

  @override
  List<Object?> get props => [tracks, title];
}

class RecommendationError extends RecommendationState {
  final String message;

  const RecommendationError(this.message);

  @override
  List<Object?> get props => [message];
}
