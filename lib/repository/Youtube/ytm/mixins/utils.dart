import 'dart:core';

import '../helpers.dart';

Map<String, dynamic> handlePageHeader(Map<String, dynamic> header,
    {Map? editHeader}) {
  List? subruns = nav(header, ['subtitle', 'runs']) ??
      nav(header, ['straplineTextOne', 'runs']);
  List? secondSubruns = nav(header, ['secondSubtitle', 'runs']);
  Map<String, dynamic> result = {
    'title': nav(header, ['title', 'runs', 0, 'text']),
    'subtitle': subruns?.map((run) => run['text']).join('') ??
        nav(header, [
          'subscriptionButton',
          'subscribeButtonRenderer',
          'longSubscriberCountText',
          'runs',
          0,
          'text'
        ]),
    'secondSubtitle': secondSubruns?.map((run) => run['text']).join(''),
    'type': nav(header, ['subscriptionButton']) != null ? 'ARTIST' : null,
    'thumbnails': nav(header, [
          'thumbnail',
          'croppedSquareThumbnailRenderer',
          'thumbnail',
          'thumbnails'
        ]) ??
        nav(header, [
          'thumbnail',
          'musicThumbnailRenderer',
          'thumbnail',
          'thumbnails'
        ]) ??
        nav(header, [
          'foregroundThumbnail',
          'musicThumbnailRenderer',
          'thumbnail',
          'thumbnails'
        ]),
    'description': nav(header, ['description', 'runs', 0, 'text']) ??
        nav(header, [
          'description',
          'musicDescriptionShelfRenderer',
          'description',
          'runs',
          0,
          'text'
        ]),
    'playlistId': nav(header, [
      'startRadioButton',
      'buttonRenderer',
      'navigationEndpoint',
      'watchEndpoint',
      'playlistId'
    ])?.replaceAll('RDAMPL', ''),
    'videoId': nav(header, [
      'buttons',
      0,
      'musicPlayButtonRenderer',
      'playNavigationEndpoint',
      'watchEndpoint',
      'videoId'
    ]),
    'params': nav(header, [
      'startRadioButton',
      'buttonRenderer',
      'navigationEndpoint',
      'watchEndpoint',
      'params'
    ]),
    'channelId': nav(
        header, ['subscriptionButton', 'subscribeButtonRenderer', 'channelId']),
    'artists': nav(header, ['straplineTextOne', 'runs'])?.map((run) {
      return {
        'name': run['text'],
        'endpoint': nav(run, ['navigationEndpoint', 'browseEndpoint'])
      };
    }).toList(),
  };
  if (subruns != null) {
    for (Map run in subruns) {
      Map? navigationEndpoint = nav(run, ['navigationEndpoint']);
      Map? browseEndpoint = nav(navigationEndpoint, ['browseEndpoint']);
      String? pageType = nav(browseEndpoint, [
        'browseEndpointContextSupportedConfigs',
        'browseEndpointContextMusicConfig',
        'pageType'
      ]);
      if (pageType == 'MUSIC_PAGE_TYPE_ARTIST') {
        result['artists'].add({
          'name': nav(run, ['text']),
          'endpoint': browseEndpoint
        });
      } else if (pageType == 'MUSIC_PAGE_TYPE_ALBUM') {
        result['album'] = {
          'name': nav(run, ['text']),
          'endpoint': browseEndpoint
        };
      }
    }
  }
  List? menuItems = nav(header, ['menu', 'menuRenderer', 'items']) ??
      (nav(header, ['buttons']) as List?)
              ?.firstWhere((el) => el['menuRenderer'] != null)?['menuRenderer']
          ?['items'];
  if (menuItems != null) {
    for (Map run in menuItems) {
      String? iconType =
          nav(run, ['menuNavigationItemRenderer', 'icon', 'iconType']) ??
              nav(run, ['menuServiceItemRenderer', 'icon', 'iconType']) ??
              nav(run,
                  ['toggleMenuServiceItemRenderer', 'defaultIcon', 'iconType']);
      if (iconType == 'MUSIC_SHUFFLE') {
        result['playlistId'] ??= nav(run, [
          'menuNavigationItemRenderer',
          'navigationEndpoint',
          'watchPlaylistEndpoint',
          'playlistId'
        ]);
      } else if (iconType == 'MIX') {
        result['playlistId'] ??= nav(run, [
          'menuNavigationItemRenderer',
          'navigationEndpoint',
          'watchPlaylistEndpoint',
          'playlistId'
        ])?.replaceAll('RDAMPL', '');
      } else if (iconType == 'QUEUE_PLAY_NEXT') {
        result['playlistId'] ??= nav(run, [
          'menuServiceItemRenderer',
          'serviceEndpoint',
          'queueAddEndpoint',
          'queueTarget',
          'playlistId'
        ]);
      } else if (iconType == 'LIBRARY_ADD') {
        result['playlistId'] ??= nav(run, [
          'toggleMenuServiceItemRenderer',
          'toggledServiceEndpoint',
          'likeEndpoint',
          'target',
          'playlistId'
        ]);
      }
    }
  }
  if (editHeader != null) {
    result['privacy'] = editHeader['privacy'];
  }
  result.removeWhere((key, val) => val == null || val.toString().isEmpty);
  return result;
}

