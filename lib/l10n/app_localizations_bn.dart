// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get onboardingTitle => 'বিটস-এ স্বাগতম';

  @override
  String get onboardingSubtitle => 'চলুন আপনার ভাষা এবং অঞ্চল সেট আপ করি।';

  @override
  String get continueButton => 'চালিয়ে যান';

  @override
  String get navHome => 'হোম';

  @override
  String get navLibrary => 'লাইব্রেরি';

  @override
  String get navSearch => 'অনুসন্ধান';

  @override
  String get navLocal => 'লোকাল';

  @override
  String get navOffline => 'অফলাইন';

  @override
  String get playerEnjoyingFrom => 'উপভোগ করছেন এখান থেকে';

  @override
  String get playerPlayWithMix => 'অটো-মিক্স প্লে';

  @override
  String get playerPlayNext => 'পরবর্তী প্লে করুন';

  @override
  String get playerAddToQueue => 'কিউতে যোগ করুন';

  @override
  String get playerAddToFavorites => 'ফেভারিটে যোগ করুন';

  @override
  String get playerNoLyricsFound => 'কোন লিরিক্স পাওয়া যায়নি';

  @override
  String get playerLyricsNoPlugin =>
      'কোন লিরিক্স প্রোভাইডার সেট করা নেই। সেটিংস → প্লাগইন-এ গিয়ে একটি ইনস্টল করুন।';

  @override
  String get localMusicTitle => 'লোকাল';

  @override
  String get localMusicGrantPermission => 'অনুমতি দিন';

  @override
  String get localMusicStorageAccessRequired => 'স্টোরেজ এক্সেস প্রয়োজন';

  @override
  String get localMusicStorageAccessDesc =>
      'আপনার ডিভাইসে সংরক্ষিত অডিও ফাইল স্ক্যান এবং প্লে করার জন্য অনুগ্রহ করে অনুমতি দিন।';

  @override
  String get localMusicAddFolder => 'মিউজিক ফোল্ডার যোগ করুন';

  @override
  String get localMusicScanNow => 'এখনই স্ক্যান করুন';

  @override
  String localMusicScanFailed(String message) {
    return 'স্ক্যান ব্যর্থ হয়েছে: $message';
  }

  @override
  String get localMusicScanning =>
      'অডিও ফাইলের জন্য ডিভাইস স্ক্যান করা হচ্ছে...';

  @override
  String get localMusicShuffle => 'সাফল';

  @override
  String get localMusicPlayAll => 'সব প্লে করুন';

  @override
  String get localMusicSearchHint => 'লোকাল মিউজিক খুঁজুন...';

  @override
  String get localMusicRescanDevice => 'ডিভাইস রিস্ক্যান করুন';

  @override
  String get buttonCancel => 'বাতিল';

  @override
  String get buttonDelete => 'ডিলিট';

  @override
  String get buttonOk => 'ঠিক আছে';

  @override
  String get buttonUpdate => 'আপডেট';

  @override
  String get buttonDownload => 'ডাউনলোড';

  @override
  String get buttonLater => 'পরে';

  @override
  String get buttonInfo => 'তথ্য';

  @override
  String get buttonMore => 'আরও';

  @override
  String get dialogDeleteTrack => 'ট্র্যাক ডিলিট করুন';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'আপনি কি নিশ্চিত যে আপনি আপনার ডিভাইস থেকে \"$title\" ডিলিট করতে চান? এই কাজটি আর ফেরানো যাবে না।';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'এই ট্র্যাকটি এই প্লেলিস্ট থেকেও সরিয়ে ফেলা হবে:';

  @override
  String get dialogDontAskAgain => 'আর জিজ্ঞাসা করবেন না';

  @override
  String get dialogUpdateAvailable => 'আপডেট উপলব্ধ';

  @override
  String get dialogUpdateNow => 'এখনই আপডেট করুন';

  @override
  String get dialogDownloadPlaylist => 'প্লেলিস্ট ডাউনলোড করুন';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'আপনি কি \"$title\" থেকে $countটি গান ডাউনলোড করতে চান? এটি সেগুলোকে ডাউনলোড কিউতে যোগ করবে।';
  }

  @override
  String get dialogDownloadAll => 'সব ডাউনলোড করুন';

  @override
  String get playlistEdit => 'প্লেলিস্ট এডিট করুন';

  @override
  String get playlistShareFile => 'ফাইল শেয়ার করুন';

  @override
  String get playlistExportFile => 'ফাইল এক্সপোর্ট করুন';

  @override
  String get playlistPlay => 'প্লে';

  @override
  String get playlistAddToQueue => 'প্লেলিস্ট কিউতে যোগ করুন';

  @override
  String get playlistShare => 'প্লেলিস্ট শেয়ার করুন';

  @override
  String get playlistDelete => 'প্লেলিস্ট ডিলিট করুন';

  @override
  String get playlistEmptyState => 'এখনও গান নেই!';

  @override
  String get playlistAvailableOffline => 'অফলাইনে পাওয়া যাবে';

  @override
  String get playlistShuffle => 'সাফল';

  @override
  String get playlistNoMatchSearch =>
      'আপনার অনুসন্ধানের সাথে মিলছে এমন কোন প্লেলিস্ট নেই';

  @override
  String get playlistCreateNew => 'নতুন প্লেলিস্ট তৈরি করুন';

  @override
  String get playlistCreateFirstOne =>
      'এখনও কোন প্লেলিস্ট নেই। শুরু করতে একটি তৈরি করুন!';

  @override
  String get addToPlaylistNoSongSelected => 'No song selected';

  @override
  String get createPlaylistDialogBarrierLabel => 'Create playlist dialog';

  @override
  String get createPlaylistDialogNameHint => 'Summer Vibes';

  @override
  String get createPlaylistDialogCreate => 'Create';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি গান',
      one: '১টি গান',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$playlist থেকে $title সরানো হয়েছে';
  }

  @override
  String get playlistFailedToLoad => 'প্লেলিস্ট লোড করতে ব্যর্থ হয়েছে';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsPlugins => 'প্লাগইনসমূহ';

  @override
  String get settingsPluginsSubtitle => 'প্লাগইন ইনস্টল, লোড এবং ম্যানেজ করুন।';

  @override
  String get settingsUpdates => 'আপডেটসমূহ';

  @override
  String get settingsUpdatesSubtitle => 'নতুন আপডেটের জন্য চেক করুন';

  @override
  String get settingsDownloads => 'ডাউনলোডসমূহ';

  @override
  String get settingsDownloadsSubtitle =>
      'ডাউনলোড পাথ, ডাউনলোড কোয়ালিটি এবং আরও অনেক কিছু...';

  @override
  String get settingsLocalTracks => 'লোকাল ট্র্যাকসমূহ';

  @override
  String get settingsLocalTracksSubtitle =>
      'স্ক্যান, ফোল্ডার ম্যানেজমেন্ট এবং অটো-স্ক্যান সেটিংস।';

  @override
  String get settingsPlayer => 'প্লেয়ার সেটিংস';

  @override
  String get settingsPlayerSubtitle => 'স্ট্রিম কোয়ালিটি, অটো প্লে ইত্যাদি।';

  @override
  String get settingsPluginDefaults => 'প্লাগইন ডিফল্ট';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'ডিসকভার সোর্স, রিজলভার প্রিয়োরিটি।';

  @override
  String get settingsUIElements => 'UI এলিমেন্টসমূহ';

  @override
  String get settingsUIElementsSubtitle => 'অটো স্লাইড, UI টুইকস ইত্যাদি।';

  @override
  String get settingsLastFM => 'Last.FM সেটিংস';

  @override
  String get settingsLastFMSubtitle => 'API কী, সিক্রেট এবং স্ক্রবলিং সেটিংস।';

  @override
  String get settingsStorage => 'স্টোরেজ';

  @override
  String get settingsStorageSubtitle =>
      'ব্যাকআপ, ক্যাশে, হিস্ট্রি, রিস্টোর এবং আরও অনেক কিছু...';

  @override
  String get settingsLanguageCountry => 'ভাষা এবং দেশ';

  @override
  String get settingsLanguageCountrySubtitle =>
      'আপনার ভাষা এবং দেশ নির্বাচন করুন।';

  @override
  String get settingsAbout => 'সম্পর্কে';

  @override
  String get settingsAboutSubtitle =>
      'অ্যাপ সম্পর্কে, ভার্সন, ডেভেলপার ইত্যাদি।';

  @override
  String get settingsScanning => 'স্ক্যান করা হচ্ছে';

  @override
  String get settingsMusicFolders => 'মিউজিক ফোল্ডারসমূহ';

  @override
  String get settingsQuality => 'কোয়ালিটি';

  @override
  String get settingsHistory => 'হিস্ট্রি';

  @override
  String get settingsBackupRestore => 'ব্যাকআপ এবং রিস্টোর';

  @override
  String get settingsAutomatic => 'স্বয়ংক্রিয়';

  @override
  String get settingsDangerZone => 'বিপজ্জনক জোন';

  @override
  String get settingsScrobbling => 'স্ক্রবলিং';

  @override
  String get settingsAuthentication => 'অথেনটিকেশন';

  @override
  String get settingsHomeScreen => 'হোম স্ক্রিন';

  @override
  String get settingsChartVisibility => 'চার্ট ভিজিবিলিটি';

  @override
  String get dialogAddingToDownloadQueue => 'ডাউনলোড কিউতে যোগ করা হচ্ছে';

  @override
  String get emptyNoInternet => 'কোন ইন্টারনেট কানেকশন নেই!';

  @override
  String get emptyNoContentPlugin =>
      'কোন কন্টেন্ট প্লাগইন লোড করা নেই। প্লাগইন ম্যানেজারে কন্টেন্ট রিজলভার লোড করুন।';

  @override
  String get emptyRefreshingSource =>
      'ডিসকভার সোর্স রিফ্রেশ করা হচ্ছে... আগের সোর্সটি আর উপলব্ধ নেই।';

  @override
  String get emptyNoTracks => 'কোন ট্র্যাক উপলব্ধ নেই';

  @override
  String get emptyNoResults => 'কোন মিল পাওয়া যায়নি';

  @override
  String snackbarDeletedTrack(String title) {
    return '\"$title\" ডিলিট করা হয়েছে';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return '\"$title\" ডিলিট করতে ব্যর্থ হয়েছে';
  }

  @override
  String get snackbarAddedToNextQueue =>
      'কিউতে এর পরে প্লে করার জন্য জোড়া হয়েছে';

  @override
  String get snackbarAddedToQueue => 'কিউতে যোগ করা হয়েছে';

  @override
  String snackbarAddedToLiked(String title) {
    return '$title লাইকড গানে যোগ করা হয়েছে!!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return '$name প্লে হচ্ছে';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return 'কিউতে $name যোগ করা হয়েছে';
  }

  @override
  String get snackbarPlaylistUpdated => 'প্লেলিস্ট আপডেট করা হয়েছে!';

  @override
  String get snackbarLinkCopied => 'লিঙ্ক কপি করা হয়েছে';

  @override
  String get snackbarCouldNotOpenLink => 'লিঙ্কটি খোলা যায়নি';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'ডাউনলোড কিউতে $countটি গান যোগ করা হয়েছে';
  }

  @override
  String get searchHintExplore => 'আপনি কি শুনতে চান?';

  @override
  String get searchHintLibrary => 'লাইব্রেরিতে খুঁজুন...';

  @override
  String get searchHintPlaylists => 'প্লেলিস্ট খুঁজুন...';

  @override
  String get searchStartTyping => 'খুঁজতে টাইপ করা শুরু করুন...';

  @override
  String get searchNoSuggestions => 'কোন সাজেশন পাওয়া যায়নি!';

  @override
  String get searchNoResults =>
      'কোন ফলাফল পাওয়া যায়নি!\nঅন্য কোন কি-ওয়ার্ড বা সোর্স চেষ্টা করুন।';

  @override
  String get searchFailed => 'অনুসন্ধান ব্যর্থ হয়েছে!';

  @override
  String get searchDiscover => 'অসাধারণ মিউজিক খুঁজুন...';

  @override
  String get searchSources => 'সোর্সসমূহ';

  @override
  String get searchNoPlugins => 'কোন প্লাগইন ইনস্টল করা নেই';

  @override
  String get searchTracks => 'ট্র্যাকসমূহ';

  @override
  String get searchAlbums => 'অ্যালবামসমূহ';

  @override
  String get searchArtists => 'আর্টিস্টসমূহ';

  @override
  String get searchPlaylists => 'প্লেলিস্টসমূহ';

  @override
  String get exploreDiscover => 'ডিসকভার';

  @override
  String get exploreRecently => 'সাম্প্রতিক';

  @override
  String get exploreLastFmPicks => 'Last.Fm চয়েস';

  @override
  String get exploreFailedToLoad => 'হোম সেকশন লোড করতে ব্যর্থ হয়েছে।';

  @override
  String get libraryTitle => 'লাইব্রেরি';

  @override
  String get libraryEmptyState =>
      'আপনার লাইব্রেরি একা বোধ করছে। কিছু গান যোগ করুন!';

  @override
  String libraryIn(String playlistName) {
    return '$playlistName-এ';
  }

  @override
  String get menuAddToPlaylist => 'প্লেলিস্টে যোগ করুন';

  @override
  String get menuSmartReplace => 'স্মার্ট রিপ্লেস';

  @override
  String get menuShare => 'শেয়ার করুন';

  @override
  String get menuAvailableOffline => 'অফলাইনে পাওয়া যাবে';

  @override
  String get menuDownload => 'ডাউনলোড';

  @override
  String get menuOpenOriginalLink => 'আসল লিঙ্কটি খুলুন';

  @override
  String get menuDeleteTrack => 'ডিলিট করুন';

  @override
  String get tooltipRemoveFromLibrary => 'লাইব্রেরি থেকে সরিয়ে ফেলুন';

  @override
  String get tooltipSaveToLibrary => 'লাইব্রেরিতে সেভ করুন';

  @override
  String get tooltipOpenOriginalLink => 'আসল লিঙ্কটি খুলুন';

  @override
  String get tooltipAvailableOffline => 'অফলাইনে পাওয়া যাবে';

  @override
  String get tooltipMoreOptions => 'আরও অপশন';

  @override
  String get appuiTitle => 'UI এবং সার্ভিসসমূহ';

  @override
  String get appuiAutoSlideCharts => 'অটো স্লাইড চার্ট';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'হোম স্ক্রিনে চার্টগুলো অটো স্লাইড করুন।';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Last.FM থেকে সাজেশন দেখান। লগইন এবং অ্যাপ রিস্টার্ট প্রয়োজন।';

  @override
  String get appuiNoChartsAvailable =>
      'কোন চার্ট উপলব্ধ নেই। একটি চার্ট প্রোভাইডার প্লাগইন লোড করুন।';

  @override
  String get appuiLoginToLastFm => 'অনুগ্রহ করে আগে Last.FM-এ লগইন করুন।';

  @override
  String get appuiShowInCarousel => 'হোম ক্যারোজেলে দেখান।';

  @override
  String get countrySettingTitle => 'দেশ এবং ভাষা';

  @override
  String get countrySettingAutoDetect => 'দেশ অটো ডিটেক্ট করুন';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'অ্যাপ খোলার সময় স্বয়ংক্রিয়ভাবে আপনার দেশ ডিটেক্ট করুন।';

  @override
  String get countrySettingCountryLabel => 'দেশ';

  @override
  String get countrySettingLanguageLabel => 'ভাষা';

  @override
  String get countrySettingSystemDefault => 'সিস্টেম ডিফল্ট';

  @override
  String get downloadSettingTitle => 'ডাউনলোডসমূহ';

  @override
  String get downloadSettingQuality => 'ডাউনলোড কোয়ালিটি';

  @override
  String get downloadSettingQualitySubtitle =>
      'ডাউনলোড করা ট্র্যাকের জন্য অডিও কোয়ালিটি পছন্দ।';

  @override
  String get downloadSettingFolder => 'ডাউনলোড ফোল্ডার';

  @override
  String get downloadSettingResetFolder => 'ডাউনলোড ফোল্ডার রিসেট করুন';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'ডিফল্ট ডাউনলোড পাথ রিস্টোর করুন।';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'ট্র্যাক স্ক্রবল করুন';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'প্লে হওয়া ট্র্যাকগুলো আপনার Last.FM প্রোফাইলে পাঠান।';

  @override
  String get lastfmAuthFirst => 'প্রথমে Last.FM API অথেন্টিকেট করুন।';

  @override
  String get lastfmAuthenticatedAs => 'অথেন্টিকেটেড হিসেবে';

  @override
  String get lastfmAuthFailed => 'অথেনটিকেশন ব্যর্থ হয়েছে:';

  @override
  String get lastfmNotAuthenticated => 'অথেন্টিকেটেড নয়';

  @override
  String get lastfmSteps =>
      'অথেন্টিকেশনের ধাপসমূহ:\n১. last.fm-এ একটি অ্যাকাউন্ট তৈরি করুন বা খুলুন\n২. last.fm/api/account/create-এ API কী তৈরি করুন\n৩. আপনার API কী এবং সিক্রেট নিচে দিন\n৪. \"Start Auth\" ট্যাপ করুন এবং ব্রাউজারে অনুমতি দিন\n৫. শেষ করতে \"Get & Save Session Key\" ট্যাপ করুন';

  @override
  String get lastfmApiKey => 'API কী';

  @override
  String get lastfmApiSecret => 'API সিক্রেট';

  @override
  String get lastfmStartAuth => '১. স্টার্ট অথেন্টিকেশন';

  @override
  String get lastfmGetSession => '২. সেশন কী সেভ করুন';

  @override
  String get lastfmRemoveKeys => 'কী-গুলো সরিয়ে ফেলুন';

  @override
  String get lastfmStartAuthFirst =>
      'প্রথমে স্টার্ট অথেন্টিকেশন করুন, তারপর ব্রাউজারে অনুমতি দিন।';

  @override
  String get localSettingTitle => 'লোকাল ট্র্যাকসমূহ';

  @override
  String get localSettingAutoScan => 'স্টার্টআপে অটো স্ক্যান';

  @override
  String get localSettingAutoScanSubtitle =>
      'অ্যাপ চালু করার সময় অটোমেটিক লোকাল ট্র্যাক স্ক্যান করুন।';

  @override
  String get localSettingLastScan => 'শেষ স্ক্যান';

  @override
  String get localSettingNeverScanned => 'কখনও না';

  @override
  String get localSettingScanInProgress => 'স্ক্যান করা হচ্ছে…';

  @override
  String get localSettingScanNowSubtitle =>
      'নিজে থেকে পুরো লাইব্রেরি স্ক্যান করুন।';

  @override
  String get localSettingNoFolders =>
      'কোন ফোল্ডার যোগ করা নেই। শুরু করতে ফোল্ডার যোগ করুন।';

  @override
  String get localSettingAddFolder => 'ফোল্ডার যোগ করুন';

  @override
  String get playerSettingTitle => 'প্লেয়ার সেটিংস';

  @override
  String get playerSettingStreamingHeader => 'স্ট্রিমিং';

  @override
  String get playerSettingStreamQuality => 'স্ট্রিমিং কোয়ালিটি';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'অনলাইন প্লেব্যাকের জন্য অডিও বিটরেট।';

  @override
  String get playerSettingQualityLow => 'লো';

  @override
  String get playerSettingQualityMedium => 'মিডিয়াম';

  @override
  String get playerSettingQualityHigh => 'হাই';

  @override
  String get playerSettingPlaybackHeader => 'প্লেব্যাক';

  @override
  String get playerSettingAutoPlay => 'অটো প্লে';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'কিউ শেষ হলে একই ধরণের গান কিউতে যোগ করুন।';

  @override
  String get playerSettingAutoFallback => 'অটো ফলব্যাক প্লেব্যাক';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'প্লাগইন মিসিং বা স্ট্রিম না থাকলে বিকল্প সোর্স দিয়ে প্লে করার চেষ্টা করুন।';

  @override
  String get playerSettingCrossfade => 'ক্রসফেড';

  @override
  String get playerSettingCrossfadeOff => 'বন্ধ';

  @override
  String get playerSettingCrossfadeInstant =>
      'তাৎক্ষণিকভাবে ট্র্যাক পরিবর্তন হবে';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'ট্র্যাকের মধ্যে $seconds সেকেন্ড ব্লেন্ড হবে';
  }

  @override
  String get playerSettingEqualizer => 'ইকুয়ালাইজার';

  @override
  String get playerSettingEqualizerActive => 'সক্রিয়';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'চালু আছে — $preset প্রিসেট';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'FFmpeg-এর মাধ্যমে ১০-ব্যান্ডের ইকুয়ালাইজার।';

  @override
  String get pluginDefaultsTitle => 'প্লাগইন ডিফল্ট';

  @override
  String get pluginDefaultsDiscoverHeader => 'ডিসকভার সোর্স';

  @override
  String get pluginDefaultsNoResolver =>
      'কোন কন্টেন্ট রিজলভার লোড করা নেই। ডিসকভার সোর্স চয়েস করতে প্লাগইন লোড করুন।';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'প্রথম সচল কন্টেন্ট রিজলভার ব্যবহার করুন।';

  @override
  String get pluginDefaultsPriorityHeader => 'রিজলভার প্রিয়োরিটি';

  @override
  String get pluginDefaultsNoPriority =>
      'কোন কন্টেন্ট রিজলভার লোড করা নেই। প্লাগইন লোড হলে এখানে ক্রম দেখাবে।';

  @override
  String get pluginDefaultsPriorityDesc =>
      'ক্রম পরিবর্তনের জন্য ড্র্যাগ করুন। হাই প্রিয়োরিটি রিজলভারগুলো আগে চেষ্টা করা হয়।';

  @override
  String get pluginDefaultsLyricsHeader => 'লিরিক্স প্রিয়োরিটি';

  @override
  String get pluginDefaultsLyricsNone => 'কোন লিরিক্স প্রোভাইডার লোড করা নেই।';

  @override
  String get pluginDefaultsLyricsDesc =>
      'লিরিক্স প্রোভাইডারের ক্রম পরিবর্তনের জন্য ড্র্যাগ করুন। প্রথমটি আগে চেষ্টা করা হবে।';

  @override
  String get pluginDefaultsSuggestionsHeader => 'সার্চ সাজেশন';

  @override
  String get pluginDefaultsSuggestionsNone =>
      'কোন সাজেশন প্রোভাইডার লোড করা নেই।';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'নাই';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'শুধু সার্চ হিস্ট্রি ব্যবহার করুন।';

  @override
  String get storageSettingTitle => 'স্টোরেজ';

  @override
  String get storageClearHistoryEvery => 'হিস্ট্রি ক্লিয়ার করার সময়কাল';

  @override
  String get storageClearHistorySubtitle =>
      'নির্দিষ্ট সময় পর অটো হিস্ট্রি ক্লিয়ার করুন।';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন',
      one: '১ দিন',
    );
    return '$_temp0';
  }

  @override
  String storageBackupCreatedAt(String path) {
    return 'ব্যাকআপ তৈরি হয়েছে এখানে: $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'ব্যাকআপ শেয়ার করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get storageRestoreBackup => 'ব্যাকআপ রিস্টোর করুন';

  @override
  String get storageRestoreBackupSubtitle =>
      'ব্যাকআপ ফাইল থেকে আপনার সেটিংস এবং ডেটা রিস্টোর করুন।';

  @override
  String get storageAutoBackup => 'অটো ব্যাকআপ';

  @override
  String get storageAutoLyrics => 'লিরিক্স অটো সেভ করুন';

  @override
  String get storageAutoLyricsSubtitle =>
      'গান প্লে হওয়ার সময় অটোমেটিক লিরিক্স সেভ করুন।';

  @override
  String get storageResetApp => 'অ্যাপ রিসেট করুন';

  @override
  String get storageResetConfirmTitle => 'রিসেট কনফার্ম করুন';

  @override
  String get storageResetButton => 'রিসেট';

  @override
  String get storageRestoreOptionsTitle => 'রিস্টোর অপশনসমূহ';

  @override
  String get storageRestoreContinue => 'চালিয়ে যান';

  @override
  String get storageRestoreConfirmTitle => 'রিস্টোর কনফার্ম করুন';

  @override
  String get storageRestoreYes => 'হ্যাঁ, রিস্টোর করুন';

  @override
  String get storageRestoring =>
      'নির্বাচিত ডেটা রিস্টোর করা হচ্ছে… অনুগ্রহ করে শেষ হওয়া পর্যন্ত অপেক্ষা করুন।';

  @override
  String get storageRestoreFailedTitle => 'রিস্টোর ব্যর্থ হয়েছে';

  @override
  String get updateSettingTitle => 'আপডেটসমূহ';

  @override
  String get updateCheckForUpdates => 'আপডেটের জন্য চেক করুন';

  @override
  String get updateCheckSubtitle => 'অ্যাপের নতুন কোন ভার্সন এসেছে কিনা দেখুন।';

  @override
  String get updateAutoNotify => 'অটো আপডেট নোটিফাই';

  @override
  String get updateAutoNotifySubtitle =>
      'নতুন আপডেট থাকলে অ্যাপ চালু হওয়ার সময় নোটিফিকেশন পান।';

  @override
  String get updateCheckTitle => 'আপডেটের জন্য চেক করা হচ্ছে';

  @override
  String get updateUpToDate => 'অ্যাপটি আপ-টু-ডেট আছে!!!';

  @override
  String get updateViewPreRelease => 'লেটেস্ট প্রি-রিলিজ দেখুন';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'বর্তমান ভার্সন: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable => 'অ্যাপের নতুন ভার্সন এসেছে!!';

  @override
  String updateVersion(String ver, String build) {
    return 'ভার্সন: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'এখনই ডাউনলোড করুন';

  @override
  String get updateChecking => 'নতুন ভার্সন চেক করা হচ্ছে!';

  @override
  String get timerTitle => 'স্লিপ টাইমার';

  @override
  String get timerInterludeMessage => 'টাইমার শেষ হবে…';

  @override
  String get timerHours => 'ঘন্টা';

  @override
  String get timerMinutes => 'মিনিট';

  @override
  String get timerSeconds => 'সেকেন্ড';

  @override
  String get timerStop => 'টাইমার বন্ধ করুন';

  @override
  String get timerFinishedMessage => 'টাইমার শেষ হয়েছে। শুভ রাত্রি 🥰।';

  @override
  String get timerGotIt => 'বুঝেছি!';

  @override
  String get timerSetTimeError => 'অনুগ্রহ করে সময় সেট করুন';

  @override
  String get timerStart => 'টাইমার শুরু করুন';

  @override
  String get notificationsTitle => 'নোটিফিকেশনসমূহ';

  @override
  String get notificationsEmpty => 'এখনও কোন নোটিফিকেশন নেই!';

  @override
  String get recentsTitle => 'হিস্ট্রি';

  @override
  String playlistByCreator(String creator) {
    return '$creator-এর তৈরি';
  }

  @override
  String get playlistYou => 'আপনি';

  @override
  String get pluginManagerTitle => 'প্লাগইনসমূহ';

  @override
  String get pluginManagerEmpty =>
      'কোন প্লাগইন ইনস্টল করা নেই।\n+ ট্যাপ করে .bex ফাইল যোগ করুন।';

  @override
  String get pluginManagerFilterAll => 'সব';

  @override
  String get pluginManagerFilterContent => 'কন্টেন্ট রিজলভার';

  @override
  String get pluginManagerFilterCharts => 'চার্ট প্রোভাইডার';

  @override
  String get pluginManagerFilterLyrics => 'লিরিক্স প্রোভাইডার';

  @override
  String get pluginManagerFilterSuggestions => 'সাজেশন প্রোভাইডার';

  @override
  String get pluginManagerFilterImporters => 'কন্টেন্ট ইমপোর্টার';

  @override
  String get pluginManagerTooltipRefresh => 'রিফ্রেশ';

  @override
  String get pluginManagerTooltipInstall => 'প্লাগইন ইনস্টল করুন';

  @override
  String get pluginManagerNoMatch => 'ফিল্টারের সাথে মিলছে এমন কোন প্লাগইন নেই';

  @override
  String pluginManagerPickFailed(String error) {
    return 'ফাইল বাছাই করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get pluginManagerInstalling => 'প্লাগইন ইনস্টল করা হচ্ছে...';

  @override
  String get pluginManagerTypeContentResolver => 'কন্টেন্ট রিজলভার';

  @override
  String get pluginManagerTypeChartProvider => 'চার্ট প্রোভাইডার';

  @override
  String get pluginManagerTypeLyricsProvider => 'লিরিক্স প্রোভাইডার';

  @override
  String get pluginManagerTypeSuggestionProvider => 'সার্চ সাজেশন';

  @override
  String get pluginManagerTypeContentImporter => 'কন্টেন্ট ইমপোর্টার';

  @override
  String get pluginManagerDeleteTitle => 'প্লাগইন ডিলিট করবেন?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'আপনি কি নিশ্চিত যে আপনি \"$name\" ডিলিট করতে চান? এর সব ফাইল মুছে যাবে।';
  }

  @override
  String get pluginManagerDeleteAction => 'ডিলিট';

  @override
  String get pluginManagerCancel => 'বাতিল';

  @override
  String get pluginManagerEnablePlugin => 'প্লাগইন চালু করুন';

  @override
  String get pluginManagerUnloadPlugin => 'প্লাগইন বন্ধ করুন';

  @override
  String get pluginManagerDeleting => 'ডিলিট করা হচ্ছে...';

  @override
  String get pluginManagerApiKeysTitle => 'API কী';

  @override
  String get pluginManagerApiKeysSaved => 'API কী সেভ করা হয়েছে';

  @override
  String get pluginManagerSave => 'সেভ করুন';

  @override
  String get pluginManagerDetailVersion => 'ভার্সন';

  @override
  String get pluginManagerDetailType => 'ধরণ';

  @override
  String get pluginManagerDetailPublisher => 'পাবলিশার';

  @override
  String get pluginManagerDetailLastUpdated => 'শেষ আপডেট';

  @override
  String get pluginManagerDetailCreated => 'তৈরি হয়েছে';

  @override
  String get pluginManagerDetailHomepage => 'হোমপেজ';

  @override
  String get pluginManagerDeleteStorageTitle => 'প্লাগইন ডেটা ডিলিট করবেন?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return '\"$name\"-এর সেভ করা API কী এবং সেটিংসও কি ডিলিট করবেন?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'ডেটা রাখুন';

  @override
  String get pluginManagerDeleteStorageRemove => 'ডেটা ডিলিট করুন';

  @override
  String get segmentsSheetTitle => 'সেগমেন্টসমূহ';

  @override
  String get segmentsSheetEmpty => 'কোন সেগমেন্ট নেই';

  @override
  String get segmentsSheetUntitled => 'নামহীন সেগমেন্ট';

  @override
  String get smartReplaceTitle => 'স্মার্ট রিপ্লেস';

  @override
  String smartReplaceSubtitle(String title) {
    return '\"$title\"-এর জন্য প্লে করা যায় এমন বিকল্প বেছে নিন।';
  }

  @override
  String get smartReplaceClose => 'বন্ধ করুন';

  @override
  String get smartReplaceNoMatch => 'কোন বিকল্প পাওয়া যায়নি';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'কোন প্লাগইন দিয়ে সঠিক মিল পাওয়া যায়নি।';

  @override
  String get smartReplaceBestMatch => 'সবচেয়ে ভালো মিল';

  @override
  String get smartReplaceSearchFailed => 'সার্চ ব্যর্থ হয়েছে';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'স্মার্ট রিপ্লেস ব্যর্থ হয়েছে: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'বিকল্প ট্র্যাক কিউতে সেট করা হয়েছে।';
  }

  @override
  String get smartReplaceQueueUpdated => ' এবং কিউ আপডেট করা হয়েছে';

  @override
  String get playerUnknownQueue => 'অজানা';

  @override
  String playerLiked(String title) {
    return '$title লাইকড!!';
  }

  @override
  String playerUnliked(String title) {
    return '$title আনলাইকড!!';
  }

  @override
  String get offlineNoDownloads => 'কোন ডাউনলোড নেই';

  @override
  String get offlineTitle => 'অফলাইন';

  @override
  String get offlineSearchHint => 'গান খুঁজুন...';

  @override
  String get offlineRefreshTooltip => 'রিফ্রেশ করুন';

  @override
  String get offlineCloseSearch => 'সার্চ বন্ধ করুন';

  @override
  String get offlineSearchTooltip => 'অনুসন্ধান';

  @override
  String get offlineOpenFailed =>
      'অফলাইন ট্র্যাকটি খোলা যাচ্ছে না। একবার রিফ্রেশ করে দেখুন।';

  @override
  String get offlinePlayFailed =>
      'অফলাইন গানটি প্লে করা যাচ্ছে না। অনুগ্রহ করে আবার চেষ্টা করুন।';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ট্র্যাক',
      one: '১টি ট্র্যাক',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'অ্যালবাম লোড করতে ব্যর্থ হয়েছে';

  @override
  String get aboutCraftingSubtitle => 'প্রোগ্রামিংয়ের মাধ্যমে মিউজিকের সৃজন।';

  @override
  String get aboutFollowGitHub => 'গিটহাবে তাকে ফলো করুন';

  @override
  String get aboutSendInquiry => 'বিজনেস ইনকোয়ারি পাঠান';

  @override
  String get aboutCreativeHighlights => 'আপডেট এবং সৃজনশীল কাজ';

  @override
  String get aboutTipQuote =>
      'অ্যাপটি কি ভালো লাগছে? ছোট একটি সাহায্য এটিকে সচল রাখতে সহায়তা করবে। ';

  @override
  String get aboutTipButton => 'সাহায্য করব';

  @override
  String get aboutTipDesc => 'আমি চাই অ্যাপটি আরও উন্নত হোক।';

  @override
  String get aboutGitHub => 'গিটহাব';

  @override
  String get songInfoSectionDetails => 'গানের বিস্তারিত';

  @override
  String get songInfoSectionTechnical => 'টেকনিক্যাল তথ্য';

  @override
  String get songInfoSectionActions => 'পদক্ষেপ';

  @override
  String get songInfoLabelTitle => 'শিরোনাম';

  @override
  String get songInfoLabelArtist => 'আর্টিস্ট';

  @override
  String get songInfoLabelAlbum => 'অ্যালবাম';

  @override
  String get songInfoLabelDuration => 'সময়কাল';

  @override
  String get songInfoLabelSource => 'সোর্স';

  @override
  String get songInfoLabelMediaId => 'মিডিয়া আইডি';

  @override
  String get songInfoLabelPluginId => 'প্লাগইন আইডি';

  @override
  String get songInfoCopyId => 'আইডি কপি করুন';

  @override
  String get songInfoCopyLink => 'লিঙ্ক কপি করুন';

  @override
  String get songInfoOpenBrowser => 'ব্রাউজারে খুলুন';

  @override
  String get songInfoIdCopied => 'আইডি কপি করা হয়েছে';

  @override
  String get songInfoLinkCopied => 'লিঙ্ক কপি করা হয়েছে';

  @override
  String get songInfoNoLink => 'লিঙ্ক উপলব্ধ নেই';

  @override
  String get songInfoOpenFailed => 'লিঙ্ক খোলা যায়নি';

  @override
  String get songInfoUpdateMetadata => 'মেটাডেটা আপডেট করুন';

  @override
  String get songInfoMetadataUpdated => 'মেটাডেটা আপডেট করা হয়েছে';

  @override
  String get songInfoMetadataUpdateFailed => 'মেটাডেটা আপডেট করতে ব্যর্থ হয়েছে';

  @override
  String get songInfoMetadataUnavailable =>
      'এই সোর্সের জন্য রিফ্রেশ পাওয়া যাচ্ছে না';

  @override
  String get songInfoSearchTitle => 'অ্যাপে এই গানটি খুঁজুন';

  @override
  String get songInfoSearchArtist => 'এই আর্টিস্টকে খুঁজুন';

  @override
  String get songInfoSearchAlbum => 'এই অ্যালবামটি খুঁজুন';

  @override
  String get eqTitle => 'ইকুয়ালাইজার';

  @override
  String get chartNoItems => 'এই চার্টে কিছু নেই';

  @override
  String get chartLoadFailed => 'চার্ট লোড করতে ব্যর্থ হয়েছে';

  @override
  String get chartPlay => 'প্লে';

  @override
  String get chartResolving => 'তৈরি হচ্ছে';

  @override
  String get chartReady => 'প্রস্তুত';

  @override
  String get chartAddToPlaylist => 'প্লেলিস্টে যোগ করুন';

  @override
  String get chartNoResolver => 'প্লে করার জন্য প্লাগইন ইনস্টল করুন।';

  @override
  String get chartResolveFailed => 'অন্য উপায়ে চেষ্টা করা হচ্ছে...';

  @override
  String get chartNoResolverAdd => 'কোন কন্টেন্ট রিজলভার নেই।';

  @override
  String get chartNoMatch => 'কোন মিল পাওয়া যায়নি। নিজে থেকে খুঁজে দেখুন।';

  @override
  String get chartStatPeak => 'শীর্ষ';

  @override
  String get chartStatWeeks => 'সপ্তাহ';

  @override
  String get chartStatChange => 'পরিবর্তন';

  @override
  String menuSharePreparing(String title) {
    return 'শেয়ারের জন্য $title প্রস্তুত করা হচ্ছে।';
  }

  @override
  String get menuOpenLinkFailed => 'লিঙ্ক খোলা যায়নি';

  @override
  String get localMusicFolders => 'মিউজিক ফোল্ডারসমূহ';

  @override
  String get localMusicRemoveFolder => 'ফোল্ডার সরিয়ে ফেলুন';

  @override
  String get localMusicCloseSearch => 'সার্চ বন্ধ করুন';

  @override
  String get localMusicOpenSearch => 'অনুসন্ধান';

  @override
  String get localMusicNoMusicFound => 'কোন লোকাল মিউজিক পাওয়া যায়নি';

  @override
  String get localMusicNoSearchResults =>
      'আপনার অনুসন্ধানের সাথে মিলছে এমন কোন ট্র্যাক নেই।';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ট্র্যাক',
      one: '১টি ট্র্যাক',
      zero: 'কোন ট্র্যাক নেই',
    );
    return '$_temp0';
  }

  @override
  String get importSongsTitle => 'গান ইমপোর্ট করুন';

  @override
  String get importNoPluginsLoaded =>
      'কোন ইমপোর্টার প্লাগইন নেই। বাইরের সার্ভিস থেকে প্লেলিস্ট ইমপোর্ট করতে প্লাগইন ইনস্টল করুন।';

  @override
  String get importBloomeeFiles => 'Import Beats Files';

  @override
  String get importM3UFiles => 'M3U প্লেলিস্ট ইমপোর্ট করুন';

  @override
  String get importM3UNameDialogTitle => 'প্লেলিস্টের নাম';

  @override
  String get importM3UNameHint => 'প্লেলিস্টের নাম দিন';

  @override
  String get importM3UNoTracks => 'ফাইলে কোন ট্র্যাক পাওয়া যায়নি।';

  @override
  String get importNoteTitle => 'নোট';

  @override
  String get importNoteMessage =>
      'শুধু এই অ্যাপের মাধ্যমে তৈরি ফাইলই ইমপোর্ট করা যাবে। চালিয়ে যাবেন?';

  @override
  String get importTitle => 'ইমপোর্ট';

  @override
  String get importCheckingUrl => 'URL চেক করা হচ্ছে...';

  @override
  String get importFetchingTracks => 'গান আনা হচ্ছে...';

  @override
  String get importSavingToLibrary => 'লাইব্রেরিতে সেভ হচ্ছে...';

  @override
  String get importPasteUrlHint => 'ইমপোর্ট করতে প্লেলিস্ট বা অ্যালবাম URL দিন';

  @override
  String get importAction => 'ইমপোর্ট';

  @override
  String importTrackCount(int count) {
    return '$countটি ট্র্যাক';
  }

  @override
  String importResolvingProgress(int done, int total) {
    return 'তৈরি হচ্ছে: $done / $total';
  }

  @override
  String importSaveTracks(int count) {
    return '$countটি ট্র্যাক সেভ করুন';
  }

  @override
  String importTracksSaved(int count) {
    return '$countটি ট্র্যাক সেভ করা হয়েছে!';
  }

  @override
  String get importDone => 'সম্পন্ন';

  @override
  String get importMore => 'আরও ইমপোর্ট করুন';

  @override
  String get importUnknownError => 'অজানা ত্রুটি';

  @override
  String get importTryAgain => 'আবার চেষ্টা করুন';

  @override
  String get importSkipTrack => 'এই ট্র্যাকটি বাদ দিন';

  @override
  String get importMatchOptions => 'অপশনসমূহ';

  @override
  String get importSkipped => 'বাদ দেওয়া হয়েছে';

  @override
  String get importReorderTip => 'প্লেলিস্টের ক্রম পরিবর্তন করতে লং প্রেস করুন';

  @override
  String get importErrorCannotHandleUrl =>
      'এই প্লাগইনটি দিয়ে এই লিঙ্কটি কাজ করবে না।';

  @override
  String get importErrorUnexpectedResponse => 'অপ্রত্যাশিত ফলাফল।';

  @override
  String importErrorFailedToCheck(String error) {
    return 'লিঙ্ক চেক করতে ব্যর্থ: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'সংগ্রহের তথ্য আনতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'ট্র্যাক আনতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'প্লেলিস্ট সংরক্ষণ করতে ব্যর্থ হয়েছে: $error';
  }

  @override
  String get playlistPinToTop => 'উপরে পিন করুন';

  @override
  String get playlistUnpin => 'আনপিন করুন';

  @override
  String get snackbarInvalidFileFormat => 'ভুল ফাইল ফরম্যাট';

  @override
  String get snackbarProcessingFile => 'ফাইল প্রসেস করা হচ্ছে...';

  @override
  String get pluginManagerTabInstalled => 'ইনস্টলড';

  @override
  String get pluginManagerTabStore => 'স্টোর';

  @override
  String get pluginManagerSelectPackage => 'প্লাগইন প্যাকেজ (.bex) লেক্ট করুন';

  @override
  String get pluginManagerOutdatedManifest =>
      'পুরনো ম্যানিফেস্ট ভার্সন। কিছু কাজ নাও করতে পারে।';

  @override
  String get pluginManagerStatusActive => 'সক্রিয়';

  @override
  String get pluginManagerStatusInactive => 'অসক্রিয়';

  @override
  String get pluginRepositoryAddTitle => 'প্লাগইন রিপোজিটরি যোগ করুন';

  @override
  String get pluginRepositoryAddSubtitle =>
      'প্লাগইন খুঁজতে এবং ইনস্টল করতে রিপোজিটরি JSON URL পেস্ট করুন।';

  @override
  String get pluginRepositoryAddAction => 'রিপোজিটরি যোগ করুন';

  @override
  String get pluginRepositoryTitle => 'প্লাগইন রিপোজিটরি';

  @override
  String get pluginRepositorySubtitle => 'রিমোট সোর্স থেকে প্লাগইন খুঁজুন';

  @override
  String get pluginRepositoryEmpty => 'এখনও কোন রিপোজিটরি যোগ করা হয়নি';

  @override
  String get pluginRepositoryUnknownUpdate => 'অজানা';

  @override
  String get pluginRepositoryNoDescription => 'কোন বর্ণনা উপলব্ধ নেই';

  @override
  String get pluginRepositoryUrlCopied =>
      'রিপোজিটরি URL ক্লিপবোর্ডে কপি করা হয়েছে';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্লাগইন',
      one: '১টি প্লাগইন',
    );
    return '$_temp0';
  }

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'আপডেট হয়েছে $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্লাগইন উপলব্ধ',
      one: '১টি প্লাগইন উপলব্ধ',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest => 'পুরনো ম্যানিফেস্ট।';

  @override
  String get pluginRepositoryUnknownPublisher => 'অজানা পাবলিশার';

  @override
  String get pluginRepositoryActionRetry => 'আবার চেষ্টা করুন';

  @override
  String get pluginRepositoryActionOutdated => 'পুরনো';

  @override
  String get pluginRepositoryActionInstalled => 'ইনস্টলড';

  @override
  String get pluginRepositoryActionInstall => 'ইনস্টল';

  @override
  String get pluginRepositoryActionUnavailable => 'অনুপলব্ধ';

  @override
  String get pluginRepositoryInstallFailed => 'ইনস্টলেশন ব্যর্থ হয়েছে।';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return '$name ডাউনলোড করতে ব্যর্থ হয়েছে।';
  }

  @override
  String get pluginRepositoryErrorLoad =>
      'রিপোজিটরি লোড করতে ব্যর্থ হয়েছে। আপনার কানেকশন চেক করুন।';

  @override
  String get pluginRepositoryErrorInvalid => 'ভুল রিপোজিটরি URL বা ফরম্যাট।';

  @override
  String get pluginRepositoryErrorRemove => 'রিপোজিটরি সরাতে ব্যর্থ হয়েছে।';

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি প্লেলিস্টে পরিবর্তন করা হয়েছে।',
      one: '১টি প্লেলিস্টে পরিবর্তন করা হয়েছে।',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'লিরিক্স খুঁজুন...';

  @override
  String get lyricsSearchEmptyPrompt =>
      'গান বা আর্টিস্টের নাম লিখে লিরিক্স খুঁজুন।';

  @override
  String lyricsSearchNoResults(String query) {
    return '\"$query\"-এর জন্য কোন লিরিক্স পাওয়া যায়নি';
  }

  @override
  String get lyricsSearchApplied => 'লিরিক্স সেট করা হয়েছে';

  @override
  String get lyricsSearchFetchFailed => 'লিরিক্স আনতে ব্যর্থ হয়েছে';

  @override
  String get lyricsSearchPreview => 'প্রিভিউ';

  @override
  String get lyricsSearchPreviewTooltip => 'প্রিভিউ দেখুন';

  @override
  String get lyricsSearchSynced => 'সিনক্রোনাাইজড';

  @override
  String get lyricsSearchPreviewLoadFailed => 'লোড করতে ব্যর্থ হয়েছে।';

  @override
  String get lyricsSearchApplyAction => 'লিরিক্স সেট করুন';

  @override
  String get lyricsSettingsSearchTitle => 'লিরিক্স খুঁজুন';

  @override
  String get lyricsSettingsSearchSubtitle => 'অনলাইনে অন্য সোর্স খুঁজুন';

  @override
  String get lyricsSettingsSyncTitle => 'সিনক্রোনাইজেশন ঠিক করুন';

  @override
  String get lyricsSettingsSyncSubtitle => 'লিরিক্স আগে পিছে হলে ঠিক করুন';

  @override
  String get lyricsSettingsSaveTitle => 'অফলাইনে সেভ করুন';

  @override
  String get lyricsSettingsSaveSubtitle => 'আপনার ডিভাইসে লিরিক্স রাখুন';

  @override
  String get lyricsSettingsDeleteTitle => 'সেভ করা লিরিক্স ডিলিট করুন';

  @override
  String get lyricsSettingsDeleteSubtitle => 'অফলাইন লিরিক্স ডেটা সরিয়ে ফেলুন';

  @override
  String get lyricsSyncTapToReset => 'রিসেট করতে ট্যাপ করুন';

  @override
  String get upNextTitle => 'পরবর্তী';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'কিউতে $countটি গান আছে',
      one: 'কিউতে ১টি গান আছে',
    );
    return '$_temp0';
  }

  @override
  String get tooltipCopyToClipboard => 'কপি করুন';

  @override
  String get snackbarCopiedToClipboard => 'কপি করা হয়েছে';

  @override
  String get tooltipSongInfo => 'গানের তথ্য';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'বর্তমানে প্লে হওয়া গান ডিলিট করা যাবে না';

  @override
  String get playerLoopOff => 'বন্ধ';

  @override
  String get playerLoopOne => 'একটি রিপিট';

  @override
  String get playerLoopAll => 'সব রিপিট';

  @override
  String get snackbarOpeningAlbumPage => 'আসল অ্যালবাম পেজ খোলা হচ্ছে।';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'অ্যাপের নতুন ভার্সন এসেছে!\n\nভার্সন: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return '\"$id\" প্লাগইন সফলভাবে ইনস্টল হয়েছে';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return '\"$id\" প্লাগইন ডিলিট করা হয়েছে';
  }

  @override
  String get pluginBootstrapTitle => 'অ্যাপ সেট আপ হচ্ছে';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'তৈরি হচ্ছে... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'এটি শুধু একবারই হয়।';

  @override
  String get backupSave => 'Save backup as JSON';

  @override
  String get backupShare => 'Share JSON backup';

  @override
  String get backupPortableDetails =>
      'Includes playlists, likes, saved collections, histories and portable preferences. Audio files, accounts and device folders are excluded.';

  @override
  String get backupHistories => 'Playback and search histories';

  @override
  String get backupPreferences => 'Portable preferences';

  @override
  String get backupNewCopy => 'Import as new playlists';

  @override
  String get backupMerge => 'Merge with existing data';

  @override
  String get backupReplace => 'Replace selected sections';

  @override
  String get backupMergeDetails =>
      'Existing tracks, metadata and preferences are preserved. Missing tracks are appended in file order. Likes are merged.';

  @override
  String get backupReplaceWarning =>
      'This replaces the selected sections, including existing playlists and likes when library is selected. Unselected sections and device files are preserved. A private recovery snapshot is created first.';

  @override
  String get backupAutoDetails =>
      'Keeps seven private recovery snapshots. Checked when the app opens, at most once per 24 hours. Private snapshots are removed on uninstall.';

  @override
  String get backupLocationDetails =>
      'Choose a destination with Save backup. Private recovery snapshots are kept inside the app.';

  @override
  String get backupResetDetails =>
      'Reset all database data on the next app start. Downloaded audio files and installed plugin files remain on this device. A private recovery snapshot is created first.';

  @override
  String get backupResetPending =>
      'Reset scheduled. Close and reopen Beats to complete it.';

  @override
  String backupPreviewCounts(int playlists, int tracks) {
    return '$playlists playlists and $tracks tracks';
  }

  @override
  String backupImportResult(
    int playlists,
    int tracks,
    int history,
    int settings,
  ) {
    return 'Import complete: $playlists playlists created, $tracks track entries added, $history history records added and $settings preferences applied.';
  }

  @override
  String get backupRefreshFailed =>
      'Data was imported. Close and reopen Beats to refresh all preferences.';

  @override
  String get backupRecoveryCopies => 'Recovery copies';

  @override
  String get backupNoRecoveryCopies => 'No recovery copies yet.';

  @override
  String get backupRecoveryAutomatic => 'Automatic backup';

  @override
  String get backupRecoveryBeforeImport => 'Before an import';

  @override
  String get backupRecoveryBeforeReset => 'Before a reset';

  @override
  String get backupCancelReset => 'Cancel reset';

  @override
  String get libraryRecoveryTitle => 'Recover missing library';

  @override
  String get libraryRecoverySubtitle =>
      'Look for playlists and download records retained from earlier versions.';

  @override
  String get libraryRecoveryChooseSource =>
      'Choose a retained database to scan. Your current library and original files will be preserved.';

  @override
  String get libraryRecoveryNoSources =>
      'No retained databases were found. Audio files alone cannot restore original playlist membership.';

  @override
  String libraryRecoverySummary(
    int tracks,
    int playlists,
    int downloads,
    int unavailable,
  ) {
    return 'Found $tracks tracks, $playlists playlists and $downloads download records. $unavailable files are currently unavailable; their records will be preserved.';
  }

  @override
  String libraryRecoveryWarnings(int broken) {
    return '$broken broken playlist references could not be reconstructed from this copy.';
  }

  @override
  String get libraryRecoveryMergeDetails =>
      'Recovery adds missing tracks, playlist entries and download records. Existing playlists, file mappings and settings are preserved. A recovery copy is created first. Repeat this with another retained copy if it contains more of your library.';

  @override
  String get libraryRecoveryMerge => 'Merge recovered library';

  @override
  String libraryRecoveryComplete(int entries, int downloads) {
    return 'Recovery complete: $entries playlist entries and $downloads download records added.';
  }

  @override
  String get backupStartupFailed => 'Beats could not start';

  @override
  String get backupStartupFailedDetails =>
      'Startup stopped without automatically repairing or replacing your database. Close the app and retry. Keep your app data when reporting this error.';

  @override
  String get lyricsTitle => 'Lyrics';

  @override
  String get lyricsEnterFullscreen => 'Fullscreen lyrics';

  @override
  String get lyricsExitFullscreen => 'Exit fullscreen';

  @override
  String get lyricsFollowPlayback => 'Follow playback';

  @override
  String get lyricsTimingEarlier => 'Earlier';

  @override
  String get lyricsTimingLater => 'Later';

  @override
  String get lyricsTimingSave => 'Save timing';

  @override
  String get lyricsSaved => 'Lyrics saved.';

  @override
  String get lyricsSaveFailed => 'Could not save lyrics. Try again.';

  @override
  String get lyricsDeleteFailed => 'Could not delete saved lyrics. Try again.';

  @override
  String get artistTopSongs => 'Top songs';

  @override
  String get artistLoadFailed => 'Failed to load artist';

  @override
  String get artistNoTopSongs => 'No top songs available';

  @override
  String get artistNoAlbums => 'No albums available';

  @override
  String get snackbarOpeningArtistPage => 'Opening original artist page.';

  @override
  String get snackbarOpeningPlaylistPage => 'Opening original playlist page.';

  @override
  String get playlistSaveOrderFailed =>
      'Unable to save playlist order. Please try again.';

  @override
  String get playlistReorderTracksHint => 'Hold the handle to reorder tracks';

  @override
  String get playlistTrackCountLabel => 'Number of tracks';

  @override
  String get playlistDescription => 'Description';

  @override
  String get playlistOriginalUrl => 'Original URL';

  @override
  String get searchSearching => 'Searching…';

  @override
  String get searchSuggestions => 'Suggestions';

  @override
  String get searchTopResults => 'Top results';

  @override
  String get changelogEmpty => 'No changelog information available.';

  @override
  String get changelogTitle => 'What\'s new';

  @override
  String get changelogLatest => 'Latest';

  @override
  String get changelogNext => 'Next version';

  @override
  String changelogVersion(String version) {
    return 'Version $version';
  }

  @override
  String get pluginBootstrapIncomplete => 'Setup incomplete';

  @override
  String get pluginBootstrapRetryBody =>
      'Some plugins could not be installed right now. Retry to finish setup.';

  @override
  String get pluginBootstrapInternetTitle => 'Internet required';

  @override
  String get pluginBootstrapInternetBody =>
      'Beats needs an internet connection once to detect your country and set up the plugin engine.';

  @override
  String get buttonExit => 'Exit';

  @override
  String get eqSource => 'Equalizer source';

  @override
  String get eqBuiltin => 'In-app equalizer';

  @override
  String get eqBuiltinSubtitle => '10-band equalizer';

  @override
  String get eqDevice => 'Device equalizer';

  @override
  String get eqDeviceSubtitle => 'System / Dolby Atmos';

  @override
  String get eqDeviceHint =>
      'The in-app equalizer is disabled. Configure your device equalizer in your device\'s sound settings.';

  @override
  String get eqPresets => 'Presets';

  @override
  String get eqCustomCurve => 'Custom curve';

  @override
  String get shortcutMuted => 'Muted';

  @override
  String get shortcutUnmuted => 'Unmuted';

  @override
  String get shortcutShuffleOn => 'Shuffle on';

  @override
  String get shortcutShuffleOff => 'Shuffle off';

  @override
  String get shortcutRepeatOff => 'Repeat off';

  @override
  String get shortcutLiked => 'Added to favorites';

  @override
  String get shortcutUnliked => 'Removed from favorites';

  @override
  String downloadFolderSelectFailed(String error) {
    return 'Could not select download folder: $error';
  }

  @override
  String get aboutVersionUnavailable => 'Version unavailable';

  @override
  String get backupNewCopyDetails =>
      'Creates separate playlists and merges favorites. Existing playlists are preserved. Selected histories and preferences are also imported.';

  @override
  String get changelogCurrent => 'Current';

  @override
  String get backupLibrary =>
      'Library (playlists, favorites and saved collections)';

  @override
  String get eqPresetFlat => 'Flat';

  @override
  String get eqPresetAcoustic => 'Acoustic';

  @override
  String get eqPresetBassBoost => 'Bass boost';

  @override
  String get eqPresetBassReducer => 'Bass reduction';

  @override
  String get eqPresetClassical => 'Classical';

  @override
  String get eqPresetDance => 'Dance';

  @override
  String get eqPresetDeep => 'Deep';

  @override
  String get eqPresetEDM => 'EDM';

  @override
  String get eqPresetElectronic => 'Electronic';

  @override
  String get eqPresetHipHop => 'Hip-hop';

  @override
  String get eqPresetJazz => 'Jazz';

  @override
  String get eqPresetLatin => 'Latin';

  @override
  String get eqPresetLive => 'Live';

  @override
  String get eqPresetLounge => 'Lounge';

  @override
  String get eqPresetMetal => 'Metal';

  @override
  String get eqPresetPiano => 'Piano';

  @override
  String get eqPresetPop => 'Pop';

  @override
  String get eqPresetRB => 'R&B';

  @override
  String get eqPresetRock => 'Rock';

  @override
  String get eqPresetSmallSpeakers => 'Small speakers';

  @override
  String get eqPresetSpokenWord => 'Spoken word';

  @override
  String get eqPresetTrebleBoost => 'Treble boost';

  @override
  String get eqPresetTrebleReducer => 'Treble reduction';

  @override
  String get eqPresetVocalBooster => 'Vocal boost';

  @override
  String get eqPresetCustom => 'Custom';

  @override
  String get playerQueue => 'কিউ';

  @override
  String get playerFullscreenLyrics => 'ফুলস্ক্রিন লিরিক্স';

  @override
  String get localMusicEmpty => 'কোন লোকাল মিউজিক পাওয়া যায়নি';

  @override
  String get localMusicSearchEmpty =>
      'আপনার অনুসন্ধানের সাথে মিলছে এমন কোন ট্র্যাক পাওয়া যায়নি।';

  @override
  String get localMusicMusicFolders => 'মিউজিক ফোল্ডারসমূহ';

  @override
  String get buttonShare => 'শেয়ার';

  @override
  String get dialogDeletePlugin => 'প্লাগইন ডিলিট করবেন?';

  @override
  String dialogDeletePluginMessage(String name) {
    return 'আপনি কি নিশ্চিত যে আপনি \"$name\" ডিলিট করতে চান? এটি এর ফাইলগুলোকে স্থায়ীভাবে সরিয়ে ফেলবে।';
  }

  @override
  String get playlistMoreOptions => 'আরও অপশন';

  @override
  String get settingsLocation => 'অবস্থান';

  @override
  String pluginRepositoryError(String message) {
    return 'ত্রুটি: $message';
  }

  @override
  String get snackbarPlaylistQueued => 'ডাউনলোড কিউতে প্লেলিস্ট যোগ করা হয়েছে';

  @override
  String get snackbarNoInternet => 'কোন ইন্টারনেট কানেকশন নেই।';

  @override
  String get snackbarImportFailed => 'ইমপোর্ট ব্যর্থ হয়েছে!';

  @override
  String get snackbarImportCompleted => 'ইমপোর্ট সম্পন্ন হয়েছে';

  @override
  String get snackbarBackupFailed => 'ব্যাকআপ ব্যর্থ হয়েছে!';

  @override
  String snackbarExportedTo(String path) {
    return 'এক্সপোর্ট করা হয়েছে: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'মিডিয়া আইডি কপি করা হয়েছে';

  @override
  String get snackbarNoLinkAvailable => 'কোন লিঙ্ক উপলব্ধ নেই';

  @override
  String snackbarPreparingDownload(String title) {
    return '$title-এর জন্য ডাউনলোড প্রস্তুত করা হচ্ছে...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title ইতিমধ্যে ডাউনলোড করা আছে।';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title ইতিমধ্যে কিউতে আছে।';
  }

  @override
  String snackbarDownloaded(String title) {
    return 'ডাউনলোড হয়েছে: $title';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'ত্রুটি: ডাউনলোড সার্ভিস উপলব্ধ নেই।';

  @override
  String get snackbarDeleteTrackFailDevice =>
      'ডিভাইস স্টোরেজ থেকে ট্র্যাক ডিলিট করতে ব্যর্থ হয়েছে।';

  @override
  String get searchHintOfflineMusic => 'আপনার গানগুলো খুঁজুন...';

  @override
  String get songInfoTitle => 'শিরোনাম';

  @override
  String get songInfoArtist => 'আর্টিস্ট';

  @override
  String get songInfoAlbum => 'অ্যালবাম';

  @override
  String get songInfoMediaId => 'মিডিয়া আইডি';

  @override
  String get tooltipShuffle => 'সাফল';

  @override
  String get tooltipDownloadPlaylist => 'প্লেলিস্ট ডাউনলোড করুন';

  @override
  String get tooltipInfo => 'তথ্য';

  @override
  String get storageBackupLocation => 'ব্যাকআপের স্থান';

  @override
  String get storageBackupLocationAndroid => 'ডাউনলোডস / অ্যাপ-ডেটা ডিরেক্টরি';

  @override
  String get storageBackupLocationDownloads => 'ডাউনলোডস ডিরেক্টরি';

  @override
  String get storageCreateBackup => 'ব্যাকআপ তৈরি করুন';

  @override
  String get storageCreateBackupSubtitle =>
      'আপনার সেটিংস এবং ডেটা ব্যাকআপ ফাইলে সেভ করুন।';

  @override
  String get storageBackupFailed => 'ব্যাকআপ ব্যর্থ হয়েছে!';

  @override
  String get storageAutoBackupSubtitle =>
      'নির্দিষ্ট সময় পর অটো ব্যাকআপ তৈরি করুন।';

  @override
  String get storageResetAppSubtitle =>
      'সব ডেটা মুছে অ্যাপটি ডিফল্ট অবস্থায় ফিরিয়ে আনুন।';

  @override
  String get storageResetConfirmMessage =>
      'আপনি কি নিশ্চিত যে আপনি অ্যাপটি রিসেট করতে চান? সব ডেটা মুছে যাবে এবং এটি আর ফেরানো যাবে না।';

  @override
  String get storageResetSuccess => 'অ্যাপটি ডিফল্ট অবস্থায় রিসেট করা হয়েছে।';

  @override
  String get storageLocationDialogTitle => 'ব্যাকআপের স্থান';

  @override
  String get storageLocationAndroid =>
      'ব্যাকআপ এখানে রাখা হয়:\n\n১. ডাউনলোডস ডিরেক্টরি\n২. Android/data/ls.Beats.musicplayer/data\n\nযেকোনো স্থান থেকে ফাইলটি কপি করুন।';

  @override
  String get storageLocationOther =>
      'ব্যাকআপ ডাউনলোডস ডিরেক্টরিতে রাখা হয়। সেখান থেকে ফাইলটি কপি করুন।';

  @override
  String get storageRestoreOptionsDesc =>
      'ব্যাকআপ ফাইল থেকে আপনি কোন ডেটা রিস্টোর করতে চান তা বেছে নিন।';

  @override
  String get storageRestoreSelectAll => 'সব সিলেক্ট করুন';

  @override
  String get storageRestoreMediaItems =>
      'মিডিয়া আইটেমস (গান, ট্র্যাক, লাইব্রেরি)';

  @override
  String get storageRestoreSearchHistory => 'সার্চ হিস্ট্রি';

  @override
  String get storageRestoreNoFile => 'কোন ফাইল সিলেক্ট করা হয়নি।';

  @override
  String get storageRestoreSaveFailed =>
      'সিলেক্ট করা ফাইলটি সেভ করতে ব্যর্থ হয়েছে।';

  @override
  String get storageRestoreConfirmPrefix =>
      'এটি ব্যাকআপ ফাইলের ডেটা দিয়ে অ্যাপের বর্তমান ডেটা ওভাররাইট এবং মার্জ করবে:';

  @override
  String get storageRestoreConfirmSuffix =>
      'আপনার বর্তমান ডেটা পরিবর্তিত হবে। আপনি কি এগিয়ে যেতে চান?';

  @override
  String get storageRestoreNo => 'না';

  @override
  String get storageRestoreMediaBullet => '• মিডিয়া আইটেমস';

  @override
  String get storageRestoreHistoryBullet => '• সার্চ হিস্ট্রি';

  @override
  String get storageUnexpectedError =>
      'রিস্টোর করার সময় অপ্রত্যাশিত একটি ত্রুটি ঘটেছে।';

  @override
  String get storageRestoreCompleted => 'রিস্টোর সম্পন্ন হয়েছে';

  @override
  String get storageRestoreSuccessMessage =>
      'সিলেক্ট করা ডেটা সফলভাবে রিস্টোর করা হয়েছে। ভালো ফলাফলের জন্য অ্যাপটি রিস্টার্ট করুন।';

  @override
  String get storageRestoreFailedMessage => 'রিস্টোর প্রক্রিয়ায় ত্রুটিসমূহ:';

  @override
  String get storageRestoreUnknownError =>
      'রিস্টোর করার সময় অজানা ত্রুটি ঘটেছে।';

  @override
  String get storageRestoreRestartHint => 'অ্যাপটি রিস্টার্ট করুন।';

  @override
  String get updateAppUpdatesHeader => 'অ্যাপ আপডেট';

  @override
  String get playlistTypeAlbum => 'অ্যালবাম';

  @override
  String get playlistTypePlaylist => 'প্লেলিস্ট';

  @override
  String get pluginManagerDowngradeTitle => 'প্লাগইন ডাউনগ্রেড করবেন?';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return 'আপনি বর্তমানের চেয়ে সমান বা পুরনো ভার্সন ইনস্টল করছেন। চালিয়ে যাবেন?';
  }

  @override
  String get pluginManagerDowngradeAction => 'ইনস্টল করুন';

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    return '$countটি প্লেলিস্টে পরিবর্তন করা হয়েছে।';
  }

  @override
  String get eqResetTooltip => 'রিসেট করুন';

  @override
  String get importBeatsFiles => 'অ্যাপের ফাইল ইমপোর্ট করুন';

  @override
  String get importResolving => 'বিশ্লেষণ করা হচ্ছে...';

  @override
  String get importReviewTitle => 'রিভিউ';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$total-এর মধ্যে $resolvedটি সম্পন্ন, $failedটি ব্যর্থ';
  }

  @override
  String get importAutoMatched => 'অটো-ম্যাচড';

  @override
  String get importUserSelected => 'বাছাইকৃত';

  @override
  String get importNoMatch => 'মিল পাওয়া যায়নি';

  @override
  String get snackbarImportingMedia => 'মিডিয়া ইমপোর্ট করা হচ্ছে..';

  @override
  String get snackbarPlaylistSaved => 'প্লেলিস্ট লাইব্রেরিতে সেভ হয়েছে!';

  @override
  String get snackbarMediaItemImported => 'মিডিয়া ইমপোর্ট করা হয়েছে';

  @override
  String get snackbarPlaylistImported => 'প্লেলিস্ট ইমপোর্ট করা হয়েছে';

  @override
  String get snackbarOpenImportForUrl => 'ইমপোর্ট স্ক্রিন খুলুন।';

  @override
  String snackbarPreparingShare(String title) {
    return 'শেয়ারের জন্য $title প্রস্তুত হচ্ছে';
  }

  @override
  String snackbarPreparingExport(String title) {
    return '$title এক্সপোর্ট করার জন্য প্রস্তুত হচ্ছে।';
  }

  @override
  String get upNextAutoPlay => 'অটো প্লে';

  @override
  String pluginSnackbarLoaded(String id) {
    return '\"$id\" প্লাগইন লোড হয়েছে';
  }

  @override
  String get pluginBootstrapErrorTitle => 'কানেকশন খুব স্লো';

  @override
  String get pluginBootstrapErrorBody =>
      'কিছু প্লাগইন ইনস্টল করা যায়নি। পরে আবার চেষ্টা করা হবে।';

  @override
  String get pluginBootstrapContinue => 'চালিয়ে যান';

  @override
  String get lastfmStatusSection => 'Scrobble status';

  @override
  String get lastfmStatusSynced => 'All caught up';

  @override
  String get lastfmStatusSending => 'Sending…';

  @override
  String lastfmStatusQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scrobbles waiting',
      one: '1 scrobble waiting',
    );
    return '$_temp0';
  }

  @override
  String get lastfmStatusRetrying => 'Offline · will retry shortly';

  @override
  String get lastfmStatusAuthPaused => 'Paused · sign in again';

  @override
  String get lastfmStatusOff => 'Scrobbling is turned off';

  @override
  String get lastfmStatQueued => 'Queued';

  @override
  String get lastfmStatLastSent => 'Last sent';

  @override
  String get lastfmNever => 'Never';

  @override
  String get lastfmJustNow => 'Just now';

  @override
  String lastfmMinutesAgo(int n) {
    return '${n}m ago';
  }

  @override
  String lastfmHoursAgo(int n) {
    return '${n}h ago';
  }

  @override
  String lastfmDaysAgo(int n) {
    return '${n}d ago';
  }

  @override
  String get lastfmLastTrack => 'Last scrobbled';

  @override
  String get lastfmErrorNetwork =>
      'Couldn\'t reach Last.fm. Your scrobbles are safe and will be sent automatically.';

  @override
  String get lastfmErrorAuth =>
      'Your Last.fm session is no longer valid. Remove the keys and authenticate again.';

  @override
  String lastfmErrorRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last.fm rejected $count scrobbles and they were discarded.',
      one: 'Last.fm rejected 1 scrobble and it was discarded.',
    );
    return '$_temp0';
  }

  @override
  String get lastfmSyncNow => 'Sync now';

  @override
  String get lastfmClearQueue => 'Clear queue';

  @override
  String get lastfmQueueCleared => 'Scrobble queue cleared';

  @override
  String get settingsDiscord => 'Discord';

  @override
  String get settingsDiscordSubtitle =>
      'Rich Presence: show what you\'re listening to.';

  @override
  String get discordTitle => 'Discord';

  @override
  String get discordEnable => 'Show on Discord';

  @override
  String get discordEnableSubtitle =>
      'Share the song you\'re playing on your Discord profile.';

  @override
  String get discordStatusIdle => 'Ready to share';

  @override
  String get discordStatusConnecting => 'Connecting to Discord…';

  @override
  String discordStatusConnected(String name) {
    return 'Connected as $name';
  }

  @override
  String get discordStatusConnectedNoUser => 'Connected to Discord';

  @override
  String get discordStatusNotFound => 'Discord isn\'t running';

  @override
  String get discordStatusError => 'Discord refused the connection';

  @override
  String get discordReconnect => 'Reconnect';

  @override
  String get discordSectionPreview => 'Preview';

  @override
  String get discordSectionCard => 'Appearance';

  @override
  String get discordSectionPrivacy => 'Privacy';

  @override
  String get discordPreviewEmpty => 'Play a song to preview your card.';

  @override
  String get discordKindListening => 'Listening to Beats';

  @override
  String get discordWhenPaused => 'When paused';

  @override
  String get discordPausedKeep => 'Keep showing';

  @override
  String get discordPausedHideLater => 'Hide after 5 minutes';

  @override
  String get discordPausedHide => 'Hide right away';

  @override
  String get discordShowArtwork => 'Album artwork';

  @override
  String get discordShowArtworkSubtitle =>
      'Cover art with a play or pause badge.';

  @override
  String get discordShowProgress => 'Time bar';

  @override
  String get discordShowProgressSubtitle =>
      'Live progress bar that follows seeks.';

  @override
  String get discordShowLinks => 'Clickable links';

  @override
  String get discordShowLinksSubtitle =>
      'Song, artist and album open their pages.';

  @override
  String get discordShareLocal => 'Share local files';

  @override
  String get discordShareLocalSubtitle =>
      'Also publish songs from your local library.';

  @override
  String get discordFooter =>
      'Needs the Discord desktop app running on this computer. Changes apply instantly; Discord accepts about one update every 4 seconds.';

  @override
  String discordStatusRetry(int seconds) {
    return 'Retrying in ${seconds}s';
  }

  @override
  String get discordStatusIdleDetail =>
      'Connects automatically when music plays.';

  @override
  String get discordPausedKeepSubtitle =>
      'Shows a paused badge without the time bar.';

  @override
  String get discordPausedHideLaterSubtitle =>
      'Short pauses keep your card, long ones clear it.';

  @override
  String get discordPausedHideSubtitle => 'Clears the moment you pause.';

  @override
  String get discordPreviewCaption => 'How friends see you on Discord.';

  @override
  String get discordStatusText => 'Status text';

  @override
  String get discordStatusTextSubtitle => 'What friends see next to your name.';

  @override
  String get discordStatusTextApp => 'App name';

  @override
  String get discordStatusTextArtist => 'Artist';

  @override
  String get discordStatusTextSong => 'Song title';

  @override
  String get libraryReorderHint => 'Drag to reorder';

  @override
  String get libraryReorderHintPinned =>
      'Drag to reorder. Pinned items stay on top.';

  @override
  String get tooltipRemoveFromQueue => 'Remove from queue';

  @override
  String get windowMinimize => 'Minimize';

  @override
  String get windowMaximize => 'Maximize';

  @override
  String get windowRestore => 'Restore Down';

  @override
  String get windowClose => 'Close';

  @override
  String get settingsWindow => 'Window & Tray';

  @override
  String get settingsWindowSubtitle =>
      'Close button, tray icon and background playback';

  @override
  String get windowCloseSection => 'When you close the window';

  @override
  String get windowCloseTray => 'Keep playing in the system tray';

  @override
  String get windowCloseTrayMac => 'Keep playing in the menu bar';

  @override
  String get windowCloseTraySubtitle =>
      'Hides the window and keeps the music going. Uses the fewest resources.';

  @override
  String get windowCloseMinimize => 'Minimize the window';

  @override
  String get windowCloseMinimizeSubtitle =>
      'Keeps playing with the window minimized to the taskbar.';

  @override
  String get windowCloseMinimizeSubtitleMac =>
      'Keeps playing with the window minimized to the Dock.';

  @override
  String get windowCloseQuit => 'Quit Beats';

  @override
  String get windowCloseQuitSubtitle =>
      'Stops playback and closes the app completely.';

  @override
  String get windowTrayUnavailable =>
      'No system tray is available, so closing minimizes the window instead.';

  @override
  String get windowTrayMenuSection => 'Tray menu';

  @override
  String get windowTrayFootnote =>
      'Click the tray icon to bring Beats back, or right-click it for playback controls.';

  @override
  String get windowTrayFootnoteMac =>
      'Click the menu bar icon for playback controls or to bring Beats back.';

  @override
  String get windowTrayFootnoteLinux =>
      'Open the tray icon\'s menu for playback controls. On GNOME, tray icons need the AppIndicator extension.';

  @override
  String get trayNothingPlaying => 'Nothing playing';

  @override
  String get trayPlay => 'Play';

  @override
  String get trayPause => 'Pause';

  @override
  String get trayNext => 'Next';

  @override
  String get trayPrevious => 'Previous';

  @override
  String get trayShowWindow => 'Show Beats';

  @override
  String get trayHideWindow => 'Hide Beats';

  @override
  String get trayQuit => 'Quit Beats';

  @override
  String get feedKindAnnouncement => 'News';

  @override
  String get feedKindApp => 'New app';

  @override
  String get feedKindForm => 'Sign up';

  @override
  String get feedKindNotice => 'Important';

  @override
  String get feedKindUpdate => 'Update';

  @override
  String feedUpdateTitle(String version) {
    return 'Beats $version is available';
  }

  @override
  String get feedUpdateBody => 'See what\'s new and download it.';

  @override
  String get feedUpdateAction => 'View update';

  @override
  String get feedOpen => 'Open';

  @override
  String get feedDismiss => 'Dismiss';

  @override
  String get feedNew => 'New';

  @override
  String get feedDraft => 'Draft';

  @override
  String get feedPreview => 'Preview drafts';

  @override
  String get feedEmpty => 'You\'re all caught up';

  @override
  String get feedEmptySubtitle =>
      'News, new apps and updates will show up here.';

  @override
  String get settingsNotifications => 'Updates & news';

  @override
  String get settingsNotificationsSubtitle =>
      'Update alerts, news and announcements';

  @override
  String get feedSection => 'News & announcements';

  @override
  String get feedOnHome => 'Show on Home';

  @override
  String get feedOnHomeSubtitle =>
      'A small card for news and new apps. Important notices always show.';
}
