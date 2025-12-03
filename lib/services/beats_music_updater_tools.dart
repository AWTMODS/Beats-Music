import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:beats_music/routes_and_consts/global_str_consts.dart';
import 'package:beats_music/services/db/beats_music_db_service.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

bool isUpdateAvailable(
    String currentVer, String currentBuild, String newVer, String newBuild,
    {bool checkBuild = true}) {
  // Normalize versions and builds and compare component-wise.
  List<int> parseVersion(String v) {
    v = v.replaceFirst(RegExp(r'^v'), '');
    final parts = v.split('.');
    return parts.map((p) {
      final m = RegExp(r'^(\d+)').firstMatch(p);
      return m != null ? int.parse(m.group(1)!) : 0;
    }).toList();
  }

  List<int> currentParts = parseVersion(currentVer);
  List<int> newParts = parseVersion(newVer);

  final maxLen = currentParts.length > newParts.length
      ? currentParts.length
      : newParts.length;
  for (int i = 0; i < maxLen; i++) {
    final cur = i < currentParts.length ? currentParts[i] : 0;
    final neu = i < newParts.length ? newParts[i] : 0;
    if (neu > cur) return true;
    if (neu < cur) return false;
  }

  if (checkBuild && !Platform.isLinux) {
    int parseBuild(String b) {
      try {
        final parsed = int.parse(b);
        return parsed > 1000 ? parsed % 1000 : parsed;
      } catch (_) {
        final m = RegExp(r'(\d+)').firstMatch(b);
        return m != null ? int.parse(m.group(1)!) : 0;
      }
    }

    final curBuild = parseBuild(currentBuild);
    final newBuildNum = parseBuild(newBuild);
    if (newBuildNum > curBuild) return true;
    if (newBuildNum < curBuild) return false;
  }

  return false;
}

Future<Map<String, dynamic>> customUpdate(
    {Duration timeout = const Duration(seconds: 6)}) async {
  String platform = Platform.operatingSystem;
  if (platform != 'linux' && platform != 'android' && platform != 'win') {
    // normalize unknowns to win for matching
    platform = 'win';
  }
  const url =
      'https://raw.githubusercontent.com/AWTMODS/Beats-Music/main/update.json';
  
  // GitHub raw doesn't strictly require these specific headers, but good to have a UA.
  final headers = {
    'user-agent': 'BeatsMusic/1.0.0',
    'accept': 'application/json',
  };

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  try {
    final response =
        await http.get(Uri.parse(url), headers: headers).timeout(timeout);
    log("Custom update response status code: ${response.statusCode}",
        name: 'UpdaterTools');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Prefer platform-specific release entry when available
      String platformKey = 'windows';
      if (Platform.isLinux) {
        platformKey = 'linux';
      } else if (Platform.isMacOS) {
        platformKey = 'mac';
      } else if (Platform.isAndroid) {
        platformKey = 'android';
      }

      Map? entry = (data['platform_releases'] is Map)
          ? (data['platform_releases'] as Map)[platformKey]
          : null;
      entry ??= data['release'];

      // extract url/filename from the chosen entry first, fall back to release
      final releaseUrl = (entry != null && entry['url'] != null)
          ? entry['url'] as String
          : (data['release']?['url'] ?? '');
      String filename = (entry != null && entry['filename'] != null)
          ? entry['filename'] as String
          : (data['release']?['filename'] ?? '');

      // decode percent-encoding and normalize
      try {
        filename = Uri.decodeFull(filename);
      } catch (_) {}
      String decodedUrl = releaseUrl;
      try {
        decodedUrl = Uri.decodeFull(releaseUrl);
      } catch (_) {}

      // try to find version/build in filename, then url
      final versionRegex = RegExp(r'v(\d+(?:\.\d+)*)');
      final buildRegex = RegExp(r'\+(\d+)');

      Match? versionMatch = versionRegex.firstMatch(filename);
      versionMatch ??= versionRegex.firstMatch(decodedUrl);
      Match? buildMatch = buildRegex.firstMatch(filename);
      buildMatch ??= buildRegex.firstMatch(decodedUrl);

      final version = versionMatch?.group(1) ?? '';
      final build = buildMatch?.group(1) ?? '';

      return {
        'source': 'custom',
        'newVer': version,
        'newBuild': build,
        'download_url': releaseUrl,
        'currVer': packageInfo.version,
        'currBuild': (int.tryParse(packageInfo.buildNumber) ?? 0) > 1000
            ? ((int.tryParse(packageInfo.buildNumber) ?? 0) % 1000).toString()
            : packageInfo.buildNumber,
        'results': isUpdateAvailable(
          packageInfo.version,
          packageInfo.buildNumber,
          version.isNotEmpty ? version : '0.0.0',
          build.isNotEmpty ? build : '0',
          checkBuild: platform == 'linux' ? false : true,
        ),
      };
    } else {
      throw Exception('Custom update returned ${response.statusCode}');
    }
  } catch (e, st) {
    log('Custom update check failed: $e\n$st', name: 'UpdaterTools');
    rethrow;
  }
}

