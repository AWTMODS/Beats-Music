import 'dart:async';
import 'dart:developer';

import 'package:beats_music/services/beats_music_updater_tools.dart';
import 'package:beats_music/services/db/GlobalDB.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  StreamSubscription? _subscription;
  NotificationCubit() : super(NotificationInitial()) {
    getLatestVersion().then((value) {
      if (value["results"]) {
        if (int.parse(value["currBuild"]) < int.parse(value["newBuild"])) {
          BeatsMusicDBService.putNotification(
            title: "Update Available",
            body:
                "New Version of Beats Music is now available!! Version: ${value["newVer"]} + ${value["newBuild"]}",
            type: "app_update",
            unique: true,
          );
        }
      }
    });
    getNotification();
  }
  void getNotification() async {
    List<NotificationDB> notifications =
        await BeatsMusicDBService.getNotifications();
    emit(NotificationState(notifications: notifications));
  }

  void clearNotification() {
    BeatsMusicDBService.clearNotifications();
    log("Notification Cleared");
    getNotification();
  }

  Future<void> watchNotification() async {
    _subscription =
        (await BeatsMusicDBService.watchNotification()).listen((event) {
      getNotification();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
