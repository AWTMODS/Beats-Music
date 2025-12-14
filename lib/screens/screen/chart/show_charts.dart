import 'package:beats_music/plugins/ext_charts/kworb_charts.dart';
import 'package:beats_music/plugins/ext_charts/chart_defines.dart';
import 'package:beats_music/plugins/ext_charts/last_dot_fm_charts.dart';
import 'package:beats_music/plugins/ext_charts/melon_charts.dart';
import 'package:beats_music/plugins/ext_charts/spotify_top50_chart.dart';

final List<ChartInfo> chartInfoList = [
  ChartInfo(
    chartFunction: getSpotifyTop50Chart,
    imgUrl: spotifyRandomIMGs.getImage(),
    title: SpotifyCharts.TOP_50.title,
    url: SpotifyCharts.TOP_50,
  ),
  ChartInfo(
    chartFunction: getLastFmCharts,
    imgUrl: lastfmRandomIMGs.getImage(),
    title: LastFMCharts.TOP_TRACKS.title,
    url: LastFMCharts.TOP_TRACKS,
  ),
  ChartInfo(
    chartFunction: getMelonChart,
    imgUrl: melonRandomIMGs.getImage(),
    title: MelonCharts.DOMESTIC_DAILY.title,
    url: MelonCharts.DOMESTIC_DAILY,
  ),
  ChartInfo(
    chartFunction: getMelonChart,
    imgUrl: melonRandomIMGs.getImage(),
    title: MelonCharts.DOMESTIC_WEEKLY.title,
    url: MelonCharts.DOMESTIC_WEEKLY,
  ),
  ChartInfo(
    chartFunction: getMelonChart,
    imgUrl: melonRandomIMGs.getImage(),
    title: MelonCharts.DOMESTIC_MONTHLY.title,
    url: MelonCharts.DOMESTIC_MONTHLY,
  ),
  // ChartInfo(
  //   chartFunction: getMelonChart,
  //   imgUrl: melonRandomIMGs.getImage(),
  //   title: MelonCharts.GENREOMICS_DAILY.title,
  //   url: MelonCharts.GENREOMICS_DAILY,
  // ),
  // ChartInfo(
  //   chartFunction: getMelonChart,
  //   imgUrl: melonRandomIMGs.getImage(),
  //   title: MelonCharts.GENREOMICS_WEEKLY.title,
  //   url: MelonCharts.GENREOMICS_WEEKLY,
  // ),
  // ChartInfo(
  //   chartFunction: getMelonChart,
  //   imgUrl: melonRandomIMGs.getImage(),
  //   title: MelonCharts.GENREOMICS_MONTHLY.title,
  //   url: MelonCharts.GENREOMICS_MONTHLY,
  // ),
  ChartInfo(
      chartFunction: getKworbChart,
      imgUrl: kworbRandomIMGs.getImage(),
      title: KworbCharts.GLOBAL_DAILY.title,
      url: KworbCharts.GLOBAL_DAILY),
  ChartInfo(
      chartFunction: getKworbChart,
      imgUrl: kworbRandomIMGs.getImage(),
      title: KworbCharts.KOREA_DAILY.title,
      url: KworbCharts.KOREA_DAILY),
  ChartInfo(
      chartFunction: getKworbChart,
      imgUrl: kworbRandomIMGs.getImage(),
      title: KworbCharts.INDIA_DAILY.title,
      url: KworbCharts.INDIA_DAILY),
  ChartInfo(
      chartFunction: getKworbChart,
      imgUrl: kworbRandomIMGs.getImage(),
      title: KworbCharts.JAPAN_DAILY.title,
      url: KworbCharts.JAPAN_DAILY),
];