Future<Map<String, dynamic>> githubUpdate(
    {Duration timeout = const Duration(seconds: 6)}) async {
  final url =
      'https://api.github.com/repos/AWTMODS/Beats-Music/releases/latest';
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  try {
    final response = await http.get(Uri.parse(url)).timeout(timeout);
    log("GitHub response status code: ${response.statusCode}",
        name: 'UpdaterTools');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final tag = (data['tag_name'] as String?) ?? '';
      // tag might be like v2.7.11+12 or v2.7.11
      final tagParts = tag.split('+');
      final versionPart =
          tagParts.isNotEmpty ? tagParts[0].replaceFirst('v', '') : '';
      final buildPart = tagParts.length > 1 ? tagParts[1] : '';

      // Attempt to extract download url from assets if possible
      String? download = extractUpUrl(data);
      download ??= data['html_url'] ?? '';

      return {
        'source': 'github',
        'newVer': versionPart,
        'newBuild': buildPart,
        'download_url': download,
        'currVer': packageInfo.version,
        'currBuild': (int.tryParse(packageInfo.buildNumber) ?? 0) > 1000
            ? ((int.tryParse(packageInfo.buildNumber) ?? 0) % 1000).toString()
            : packageInfo.buildNumber,
        'results': isUpdateAvailable(
          packageInfo.version,
          packageInfo.buildNumber,
          versionPart.isNotEmpty ? versionPart : '0.0.0',
          buildPart.isNotEmpty ? buildPart : '0',
          checkBuild: true,
        ),
      };
    } else {
      throw Exception('GitHub returned ${response.statusCode}');
    }
  } catch (e, st) {
    log('GitHub update check failed: $e\n$st', name: 'UpdaterTools');
    rethrow;
  }
}

/// New public API: try GitHub first, then SourceForge; return a consistent map.
Future<Map<String, dynamic>> getAppUpdates() async {
  // Try Custom JSON update first.
  Map<String, dynamic> updates;
  try {
    updates = await customUpdate();
  } catch (e) {
    log('Custom update check failed: $e', name: 'UpdaterTools');
    // Final fallback: return structured failure map with current info
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      updates = {
        'results': false,
        'error': 'Failed to check remote releases',
        'currVer': packageInfo.version,
        'currBuild': packageInfo.buildNumber,
        'source': 'none',
      };
    } catch (e3) {
      updates = {
        'results': false,
        'error':
            'Failed to check remote releases and failed to read local package info',
        'source': 'none',
      };
    }
  }

  try {
    // Contains the latest changelog read by the user. [eg. v2.11.6+171] (can be null)
    final readChangelogs =
        await BeatsMusicDBService.getSettingStr(GlobalStrConsts.readChangelogs);
    final currVer = "v${updates['currVer']}";
    final newVer = "v${updates['newVer']}";

    log('Current version: $currVer, New version: $newVer, Read changelogs: $readChangelogs',
        name: 'UpdaterTools');

    if (currVer == newVer &&
        (readChangelogs == null || readChangelogs != currVer)) {
      final changelogText = await fetchChangelog();
      updates['changelogs'] = changelogText;
    } else {
      updates['changelogs'] = null;
    }
  } catch (e, st) {
    log('Attaching changelog failed: $e\n$st', name: 'UpdaterTools');
    updates['changelogs'] = null;
  }

  // log('Update check completed: $updates', name: 'UpdaterTools');

  return updates;
}

/// Fetch the project's CHANGELOG.md from the hosted GitHub Pages site.
/// Returns the changelog text on success, or null on any failure.
Future<String?> fetchChangelog(
    {Duration timeout = const Duration(seconds: 6)}) async {
  const changelogUrl =
      'https://raw.githubusercontent.com/AWTMODS/Beats-Music/main/CHANGELOG.md';
  try {
    final response = await http.get(Uri.parse(changelogUrl)).timeout(timeout);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      log('Changelog fetch returned status ${response.statusCode}',
          name: 'UpdaterTools');
      return null;
    }
  } catch (e, st) {
    log('Failed to fetch changelog: $e\n$st', name: 'UpdaterTools');
    return null;
  }
}

/// Backwards-compatible wrapper for existing callers
Future<Map<String, dynamic>> getLatestVersion() async => await getAppUpdates();

String? extractUpUrl(Map<String, dynamic> data) {
  // List<String> urls = [];

  for (var element in (data["assets"] as List)) {
    // urls.add(element["browser_download_url"]);
    if (element["browser_download_url"].toString().contains("windows")) {
      if (Platform.isWindows) {
        return element["browser_download_url"].toString();
      }
    } else if (element["browser_download_url"].toString().contains("android")) {
      if (Platform.isAndroid) {
        return element["browser_download_url"].toString();
      }
    } else {
      continue;
    }
  }
  return null;
}