handleContents(List contents, {List? thumbnails}) {
  List contentsResult = [];
  int filteredCount = 0;
  
  for (int i = 0; i < contents.length; i++) {
    Map content = contents[i];
    Map result = {};
    
    // Handle musicTwoColumnItemRenderer (new YouTube Music format)
    Map? musicTwoColumnItemRenderer = nav(content, ['musicTwoColumnItemRenderer']);
    if (musicTwoColumnItemRenderer != null) {
      // Extract the actual renderer from inside musicTwoColumnItemRenderer
      content = musicTwoColumnItemRenderer;
    }
    
    Map? musicResponsiveListItemRenderer =
        nav(content, ['musicResponsiveListItemRenderer']);
    Map? musicTwoRowItemRenderer = nav(content, ['musicTwoRowItemRenderer']);
    Map? musicMultiRowListItemRenderer =
        nav(content, ['musicMultiRowListItemRenderer']);
    Map? playlistPanelVideoRenderer =
        nav(content, ['playlistPanelVideoRenderer']);
    
    String rendererType = 'unknown';
    if (musicResponsiveListItemRenderer != null) {
      rendererType = 'musicResponsiveListItemRenderer';
      result = handleMusicResponsiveListItemRenderer(
          musicResponsiveListItemRenderer,
          thumbnails: thumbnails);
    } else if (musicTwoRowItemRenderer != null) {
      rendererType = 'musicTwoRowItemRenderer';
      result = handleMusicTwoRowItemRenderer(musicTwoRowItemRenderer,
          thumbnails: thumbnails);
    } else if (musicMultiRowListItemRenderer != null) {
      rendererType = 'musicMultiRowListItemRenderer';
      result =
          handleMusicMultiRowListItemRenderer(musicMultiRowListItemRenderer);
    } else if (playlistPanelVideoRenderer != null) {
      rendererType = 'playlistPanelVideoRenderer';
      result = handlePlaylistPanelVideoRenderer(playlistPanelVideoRenderer);
    } else if (content['thumbnail'] != null && content['title'] != null) {
      // New YouTube Music format: direct properties without renderer wrapper
      rendererType = 'directProperties';
      result = handleDirectPropertiesItem(content);
      print('[handleContents] DirectProperties item $i: title=${result['title']}, videoId=${result['videoId']}, thumbnails=${result['thumbnails']?.length ?? 0}');
    } else {
      print('[handleContents] Item $i: Unknown renderer type, keys: ${content.keys.toList()}');
    }
    
    if (result['thumbnails'] == null) {
      filteredCount++;
      print('[handleContents] ⚠️ Item $i ($rendererType) filtered: no thumbnails. Title: ${result['title']}, VideoId: ${result['videoId']}');
      continue;
    }
    contentsResult.add(result);
  }
  
  if (filteredCount > 0) {
    print('[handleContents] Filtered out $filteredCount items due to missing thumbnails');
  }
  
  return contentsResult;
}

