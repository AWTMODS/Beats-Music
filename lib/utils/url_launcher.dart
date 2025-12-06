import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

Future<void> launch_Url(var _url) async {
  Uri uri;
  if (_url is Uri) {
    uri = _url;
  } else {
    uri = Uri.parse(_url.toString());
  }
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    log('Could not launch $_url', name: "launch_Url");
  }
}
