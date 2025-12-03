import 'dart:developer';

import 'package:beats_music/routes_and_consts/global_str_consts.dart';
import 'package:beats_music/services/beats_music_updater_tools.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_events_state.dart';

class GlobalEventsCubit extends Cubit<GlobalEventsState> {
  GlobalEventsCubit() : super(GlobalEventsInitial()) {
    // checkForUpdates(); // Disabled for v1.0.0(beta)
  }

  void checkForUpdates() async {
    final Map<String, dynamic> updates = await getAppUpdates();
    log("Checking for updates...", name: 'GlobalEventsCubit');

    if (updates['changelogs'] != null) {
      emit(WhatIsNewState(changeLogs: updates['changelogs']));
    }

    if (await BeatsMusicDBService.getSettingBool(
            GlobalStrConsts.autoUpdateNotify) ??
        true) {
      if (updates["results"]) {
        emit(UpdateAvailable(
          newVersion: updates["newVer"],
          message:
              "New Version of Beats Music is now available!!\n\nVersion: ${updates["newVer"]} + ${updates["newBuild"]}",
          downloadUrl: "https://github.com/AWTMODS/Beats-Music/releases",
        ));
      }
    }
  }

  void showAlertDialog(String title, String content) {
    emit(AlertDialogState(title: title, content: content));
  }
}