int? getDuration(String duration) {
  if (RegExp(r'\d+:\s*\d+').hasMatch(duration)) {
    if (duration.isNotEmpty) {
      duration = duration.trim();
      List<String> durationList = duration.split(':');
      if (durationList.length == 2) {
        return int.parse(durationList[0]) * 60 + int.parse(durationList[1]);
      } else if (durationList.length == 3) {
        return int.parse(durationList[0]) * 3600 +
            int.parse(durationList[1]) * 60 +
            int.parse(durationList[2]);
      }
    }
  }
  return null;
}

Map<String, dynamic> checkRuns(List? runs) {
  if (runs == null) return {};
  Map<String, dynamic> runResult = {'artists': []};
  Map<String, dynamic> channel = {};
  for (Map run in runs) {
    String? pageType = nav(run, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseEndpointContextSupportedConfigs',
          'browseEndpointContextMusicConfig',
          'pageType'
        ]) ??
        nav(run, [
          'navigationEndpoint',
          'watchEndpoint',
          'watchEndpointMusicSupportedConfigs',
          'watchEndpointMusicConfig',
          'musicVideoType'
        ]) ??
        nav(run, ['menuServiceItemRenderer', 'icon', 'iconType']);
    if (pageType == 'MUSIC_PAGE_TYPE_ARTIST') {
      runResult['artists'].add({
        'name': nav(run, ['text']),
        'endpoint': nav(run, ['navigationEndpoint', 'browseEndpoint'])
      });
    } else if (pageType == 'MUSIC_PAGE_TYPE_ALBUM') {
      runResult['album'] = {
        'name': nav(run, ['text']),
        'endpoint': nav(run, ['navigationEndpoint', 'browseEndpoint'])
      };
    } else if (pageType == 'MUSIC_VIDEO_TYPE_OMV' ||
        pageType == 'MUSIC_VIDEO_TYPE_ATV') {
      runResult['title'] ??= run['text'];
      runResult['videoId'] ??=
          nav(run, ['navigationEndpoint', 'watchEndpoint', 'videoId']);
    } else if (pageType == 'QUEUE_PLAY_NEXT') {
      runResult['videoId'] ??= nav(run, [
        'menuServiceItemRenderer',
        'serviceEndpoint',
        'queueAddEndpoint',
        'queueTarget',
        'videoId'
      ]);
    } else if (pageType == "MUSIC_PAGE_TYPE_USER_CHANNEL") {
      channel['name'] = nav(run, ['text']);
      channel['endpoint'] = nav(run, ['navigationEndpoint', 'browseEndpoint']);
    }
    if (nav(run, ['menuNavigationItemRenderer', 'icon', 'iconType']) ==
        'MUSIC_SHUFFLE') {
      runResult['playlistId'] ??= nav(run, [
        'menuNavigationItemRenderer',
        'navigationEndpoint',
        'watchPlaylistEndpoint',
        'playlistId'
      ]);
    } else if (nav(run, ['menuNavigationItemRenderer', 'icon', 'iconType']) ==
        'MIX') {
      runResult['playlistId'] ??= nav(run, [
        'menuNavigationItemRenderer',
        'navigationEndpoint',
        'watchPlaylistEndpoint',
        'playlistId'
      ])?.replaceAll('RDAMPL', '');
    } else if (nav(run, [
          'toggleMenuServiceItemRenderer',
          'toggledServiceEndpoint',
          'likeEndpoint',
          'target',
          'playlistId'
        ]) !=
        null) {
      runResult['playlistId'] ??= nav(run, [
        'toggleMenuServiceItemRenderer',
        'toggledServiceEndpoint',
        'likeEndpoint',
        'target',
        'playlistId'
      ])?.replaceAll('RDAMPL', '');
    }
    if (nav(run, ['menuServiceItemRenderer', 'icon', 'iconType']) ==
        'REMOVE_FROM_HISTORY') {
      runResult['feedbackToken'] = nav(run, [
        'menuServiceItemRenderer',
        'serviceEndpoint',
        'feedbackEndpoint',
        'feedbackToken'
      ]);
    }
    final text = nav(run, ['text']);
    if (text != null) {
      final duration = getDuration(text);
      if (duration != null) {
        runResult['duration'] = duration.toString();
      }
    }
  }
  runResult.removeWhere((key, val) => val == null || val.isEmpty);
  if (runResult['artists'] == null && channel.isNotEmpty) {
    runResult['artists'] = [channel];
  }
  return runResult;
}

