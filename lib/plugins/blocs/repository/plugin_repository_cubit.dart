import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/plugins/models/plugin_repository.dart';
import 'package:beats_music/plugins/services/plugin_repository_service.dart';

abstract class PluginRepositoryState {}

class PluginRepositoryInitial extends PluginRepositoryState {}

class PluginRepositoryLoading extends PluginRepositoryState {}

class PluginRepositoryLoaded extends PluginRepositoryState {
  final List<PluginRepositoryModel> repositories;
  PluginRepositoryLoaded(this.repositories);
}

class PluginRepositoryError extends PluginRepositoryState {
  final String message;
  PluginRepositoryError(this.message);
}

class PluginRepositoryCubit extends Cubit<PluginRepositoryState> {
  final PluginRepositoryService _service;

  PluginRepositoryCubit(this._service) : super(PluginRepositoryInitial());

  @override
  void emit(PluginRepositoryState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> loadRepositories() async {
    if (isClosed) return;
    emit(PluginRepositoryLoading());
    try {
      final urls = await _service.getSavedRepositoryUrls();
      if (isClosed) return;
      if (urls.isEmpty) {
        emit(PluginRepositoryLoaded([]));
        return;
      }

      final List<PluginRepositoryModel> results = [];
      for (final url in urls) {
        if (isClosed) return;
        try {
          final repo = await _service.fetchRepository(url);
          results.add(repo);
        } catch (e) {
          log('Error fetching repo $url: $e');
          // We can still add a "failed" placeholder or just skip
        }
      }

      if (isClosed) return;
      emit(PluginRepositoryLoaded(results));
    } catch (e) {
      if (isClosed) return;
      emit(PluginRepositoryError('Failed to load repositories: $e'));
    }
  }

  Future<void> addRepository(String url) async {
    if (isClosed) return;
    try {
      emit(PluginRepositoryLoading());
      // First verify it's valid
      await _service.fetchRepository(url);
      if (isClosed) return;
      await _service.addRepositoryUrl(url);
      if (isClosed) return;
      await loadRepositories();
    } catch (e) {
      if (isClosed) return;
      emit(PluginRepositoryError('Invalid repository: $e'));
      // try reloading to restore previous state
      await loadRepositories();
    }
  }

  Future<void> removeRepository(String url) async {
    if (isClosed) return;
    try {
      emit(PluginRepositoryLoading());
      await _service.removeRepositoryUrl(url);
      if (isClosed) return;
      await loadRepositories();
    } catch (e) {
      if (isClosed) return;
      emit(PluginRepositoryError('Failed to remove repository: $e'));
      await loadRepositories();
    }
  }
}


