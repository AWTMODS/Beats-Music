import 'package:beats_music/routes_and_consts/global_str_consts.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';

Future<Map<String, String>> initializeHeaders({String language = 'en'}) async {
  Map<String, String> h = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    'accept': '*/*',
    'accept-encoding': 'gzip, deflate',
    'content-type': 'application/json',
    'content-encoding': 'gzip',
    "Origin": "https://music.youtube.com",
    'cookie': 'CONSENT=YES+1',
    'Accept-Language': language,
  };
  // String? visitorId = Hive.box('SETTINGS').get('VISITOR_ID');
  String? visitorId = await BeatsMusicDBService.getAPICache("VISITOR_ID");
  if (visitorId != null) {
    h['X-Goog-Visitor-Id'] = visitorId;
  }
  return h;
}

Future<Map<String, dynamic>> initializeContext({String language = 'en'}) async {
  final DateTime now = DateTime.now();
  final String year = now.year.toString();
  final String month = now.month.toString().padLeft(2, '0');
  final String day = now.day.toString().padLeft(2, '0');
  final String date = year + month + day;
  return {
    'context': {
      'client': {
        "hl": language,
        "gl": await BeatsMusicDBService.getSettingStr(GlobalStrConsts.countryCode,
            defaultValue: "IN"),
        'clientName': 'ANDROID_MUSIC',
        'clientVersion': '6.01.55',
      },
      'user': {}
    }
  };
}

dynamic nav(dynamic root, List<dynamic> items, {bool noneIfAbsent = false}) {
  try {
    for (var k in items) {
      root = root?[k];
    }
    return root;
  } catch (err) {
    if (noneIfAbsent) {
      return null;
    } else {
      rethrow;
    }
  }
}

String getContinuationString(dynamic ctoken) {
  return "&ctoken=$ctoken&continuation=$ctoken";
}