Map itemCategory = {
  'MUSIC_PAGE_TYPE_ARTIST': 'ARTIST',
  'MUSIC_PAGE_TYPE_LIBRARY_ARTIST': 'ARTIST',
  'MUSIC_VIDEO_TYPE_OMV': 'VIDEO',
  'MUSIC_VIDEO_TYPE_UGC': 'VIDEO',
  'MUSIC_PAGE_TYPE_ALBUM': 'ALBUM',
  'MUSIC_VIDEO_TYPE_ATV': 'SONG',
  'MUSIC_PAGE_TYPE_PLAYLIST': 'PLAYLIST',
  'MUSIC_PAGE_TYPE_NON_MUSIC_AUDIO_TRACK_PAGE': 'EPISODE',
  'MUSIC_PAGE_TYPE_USER_CHANNEL': 'PROFILE'
};

Map<String, dynamic> handleMusicShelfRenderer(Map item, {List? thumbnails}) {
  List? contents = nav(item, ['contents']);
  Map<String, dynamic> section = {
    'title': nav(item, ['title', 'runs', 0, 'text']),
    'contents': [],
  };
  if (nav(item, ['bottomEndpoint', 'browseEndpoint']) != null) {
    section['trailing'] = {
      'text': nav(item, ['bottomText', 'runs', 0, 'text']),
      'endpoint': nav(item, ['bottomEndpoint', 'browseEndpoint'])
    };
  }
  if (contents != null) {
    section['contents']
        .addAll(handleContents(contents, thumbnails: thumbnails));
  }
  return section;
}

Map<String, dynamic> handleGridRenderer(Map item) {
  List? contents = nav(item, ['items']);
  Map<String, dynamic> section = {
    'title': nav(item, ['title', 'runs', 0, 'text']),
    'contents': [],
    'viewType': 'SINGLE_COLUMN',
  };
  if (contents != null) {
    section['contents'].addAll(handleContents(contents));
  }
  return section;
}

handleContinuationContents(Map item) {
  Map<String, dynamic> section = {
    'title': null,
    'contents': [],
    'viewType': 'COLUMN',
  };
  List? contents = nav(item, ['contents']);
  if (contents != null) {
    section['contents'].addAll(handleContents(contents));
  }
  return section;
}

handleMusicPlaylistShelfRenderer(Map item) {
  Map<String, dynamic> section = {'contents': []};
  if (nav(item, ['playlistId']) != null) {
    section['playlistId'] = nav(item, ['playlistId']);
    section['viewType'] = 'COLUMN';
  }
  String? cont =
      nav(item, ['continuations', 0, 'nextContinuationData', 'continuation']);
  String? continuationparams =
      cont != null ? getContinuationString(cont) : null;
  section['continuation'] = continuationparams;

  List? contents = nav(item, ['contents']);
  if (contents != null) {
    section['contents'].addAll(handleContents(contents));
  }
  if (cont == null && contents != null) {
    for (var c in contents) {
      if (c['continuationItemRenderer'] != null) {
        cont = nav(c, [
          'continuationItemRenderer',
          'continuationEndpoint',
          'continuationCommand',
          'token'
        ]);
        continuationparams = cont != null ? getContinuationString(cont) : null;
        section['continuation'] = continuationparams;
      }
    }
  }
  return section;
}

Map<String, dynamic> handleMusicResponsiveListItemRenderer(Map item,
    {List? thumbnails}) {
  List flexColumns = nav(item, ['flexColumns']);

  List allRuns = flexColumns
      .map((column) => nav(column,
          ['musicResponsiveListItemFlexColumnRenderer', 'text', 'runs']))
      .toList();
  allRuns.removeWhere((element) => element == null);
  allRuns = allRuns.expand((x) => x).toList();
  Map firstRun = allRuns[0];
  Map<String, dynamic> itemresult = {
    'thumbnails': nav(item, [
          'thumbnail',
          'musicThumbnailRenderer',
          'thumbnail',
          'thumbnails'
        ]) ??
        thumbnails,
    'explicit': nav(item,
            ['badges', 0, 'musicInlineBadgeRenderer', 'icon', 'iconType']) ==
        'MUSIC_EXPLICIT_BADGE',
    'title': nav(firstRun, ['text']),
    'subtitle': nav(flexColumns.last, [
      'musicResponsiveListItemFlexColumnRenderer',
      'text',
      'runs'
    ])?.map((el) => el['text']).join(''),
    'endpoint': nav(firstRun, ['navigationEndpoint', 'browseEndpoint']) ??
        nav(item, ['navigationEndpoint', 'browseEndpoint']),
    'videoId':
        nav(firstRun, ['navigationEndpoint', 'watchEndpoint', 'videoId']) ??
            nav(item, ['playlistItemData', 'videoId']),
    'type': itemCategory[nav(firstRun, [
          'navigationEndpoint',
          'watchEndpoint',
          'watchEndpointMusicSupportedConfigs',
          'watchEndpointMusicConfig',
          'musicVideoType'
        ]) ??
        nav(firstRun, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseEndpointContextSupportedConfigs',
          'browseEndpointContextMusicConfig',
          'pageType'
        ]) ??
        nav(item, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseEndpointContextSupportedConfigs',
          'browseEndpointContextMusicConfig',
          'pageType'
        ])],
    ...checkRuns(allRuns),
    ...checkRuns(nav(item, ['menu', 'menuRenderer', 'items']))
  };

  itemresult.removeWhere((key, val) => val == null || val.toString().isEmpty);
  final dur = nav(item, [
    'fixedColumns',
    0,
    'musicResponsiveListItemFixedColumnRenderer',
    'text',
    'runs',
    0,
    'text'
  ]);
  if (itemresult['duration'] == null && dur != null) {
    itemresult['duration'] = getDuration(dur).toString();
  }
  if (itemresult['artists'] == null &&
      nav(flexColumns[1], [
            'musicResponsiveListItemFlexColumnRenderer',
            'text',
            'runs'
          ]) !=
          null) {
    var runs = nav(flexColumns[1], [
      'musicResponsiveListItemFlexColumnRenderer',
      'text',
      'runs'
    ]);
    if (runs is List) {
      List<Map<String, dynamic>> artists = [];
      for (var run in runs) {
        String text = run['text'] ?? '';
        // Skip common separators and metadata
        if ([' • ', ' & ', ', ', '|'].contains(text)) continue;
        if (text.contains('views') || text.contains('ago') || text.contains('minutes') || text.contains('seconds')) continue;
        
        // If we hit a known metadata separator like a pure bullet, we might want to stop if we already have artists
        // But for "Year in Music", the format is often "Artist • Album • Year"
        // So we should capture the first valid text run as the artist.
        
        artists.add({
          'name': text,
          'endpoint': nav(run, ['navigationEndpoint', 'browseEndpoint']),
        });
      }
      
      if (artists.isNotEmpty) {
        itemresult['artists'] = artists;
      }
    }
  }
  
  // Fallback: If still no artists, check "subtitle" field directly if available
  if ((itemresult['artists'] == null || itemresult['artists'].isEmpty) && item['subtitle'] != null) {
      var subtitleRuns = nav(item, ['subtitle', 'runs']);
      if (subtitleRuns != null) {
          itemresult['artists'] = [];
           for (var run in subtitleRuns) {
              String text = run['text'];
               if ([' • ', ' & ', ', ', '|'].contains(text)) continue;
               if (text.contains('views') || text.contains('ago')) continue;
               itemresult['artists'].add({'name': text, 'endpoint': null});
           }
      }
  }

  return itemresult;
}

handleMusicTwoRowItemRenderer(Map item, {List? thumbnails}) {
  Map itemresult = {
    'title': nav(item, ['title', 'runs', 0, 'text']),
    'thumbnails': nav(item, [
          'thumbnailRenderer',
          'musicThumbnailRenderer',
          'thumbnail',
          'thumbnails'
        ]) ??
        thumbnails,
    'explicit': nav(item, [
          'subtitleBadges',
          0,
          'musicInlineBadgeRenderer',
          'icon',
          'iconType'
        ]) ==
        'MUSIC_EXPLICIT_BADGE',
    'subtitle':
        nav(item, ['subtitle', 'runs'])?.map((el) => el['text']).join(''),
    'aspectRatio': nav(item, ['aspectRatio']) ==
            'MUSIC_TWO_ROW_ITEM_THUMBNAIL_ASPECT_RATIO_RECTANGLE_16_9'
        ? 16 / 9
        : 1 / 1,
    'endpoint': nav(item,
            ['title', 'runs', 0, 'navigationEndpoint', 'browseEndpoint']) ??
        nav(item, ['navigationEndpoint', 'browseEndpoint']),
    'videoId': nav(item, ['navigationEndpoint', 'watchEndpoint', 'videoId']),
    'type': itemCategory[nav(item, [
          'title',
          'runs',
          0,
          'navigationEndpoint',
          'watchEndpoint',
          'watchEndpointMusicSupportedConfigs',
          'watchEndpointMusicConfig',
          'musicVideoType'
        ]) ??
        nav(item, [
          'title',
          'runs',
          0,
          'navigationEndpoint',
          'browseEndpoint',
          'browseEndpointContextSupportedConfigs',
          'browseEndpointContextMusicConfig',
          'pageType'
        ]) ??
        nav(item, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseEndpointContextSupportedConfigs',
          'browseEndpointContextMusicConfig',
          'pageType'
        ]) ??
        nav(item, [
          'navigationEndpoint',
          'watchEndpoint',
          'watchEndpointMusicSupportedConfigs',
          'watchEndpointMusicConfig',
          'musicVideoType'
        ])],
    'description': nav(item, ['runs', 0, 'text']),
    ...checkRuns(nav(item, ['subtitle', 'runs'])),
    ...checkRuns(nav(item, ['menu', 'menuRenderer', 'items']))
  };
  itemresult.removeWhere((key, val) => val == null || val.toString().isEmpty);
  return itemresult;
}

handlePlaylistPanelVideoRenderer(Map item) {
  Map itemresult = {
    'title': nav(item, ['title', 'runs', 0, 'text']),
    'thumbnails': nav(item, ['thumbnail', 'thumbnails']),
    'explicit': nav(item, [
          'subtitleBadges',
          0,
          'musicInlineBadgeRenderer',
          'icon',
          'iconType'
        ]) ==
        'MUSIC_EXPLICIT_BADGE',
    'subtitle':
        nav(item, ['longBylineText', 'runs'])?.map((el) => el['text']).join(''),
    'aspectRatio': nav(item, ['aspectRatio']) ==
            'MUSIC_TWO_ROW_ITEM_THUMBNAIL_ASPECT_RATIO_RECTANGLE_16_9'
        ? 16 / 9
        : 1 / 1,
    'endpoint': nav(item,
            ['title', 'runs', 0, 'navigationEndpoint', 'browseEndpoint']) ??
        nav(item, ['navigationEndpoint', 'browseEndpoint']),
    'videoId': nav(item, ['videoId']) ??
        nav(item, ['navigationEndpoint', 'watchEndpoint', 'videoId']),
    'playlistId':
        nav(item, ['navigationEndpoint', 'watchEndpoint', 'playlistId']),
    'type': itemCategory[nav(item, [
          'title',
          'runs',
          0,
          'navigationEndpoint',
          'watchEndpoint',
          'watchEndpointMusicSupportedConfigs',
          'watchEndpointMusicConfig',
          'musicVideoType'
        ]) ??
        nav(item, [
          'title',
          'runs',
          0,
          'navigationEndpoint',
          'browseEndpoint',
          'browseEndpointContextSupportedConfigs',
          'browseEndpointContextMusicConfig',
          'pageType'
        ]) ??
        nav(item, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseEndpointContextSupportedConfigs',
          'browseEndpointContextMusicConfig',
          'pageType'
        ]) ??
        nav(item, [
          'navigationEndpoint',
          'watchEndpoint',
          'watchEndpointMusicSupportedConfigs',
          'watchEndpointMusicConfig',
          'musicVideoType'
        ])],
    'description': nav(item, ['runs', 0, 'text']),
    ...checkRuns(nav(item, ['longBylineText', 'runs'])),
    ...checkRuns(nav(item, ['menu', 'menuRenderer', 'items'])),
    ...checkRuns(nav(item, ['lengthText', 'runs'])),
  };
  itemresult['perma_url'] =
      "https://music.youtube.com/watch?v=${itemresult['videoId']}";
  if (itemresult['artists'] == null &&
      nav(item, ['longBylineText', 'runs', 0, 'text']) != null) {
    itemresult['artists'] = [
      {
        'name': nav(item, ['longBylineText', 'runs', 0, 'text']),
        'endpoint': null
      }
    ];
  }
  itemresult.removeWhere((key, val) => val == null || val.toString().isEmpty);
  return itemresult;
}

handleMusicMultiRowListItemRenderer(Map item) {
  Map itemresult = {
    'title': nav(item, ['title', 'runs', 0, 'text']),
    'type': itemCategory[nav(item, [
          'title',
          'runs',
          0,
          'navigationEndpoint',
          'browseEndpoint',
          'browseEndpointContextSupportedConfigs',
          'browseEndpointContextMusicConfig',
          'pageType'
        ]) ??
        nav(item, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseEndpointContextSupportedConfigs',
          'browseEndpointContextMusicConfig',
          'pageType'
        ])],
    'description': nav(item, ['description', 'runs', 0, 'text']),
    'thumbnails': nav(item,
        ['thumbnail', 'musicThumbnailRenderer', 'thumbnail', 'thumbnails']),
    'subtitle':
        nav(item, ['subtitle', 'runs'])?.map((el) => el['text']).join(''),
    'videoId': nav(item, ['onTap', 'watchEndpoint', 'videoId']),
    'playlistId': nav(item, ['onTap', 'watchEndpoint', 'playlistId']),
    'endpoint': nav(item,
            ['title', 'runs', 0, 'navigationEndpoint', 'browseEndpoint']) ??
        nav(item, ['navigationEndpoint', 'browseEndpoint']),
    'aspectRatio': 16 / 9,
    ...checkRuns(nav(item, ['subtitle', 'runs'])),
  };

  itemresult.removeWhere((key, val) => val == null || val.toString().isEmpty);
  return itemresult;
}

handleDirectPropertiesItem(Map item) {
  // Handle new YouTube Music format where items have direct properties
  // without renderer wrappers (e.g., in playlist contents)
  
  try {
    // Extract thumbnails - try ALL possible paths
    List? thumbnails;
    
    // Path 1: Standard musicThumbnailRenderer path
    thumbnails = nav(item, ['thumbnail', 'musicThumbnailRenderer', 'thumbnail', 'thumbnails']);
    
    // Path 2: Direct thumbnail path
    if (thumbnails == null || (thumbnails is List && thumbnails.isEmpty)) {
      thumbnails = nav(item, ['thumbnail', 'thumbnails']);
    }
    
    // Path 3: Top-level thumbnails
    if (thumbnails == null || (thumbnails is List && thumbnails.isEmpty)) {
      thumbnails = nav(item, ['thumbnails']);
    }
    
    // Path 4: Create fallback from videoId if still no thumbnails
    if (thumbnails == null || (thumbnails is List && thumbnails.isEmpty)) {
      final videoId = nav(item, ['playlistItemData', 'videoId']) ??
          nav(item, ['navigationEndpoint', 'watchEndpoint', 'videoId']);
      
      if (videoId != null) {
        // Generate YouTube thumbnail URLs from videoId
        // Order: low to high quality (app uses .last for highest quality)
        thumbnails = [
          {'url': 'https://i.ytimg.com/vi/$videoId/default.jpg', 'width': 120, 'height': 90},
          {'url': 'https://i.ytimg.com/vi/$videoId/mqdefault.jpg', 'width': 320, 'height': 180},
          {'url': 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg', 'width': 480, 'height': 360},
          {'url': 'https://i.ytimg.com/vi/$videoId/sddefault.jpg', 'width': 640, 'height': 480},
          {'url': 'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg', 'width': 1280, 'height': 720},
        ];
        print('[handleDirectPropertiesItem] Generated fallback thumbnails for videoId: $videoId');
      }
    }
    
    Map itemresult = {
      'title': nav(item, ['title', 'runs', 0, 'text']),
      'thumbnails': thumbnails,
      'subtitle': nav(item, ['subtitle', 'runs'])?.map((el) => el['text']).join(''),
      'videoId': nav(item, ['playlistItemData', 'videoId']) ??
          nav(item, ['navigationEndpoint', 'watchEndpoint', 'videoId']),
      'playlistId': nav(item, ['navigationEndpoint', 'watchEndpoint', 'playlistId']),
      'endpoint': nav(item, ['navigationEndpoint', 'browseEndpoint']),
    };

    // Try to extract type from navigation endpoint
    String? pageType = nav(item, [
      'navigationEndpoint',
      'watchEndpoint',
      'watchEndpointMusicSupportedConfigs',
      'watchEndpointMusicConfig',
      'musicVideoType'
    ]) ?? nav(item, [
      'navigationEndpoint',
      'browseEndpoint',
      'browseEndpointContextSupportedConfigs',
      'browseEndpointContextMusicConfig',
      'pageType'
    ]);
    
    itemresult['type'] = itemCategory[pageType] ?? 'SONG';

    // Extract artists from subtitle runs
    List? subtitleRuns = nav(item, ['subtitle', 'runs']);
    if (subtitleRuns != null) {
      try {
        itemresult.addAll(checkRuns(subtitleRuns));
      } catch (e) {
        print('[handleDirectPropertiesItem] Error in checkRuns for subtitle: $e');
      }
    }

    // Extract menu items for additional metadata
    List? menuItems = nav(item, ['menu', 'menuRenderer', 'items']);
    if (menuItems != null) {
      try {
        itemresult.addAll(checkRuns(menuItems));
      } catch (e) {
        print('[handleDirectPropertiesItem] Error in checkRuns for menu: $e');
      }
    }

    itemresult.removeWhere((key, val) => val == null || val.toString().isEmpty);
    return itemresult;
  } catch (e, stackTrace) {
    print('[handleDirectPropertiesItem] ERROR: $e');
    print('[handleDirectPropertiesItem] Stack trace: $stackTrace');
    // Return minimal valid result to avoid breaking the entire list
    return {
      'title': 'Error parsing item',
      'videoId': null,
    };
  }
}
