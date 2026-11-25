// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get onboardingTitle => 'مرحباً بك في Beats';

  @override
  String get onboardingSubtitle => 'دعنا نحدد لغتك ومنطقتك.';

  @override
  String get continueButton => 'استمرار';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLibrary => 'المكتبة';

  @override
  String get navSearch => 'بحث';

  @override
  String get navLocal => 'محلي';

  @override
  String get navOffline => 'أوفلاين';

  @override
  String get playerEnjoyingFrom => 'تستمع من';

  @override
  String get playerPlayWithMix => 'تشغيل تلقائي للمزيج';

  @override
  String get playerPlayNext => 'تشغيل التالي';

  @override
  String get playerAddToQueue => 'إضافة إلى قائمة الانتظار';

  @override
  String get playerAddToFavorites => 'إضافة إلى المفضلات';

  @override
  String get playerNoLyricsFound => 'لم يتم العثور على كلمات';

  @override
  String get playerLyricsNoPlugin =>
      'لم يتم تكوين مزود كلمات. اذهب إلى الإعدادات ← المكونات الإضافية لتثبيت واحد.';

  @override
  String get localMusicTitle => 'محلي';

  @override
  String get localMusicGrantPermission => 'منح الإذن';

  @override
  String get localMusicStorageAccessRequired => 'مطلوب الوصول إلى التخزين';

  @override
  String get localMusicStorageAccessDesc =>
      'يرجى منح الإذن لمسح وتشغيل ملفات الصوت المخزنة على جهازك.';

  @override
  String get localMusicAddFolder => 'إضافة مجلد موسيقى';

  @override
  String get localMusicScanNow => 'مسح الآن';

  @override
  String localMusicScanFailed(String message) {
    return 'فشل المسح: $message';
  }

  @override
  String get localMusicScanning => 'جاري مسح الجهاز بحثاً عن ملفات صوتية...';

  @override
  String get localMusicShuffle => 'تبديل عشوائي';

  @override
  String get localMusicPlayAll => 'تشغيل الكل';

  @override
  String get localMusicSearchHint => 'بحث في الموسيقى المحلية...';

  @override
  String get localMusicRescanDevice => 'إعادة مسح الجهاز';

  @override
  String get buttonCancel => 'إلغاء';

  @override
  String get buttonDelete => 'حذف';

  @override
  String get buttonOk => 'موافق';

  @override
  String get buttonUpdate => 'تحديث';

  @override
  String get buttonDownload => 'تنزيل';

  @override
  String get buttonLater => 'لاحقاً';

  @override
  String get buttonInfo => 'معلومات';

  @override
  String get buttonMore => 'المزيد';

  @override
  String get dialogDeleteTrack => 'حذف المسار';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'هل أنت متأكد أنك تريد حذف \"$title\" من جهازك؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'سيتم أيضاً إزالة هذا المسار من:';

  @override
  String get dialogDontAskAgain => 'لا تسألني مرة أخرى';

  @override
  String get dialogUpdateAvailable => 'تحديث متاح';

  @override
  String get dialogUpdateNow => 'تحدث الآن';

  @override
  String get dialogDownloadPlaylist => 'تنزيل قائمة التشغيل';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'هل تريد تنزيل $count أغنية من \"$title\"؟ سيتم إضافتها إلى قائمة انتظار التنزيل.';
  }

  @override
  String get dialogDownloadAll => 'تنزيل الكل';

  @override
  String get playlistEdit => 'تعديل قائمة التشغيل';

  @override
  String get playlistShareFile => 'مشاركة الملف';

  @override
  String get playlistExportFile => 'تصدير الملف';

  @override
  String get playlistPlay => 'تشغيل';

  @override
  String get playlistAddToQueue => 'إضافة قائمة التشغيل للانتظار';

  @override
  String get playlistShare => 'مشاركة قائمة التشغيل';

  @override
  String get playlistDelete => 'حذف قائمة التشغيل';

  @override
  String get playlistEmptyState => 'لا توجد أغاني بعد!';

  @override
  String get playlistAvailableOffline => 'متاح أوفلاين';

  @override
  String get playlistShuffle => 'تبديل عشوائي';

  @override
  String get playlistNoMatchSearch => 'لا توجد قوائم تشغيل تطابق بحثك';

  @override
  String get playlistCreateNew => 'إنشاء قائمة تشغيل جديدة';

  @override
  String get playlistCreateFirstOne =>
      'لا توجد قوائم تشغيل بعد. أنشئ واحدة للبدء!';

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
      other: '$count أغنية',
      few: '$count أغاني',
      two: 'أغنيتان',
      one: 'أغنية واحدة',
      zero: 'لا توجد أغاني',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return 'تمت إزالة $title من $playlist';
  }

  @override
  String get playlistFailedToLoad => 'فشل تحميل قائمة التشغيل';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsPlugins => 'المكونات الإضافية';

  @override
  String get settingsPluginsSubtitle =>
      'تثبيت وتحميل وإدارة المكونات الإضافية.';

  @override
  String get settingsUpdates => 'التحديثات';

  @override
  String get settingsUpdatesSubtitle => 'التحقق من وجود تحديثات جديدة';

  @override
  String get settingsDownloads => 'التنزيلات';

  @override
  String get settingsDownloadsSubtitle =>
      'مسار التنزيل، جودة التنزيل والمزيد...';

  @override
  String get settingsLocalTracks => 'المسارات المحلية';

  @override
  String get settingsLocalTracksSubtitle =>
      'مسح وإدارة المجلدات وإعدادات المسح التلقائي.';

  @override
  String get settingsPlayer => 'إعدادات المشغل';

  @override
  String get settingsPlayerSubtitle => 'جودة البث، التشغيل التلقائي، إلخ.';

  @override
  String get settingsPluginDefaults => 'الافتراضيات للمكونات';

  @override
  String get settingsPluginDefaultsSubtitle => 'مصدر الاكتشاف، أولوية المحلل.';

  @override
  String get settingsUIElements => 'عناصر الواجهة والخدمات';

  @override
  String get settingsUIElementsSubtitle =>
      'الانزلاق التلقائي، تعديلات الواجهة إلخ.';

  @override
  String get settingsLastFM => 'إعدادات Last.FM';

  @override
  String get settingsLastFMSubtitle =>
      'مفتاح API والسر وإعدادات الـ Scrobbling.';

  @override
  String get settingsStorage => 'التخزين';

  @override
  String get settingsStorageSubtitle =>
      'النسخ الاحتياطي، الذاكرة المؤقتة، السجل، الاستعادة والمزيد...';

  @override
  String get settingsLanguageCountry => 'اللغة والبلد';

  @override
  String get settingsLanguageCountrySubtitle => 'اختر لغتك وبلدك.';

  @override
  String get settingsAbout => 'حول';

  @override
  String get settingsAboutSubtitle => 'حول التطبيق، الإصدار، المطور، إلخ.';

  @override
  String get settingsScanning => 'جاري المسح';

  @override
  String get settingsMusicFolders => 'مجلدات الموسيقى';

  @override
  String get settingsQuality => 'الجودة';

  @override
  String get settingsHistory => 'السجل';

  @override
  String get settingsBackupRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get settingsAutomatic => 'تلقائي';

  @override
  String get settingsDangerZone => 'منطقة الخطر';

  @override
  String get settingsScrobbling => 'Scrobbling';

  @override
  String get settingsAuthentication => 'المصادقة';

  @override
  String get settingsHomeScreen => 'الشاشة الرئيسية';

  @override
  String get settingsChartVisibility => 'رؤية القوائم';

  @override
  String get dialogAddingToDownloadQueue =>
      'جاري الإضافة إلى قائمة انتظار التنزيل';

  @override
  String get emptyNoInternet => 'لا يوجد اتصال بالإنترنت!';

  @override
  String get emptyNoContentPlugin =>
      'لم يتم تحميل مكون محلل محتوى. قم بتحميل واحد في مدير المكونات.';

  @override
  String get emptyRefreshingSource =>
      'جاري تحديث مصدر الاكتشاف... المصدر السابق لم يعد متاحاً.';

  @override
  String get emptyNoTracks => 'لا توجد مسارات متاحة';

  @override
  String get emptyNoResults => 'لم يتم العثور على نتائج';

  @override
  String snackbarDeletedTrack(String title) {
    return 'تم حذف \"$title\"';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'فشل حذف \"$title\"';
  }

  @override
  String get snackbarAddedToNextQueue => 'تمت الإضافة كالتالي في القائمة';

  @override
  String get snackbarAddedToQueue => 'تمت الإضافة إلى القائمة';

  @override
  String snackbarAddedToLiked(String title) {
    return 'تمت إضافة $title إلى المعجبات!!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'يتم تشغيل $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return 'تمت إضافة $name إلى القائمة';
  }

  @override
  String get snackbarPlaylistUpdated => 'تم تحديث قائمة التشغيل!';

  @override
  String get snackbarLinkCopied => 'تم نسخ الرابط';

  @override
  String get snackbarCouldNotOpenLink => 'تعذر فتح الرابط';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'تمت إضافة $count أغنية لقائمة التنزيل';
  }

  @override
  String get searchHintExplore => 'ماذا تريد أن تسمع؟';

  @override
  String get searchHintLibrary => 'بحث في المكتبة...';

  @override
  String get searchHintPlaylists => 'بحث في قوائم التشغيل...';

  @override
  String get searchStartTyping => 'ابدأ الكتابة للبحث...';

  @override
  String get searchNoSuggestions => 'لم يتم العثور على اقتراحات!';

  @override
  String get searchNoResults =>
      'لم يتم العثور على نتائج!\nجرب كلمة أخرى أو مصدراً آخر.';

  @override
  String get searchFailed => 'فشل البحث!';

  @override
  String get searchDiscover => 'اكتشف موسيقى مذهلة...';

  @override
  String get searchSources => 'المصادر';

  @override
  String get searchNoPlugins => 'لا توجد مكونات مثبتة';

  @override
  String get searchTracks => 'المسارات';

  @override
  String get searchAlbums => 'الألبومات';

  @override
  String get searchArtists => 'الفنانون';

  @override
  String get searchPlaylists => 'قوائم التشغيل';

  @override
  String get exploreDiscover => 'اكتشاف';

  @override
  String get exploreRecently => 'مؤخراً';

  @override
  String get exploreLastFmPicks => 'اختيارات Last.Fm';

  @override
  String get exploreFailedToLoad => 'فشل تحميل أقسام الرئيسية.';

  @override
  String get libraryTitle => 'المكتبة';

  @override
  String get libraryEmptyState =>
      'مكتبتك تشعر بالوحدة. أضف بعض الأغاني لتبهجها!';

  @override
  String libraryIn(String playlistName) {
    return 'في $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'إضافة إلى قائمة التشغيل';

  @override
  String get menuSmartReplace => 'استبدال ذكي';

  @override
  String get menuShare => 'مشاركة';

  @override
  String get menuAvailableOffline => 'متاح أوفلاين';

  @override
  String get menuDownload => 'تنزيل';

  @override
  String get menuOpenOriginalLink => 'فتح الرابط الأصلي';

  @override
  String get menuDeleteTrack => 'حذف';

  @override
  String get tooltipRemoveFromLibrary => 'إزالة من المكتبة';

  @override
  String get tooltipSaveToLibrary => 'حفظ في المكتبة';

  @override
  String get tooltipOpenOriginalLink => 'فتح الرابط الأصلي';

  @override
  String get tooltipAvailableOffline => 'متاح أوفلاين';

  @override
  String get tooltipMoreOptions => 'المزيد من الخيارات';

  @override
  String get appuiTitle => 'الواجهة والخدمات';

  @override
  String get appuiAutoSlideCharts => 'انزلاق تلقائي للقوائم';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'تمرير القوائم تلقائياً في الشاشة الرئيسية.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'إظهار اقتراحات من Last.FM. يتطلب تسجيل الدخول وإعادة التشغيل.';

  @override
  String get appuiNoChartsAvailable =>
      'لا توجد قوائم متاحة. قم بتحميل مكون مزود قوائم.';

  @override
  String get appuiLoginToLastFm => 'يرجى تسجيل الدخول إلى Last.FM أولاً.';

  @override
  String get appuiShowInCarousel => 'إظهار في شريط الرئيسية.';

  @override
  String get countrySettingTitle => 'البلد واللغة';

  @override
  String get countrySettingAutoDetect => 'كشف تلقائي للبلد';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'كشف بلدك تلقائياً عند فتح التطبيق.';

  @override
  String get countrySettingCountryLabel => 'البلد';

  @override
  String get countrySettingLanguageLabel => 'اللغة';

  @override
  String get countrySettingSystemDefault => 'افتراضي النظام';

  @override
  String get downloadSettingTitle => 'التنزيلات';

  @override
  String get downloadSettingQuality => 'جودة التنزيل';

  @override
  String get downloadSettingQualitySubtitle =>
      'الجودة الصوتية المفضلة للمسارات المنزلة.';

  @override
  String get downloadSettingFolder => 'مجلد التنزيل';

  @override
  String get downloadSettingResetFolder => 'إعادة تعيين مجلد التنزيل';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'استعادة مسار التنزيل الافتراضي.';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'تسجيل المسارات (Scrobble)';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'إرسال المسارات المشغلة إلى ملفك الشخصي في Last.FM.';

  @override
  String get lastfmAuthFirst => 'قم بمصادقة Last.FM API أولاً.';

  @override
  String get lastfmAuthenticatedAs => 'موثق كـ';

  @override
  String get lastfmAuthFailed => 'فشلت المصادقة:';

  @override
  String get lastfmNotAuthenticated => 'غير موثق';

  @override
  String get lastfmSteps =>
      'خطوات المصادقة:\n1. أنشئ / افتح حساباً في Last.FM\n2. أنشئ مفتاح API في last.fm/api/account/create\n3. أدخل مفتاح API والسر أدناه\n4. اضغط \"بدء المصادقة\" ووافق في المتصفح\n5. اضغط \"حفظ مفتاح الجلسة\" للإنهاء';

  @override
  String get lastfmApiKey => 'مفتاح API';

  @override
  String get lastfmApiSecret => 'سر API';

  @override
  String get lastfmStartAuth => '1. بدء المصادقة';

  @override
  String get lastfmGetSession => '2. حفظ مفتاح الجلسة';

  @override
  String get lastfmRemoveKeys => 'إزالة المفاتيح';

  @override
  String get lastfmStartAuthFirst => 'ابدأ المصادقة أولاً، ثم وافق في المتصفح.';

  @override
  String get localSettingTitle => 'المسارات المحلية';

  @override
  String get localSettingAutoScan => 'مسح تلقائي عند البدء';

  @override
  String get localSettingAutoScanSubtitle =>
      'مسح المسارات المحلية الجديدة تلقائياً عند تشغيل التطبيق.';

  @override
  String get localSettingLastScan => 'آخر مسح';

  @override
  String get localSettingNeverScanned => 'أبداً';

  @override
  String get localSettingScanInProgress => 'جاري المسح...';

  @override
  String get localSettingScanNowSubtitle => 'تشغيل مسح كامل للمكتبة يدوياً.';

  @override
  String get localSettingNoFolders => 'لم يتم إضافة مجلدات. أضف مجلد للبدء.';

  @override
  String get localSettingAddFolder => 'إضافة مجلد';

  @override
  String get playerSettingTitle => 'إعدادات المشغل';

  @override
  String get playerSettingStreamingHeader => 'البث';

  @override
  String get playerSettingStreamQuality => 'جودة البث';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'معدل البت العالمي للتشغيل عبر الإنترنت.';

  @override
  String get playerSettingQualityLow => 'منخفض';

  @override
  String get playerSettingQualityMedium => 'متوسط';

  @override
  String get playerSettingQualityHigh => 'عالي';

  @override
  String get playerSettingPlaybackHeader => 'التشغيل';

  @override
  String get playerSettingAutoPlay => 'تشغيل تلقائي';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'إضافة أغانٍ مشابهة عند انتهاء القائمة.';

  @override
  String get playerSettingAutoFallback => 'تشغيل احتياطي تلقائي';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'إذا كان المكون مفقوداً أو لا يعيد تدفقات، جرب محللاً متوافقاً للتشغيل فقط.';

  @override
  String get playerSettingCrossfade => 'تلاشي متقاطع';

  @override
  String get playerSettingCrossfadeOff => 'إيقاف';

  @override
  String get playerSettingCrossfadeInstant => 'تبديل المسارات فورياً';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'تلاشي لمدة $seconds ثانية';
  }

  @override
  String get playerSettingEqualizer => 'المعادل (Equalizer)';

  @override
  String get playerSettingEqualizerActive => 'نشط';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'مفعل — نمط $preset';
  }

  @override
  String get playerSettingEqualizerSubtitle => 'معادل 10 نطاقات عبر FFmpeg.';

  @override
  String get pluginDefaultsTitle => 'الافتراضيات للمكونات';

  @override
  String get pluginDefaultsDiscoverHeader => 'مصدر الاكتشاف';

  @override
  String get pluginDefaultsNoResolver =>
      'لم يتم تحميل محلل محتوى. ثبت مكوناً لاختيار مصدر اكتشاف.';

  @override
  String get pluginDefaultsAutomaticSubtitle => 'استخدام أول محلل محتوى متاح.';

  @override
  String get pluginDefaultsPriorityHeader => 'أولوية المحلل';

  @override
  String get pluginDefaultsNoPriority =>
      'لم يتم تحميل محللات. سيظهر ترتيب الأولويات هنا بعد التحميل.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'اسحب للترتيب. يتم تجربة المحللات ذات الأولوية الأعلى أولاً.';

  @override
  String get pluginDefaultsLyricsHeader => 'أولوية الكلمات';

  @override
  String get pluginDefaultsLyricsNone => 'لم يتم تحميل مزودي كلمات.';

  @override
  String get pluginDefaultsLyricsDesc =>
      'اسحب لترتيب مزودي الكلمات. يتم تجربة المزود الأول أولاً.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'اقتراحات البحث';

  @override
  String get pluginDefaultsSuggestionsNone => 'لم يتم تحميل مزودي اقتراحات.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'لا يوجد';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'استخدام سجل البحث فقط.';

  @override
  String get storageSettingTitle => 'التخزين';

  @override
  String get storageClearHistoryEvery => 'مسح السجل كل';

  @override
  String get storageClearHistorySubtitle =>
      'مسح سجل الاستماع بعد المدة المختارة.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      few: '$count أيام',
      two: 'يومين',
      one: 'يوم واحد',
      zero: 'أبداً',
    );
    return '$_temp0';
  }

  @override
  String storageBackupCreatedAt(String path) {
    return 'تم إنشاء النسخة في $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'فشل مشاركة النسخة: $error';
  }

  @override
  String get storageRestoreBackup => 'استعادة نسخة احتياطية';

  @override
  String get storageRestoreBackupSubtitle =>
      'استعادة إعداداتك وبياناتك من ملف.';

  @override
  String get storageAutoBackup => 'نسخ احتياطي تلقائي';

  @override
  String get storageAutoLyrics => 'حفظ الكلمات تلقائياً';

  @override
  String get storageAutoLyricsSubtitle =>
      'حفظ الكلمات تلقائياً عند تشغيل الأغنية.';

  @override
  String get storageResetApp => 'إعادة تعيين Beats';

  @override
  String get storageResetConfirmTitle => 'تأكيد إعادة التعيين';

  @override
  String get storageResetButton => 'إعادة تعيين';

  @override
  String get storageRestoreOptionsTitle => 'خيارات الاستعادة';

  @override
  String get storageRestoreContinue => 'استمرار';

  @override
  String get storageRestoreConfirmTitle => 'تأكيد الاستعادة';

  @override
  String get storageRestoreYes => 'نعم، استعادة';

  @override
  String get storageRestoring => 'جاري الاستعادة... يرجى الانتظار.';

  @override
  String get storageRestoreFailedTitle => 'فشلت الاستعادة';

  @override
  String get updateSettingTitle => 'التحديثات';

  @override
  String get updateCheckForUpdates => 'التحقق من التحديثات';

  @override
  String get updateCheckSubtitle => 'ابحث عن إصدار أحدث من Beats.';

  @override
  String get updateAutoNotify => 'إشعار تحديث تلقائي';

  @override
  String get updateAutoNotifySubtitle =>
      'احصل على إشعار عند وجود تحديث عند بدء التطبيق.';

  @override
  String get updateCheckTitle => 'التحقق من التحديثات';

  @override
  String get updateUpToDate => 'Beats محدث لأحدث إصدار!!!';

  @override
  String get updateViewPreRelease => 'عرض أحدث نسخة تجريبية';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'الإصدار الحالي: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable => 'إصدار جديد من Beats متاح الآن!!';

  @override
  String updateVersion(String ver, String build) {
    return 'الإصدار: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'تنزيل الآن';

  @override
  String get updateChecking => 'جاري التحقق من وجود إصدارات جديدة!';

  @override
  String get timerTitle => 'مؤقت النوم';

  @override
  String get timerInterludeMessage => 'تحضير لراحة هادئة خلال…';

  @override
  String get timerHours => 'ساعات';

  @override
  String get timerMinutes => 'دقائق';

  @override
  String get timerSeconds => 'ثواني';

  @override
  String get timerStop => 'إيقاف المؤقت';

  @override
  String get timerFinishedMessage => 'استراحت الألحان. أحلام سعيدة 🥰.';

  @override
  String get timerGotIt => 'حسناً!';

  @override
  String get timerSetTimeError => 'يرجى تحديد وقت';

  @override
  String get timerStart => 'بدء المؤقت';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات بعد!';

  @override
  String get recentsTitle => 'السجل';

  @override
  String playlistByCreator(String creator) {
    return 'بواسطة $creator';
  }

  @override
  String get playlistYou => 'أنت';

  @override
  String get pluginManagerTitle => 'المكونات الإضافية';

  @override
  String get pluginManagerEmpty =>
      'لا توجد مكونات مثبتة.\nاضغط + لإضافة ملف .bex.';

  @override
  String get pluginManagerFilterAll => 'الكل';

  @override
  String get pluginManagerFilterContent => 'محللات المحتوى';

  @override
  String get pluginManagerFilterCharts => 'مزودو القوائم';

  @override
  String get pluginManagerFilterLyrics => 'مزودو الكلمات';

  @override
  String get pluginManagerFilterSuggestions => 'مزودو الاقتراحات';

  @override
  String get pluginManagerFilterImporters => 'مستوردو المحتوى';

  @override
  String get pluginManagerTooltipRefresh => 'تحديث';

  @override
  String get pluginManagerTooltipInstall => 'تثبيت مكون';

  @override
  String get pluginManagerNoMatch => 'لا توجد مكونات تطابق الفلتر';

  @override
  String pluginManagerPickFailed(String error) {
    return 'فشل اختيار الملف: $error';
  }

  @override
  String get pluginManagerInstalling => 'جاري التثبيت...';

  @override
  String get pluginManagerTypeContentResolver => 'محلل محتوى';

  @override
  String get pluginManagerTypeChartProvider => 'مزود قوائم';

  @override
  String get pluginManagerTypeLyricsProvider => 'مزود كلمات';

  @override
  String get pluginManagerTypeSuggestionProvider => 'اقتراحات البحث';

  @override
  String get pluginManagerTypeContentImporter => 'مستورد محتوى';

  @override
  String get pluginManagerDeleteTitle => 'حذف المكون؟';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'هل أنت متأكد؟ سيتم حذف ملفات \"$name\" نهائياً.';
  }

  @override
  String get pluginManagerDeleteAction => 'حذف';

  @override
  String get pluginManagerCancel => 'إلغاء';

  @override
  String get pluginManagerEnablePlugin => 'تمكين المكون';

  @override
  String get pluginManagerUnloadPlugin => 'إلغاء تحميل المكون';

  @override
  String get pluginManagerDeleting => 'جاري الحذف...';

  @override
  String get pluginManagerApiKeysTitle => 'مفاتيح API';

  @override
  String get pluginManagerApiKeysSaved => 'تم حفظ المفاتيح';

  @override
  String get pluginManagerSave => 'حفظ';

  @override
  String get pluginManagerDetailVersion => 'الإصدار';

  @override
  String get pluginManagerDetailType => 'النوع';

  @override
  String get pluginManagerDetailPublisher => 'الناشر';

  @override
  String get pluginManagerDetailLastUpdated => 'آخر تحديث';

  @override
  String get pluginManagerDetailCreated => 'تم الإنشاء';

  @override
  String get pluginManagerDetailHomepage => 'الصفحة الرئيسية';

  @override
  String get pluginManagerDeleteStorageTitle => 'حذف بيانات المكون؟';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'هل تود أيضاً حذف مفاتيح API وإعدادات \"$name\"؟';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'البقاء على البيانات';

  @override
  String get pluginManagerDeleteStorageRemove => 'حذف البيانات';

  @override
  String get segmentsSheetTitle => 'الأجزاء';

  @override
  String get segmentsSheetEmpty => 'لا توجد أجزاء متاحة';

  @override
  String get segmentsSheetUntitled => 'جزء بدون عنوان';

  @override
  String get smartReplaceTitle => 'استبدال ذكي';

  @override
  String smartReplaceSubtitle(String title) {
    return 'اختر بديلاً قابلاً للتشغيل لـ \"$title\" وتحديث مراجع قوائم التشغيل.';
  }

  @override
  String get smartReplaceClose => 'إغلاق';

  @override
  String get smartReplaceNoMatch => 'لم يتم العثور على بديل';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'لم تعيد أي من المكونات نتيجة مطابقة قوية.';

  @override
  String get smartReplaceBestMatch => 'أفضل مطابقة';

  @override
  String get smartReplaceSearchFailed => 'فشل البحث';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'فشل الاستبدال الذكي: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'تم تطبيق البديل$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' وتحديث قائمة الانتظار';

  @override
  String get playerUnknownQueue => 'غير معروف';

  @override
  String playerLiked(String title) {
    return 'أعجبك $title!!';
  }

  @override
  String playerUnliked(String title) {
    return 'أزلت الإعجاب بـ $title!!';
  }

  @override
  String get offlineNoDownloads => 'لا توجد تنزيلات';

  @override
  String get offlineTitle => 'أوفلاين';

  @override
  String get offlineSearchHint => 'بحث في أغانيك...';

  @override
  String get offlineRefreshTooltip => 'تحديث التنزيلات';

  @override
  String get offlineCloseSearch => 'إغلاق البحث';

  @override
  String get offlineSearchTooltip => 'بحث';

  @override
  String get offlineOpenFailed => 'تعذر فتح هذا المسار. جرب تحديث التنزيلات.';

  @override
  String get offlinePlayFailed =>
      'تعذر تشغيل هذه الأغنية أوفلاين. يرجى المحاولة ثانية.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مسار',
      few: '$count مسارات',
      two: 'مساران',
      one: 'مسار واحد',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'فشل تحميل الألبوم';

  @override
  String get aboutCraftingSubtitle => 'صياغة سمفونيات برمجية.';

  @override
  String get aboutFollowGitHub => 'تابعه على GitHub';

  @override
  String get aboutSendInquiry => 'إرسال استفسار تجاري';

  @override
  String get aboutCreativeHighlights => 'التحديثات وأبرز الإبداعات';

  @override
  String get aboutTipQuote => 'تستمتع بـ Beats؟ تلميح صغير يبقيه مزدهراً. ';

  @override
  String get aboutTipButton => 'سأساعد';

  @override
  String get aboutTipDesc => 'أريد لـ Beats أن يستمر في التحسن.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'تفاصيل الأغنية';

  @override
  String get songInfoSectionTechnical => 'معلومات تقنية';

  @override
  String get songInfoSectionActions => 'إجراءات';

  @override
  String get songInfoLabelTitle => 'العنوان';

  @override
  String get songInfoLabelArtist => 'الفنان';

  @override
  String get songInfoLabelAlbum => 'الألبوم';

  @override
  String get songInfoLabelDuration => 'المدة';

  @override
  String get songInfoLabelSource => 'المصدر';

  @override
  String get songInfoLabelMediaId => 'معرف الوسائط';

  @override
  String get songInfoLabelPluginId => 'معرف المكون';

  @override
  String get songInfoCopyId => 'نسخ المعرف';

  @override
  String get songInfoCopyLink => 'نسخ الرابط';

  @override
  String get songInfoOpenBrowser => 'فتح في المتصفح';

  @override
  String get songInfoIdCopied => 'تم نسخ المعرف';

  @override
  String get songInfoLinkCopied => 'تم نسخ الرابط';

  @override
  String get songInfoNoLink => 'لا يوجد رابط متاح';

  @override
  String get songInfoOpenFailed => 'تعذر فتح الرابط';

  @override
  String get songInfoUpdateMetadata => 'تحديث البيانات الوصفية';

  @override
  String get songInfoMetadataUpdated => 'تم تحديث البيانات';

  @override
  String get songInfoMetadataUpdateFailed => 'فشل تحديث البيانات';

  @override
  String get songInfoMetadataUnavailable => 'التحديث غير متاح لهذا المصدر';

  @override
  String get songInfoSearchTitle => 'بحث عن الأغنية في Beats';

  @override
  String get songInfoSearchArtist => 'بحث عن الفنان في Beats';

  @override
  String get songInfoSearchAlbum => 'بحث عن الألبوم في Beats';

  @override
  String get eqTitle => 'المعادل';

  @override
  String get chartNoItems => 'لا توجد عناصر في هذه القائمة';

  @override
  String get chartLoadFailed => 'فشل تحميل القائمة';

  @override
  String get chartPlay => 'تشغيل';

  @override
  String get chartResolving => 'جاري التحليل';

  @override
  String get chartReady => 'جاهز';

  @override
  String get chartAddToPlaylist => 'إضافة إلى قائمة التشغيل';

  @override
  String get chartNoResolver => 'لم يتم تحميل محلل محتوى. ثبت مكوناً للتشغيل.';

  @override
  String get chartResolveFailed => 'تعذر التحليل. سيتم البحث بدلاً من ذلك...';

  @override
  String get chartNoResolverAdd => 'لم يتم تحميل محلل محتوى.';

  @override
  String get chartNoMatch => 'لم يتم العثور على مطابقة. جرب البحث يدوياً.';

  @override
  String get chartStatPeak => 'الذروة';

  @override
  String get chartStatWeeks => 'أسابيع';

  @override
  String get chartStatChange => 'التغيير';

  @override
  String menuSharePreparing(String title) {
    return 'جاري تحضير $title للمشاركة.';
  }

  @override
  String get menuOpenLinkFailed => 'تعذر فتح الرابط';

  @override
  String get localMusicFolders => 'مجلدات الموسيقى';

  @override
  String get localMusicRemoveFolder => 'إزالة المجلد';

  @override
  String get localMusicCloseSearch => 'إغلاق البحث';

  @override
  String get localMusicOpenSearch => 'بحث';

  @override
  String get localMusicNoMusicFound => 'لم يتم العثور على موسيقى محلية';

  @override
  String get localMusicNoSearchResults =>
      'لم يتم العثور على مسارات تطابق بحثك.';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مسار',
      few: '$count مسارات',
      two: 'مساران',
      one: 'مسار واحد',
      zero: 'لا توجد مسارات',
    );
    return '$_temp0';
  }

  @override
  String get importSongsTitle => 'استيراد الأغاني';

  @override
  String get importNoPluginsLoaded =>
      'لم يتم تحميل مستورد محتوى.\nثبت واحداً لاستيراد القوائم من الخدمات الخارجية.';

  @override
  String get importBloomeeFiles => 'Import Beats Files';

  @override
  String get importM3UFiles => 'استيراد قائمة M3U';

  @override
  String get importM3UNameDialogTitle => 'اسم قائمة التشغيل';

  @override
  String get importM3UNameHint => 'أدخل اسماً لهذه القائمة';

  @override
  String get importM3UNoTracks => 'لم يتم العثور على مسارات صالحة في ملف M3U.';

  @override
  String get importNoteTitle => 'ملاحظة';

  @override
  String get importNoteMessage =>
      'يمكنك فقط استيراد الملفات التي تم إنشاؤها بواسطة Beats.\nإذا كان الملف من مصدر آخر، فلن يعمل. استمرار على أي حال؟';

  @override
  String get importTitle => 'استيراد';

  @override
  String get importCheckingUrl => 'جاري التحقق من الرابط...';

  @override
  String get importFetchingTracks => 'جاري جلب المسارات...';

  @override
  String get importSavingToLibrary => 'جاري الحفظ في المكتبة...';

  @override
  String get importPasteUrlHint => 'الصق رابط قائمة تشغيل أو ألبوم للاستيراد';

  @override
  String get importAction => 'استيراد';

  @override
  String importTrackCount(int count) {
    return '$count مسارات';
  }

  @override
  String importResolvingProgress(int done, int total) {
    return 'تحليل المسارات: $done / $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'حفظ $count مسارات';
  }

  @override
  String importTracksSaved(int count) {
    return 'تم حفظ $count مسارات!';
  }

  @override
  String get importDone => 'تم';

  @override
  String get importMore => 'استيراد المزيد';

  @override
  String get importUnknownError => 'خطأ غير معروف';

  @override
  String get importTryAgain => 'إعادة المحاولة';

  @override
  String get importSkipTrack => 'تخطي هذا المسار';

  @override
  String get importMatchOptions => 'خيارات المطابقة';

  @override
  String get importSkipped => 'تم التخطي';

  @override
  String get importReorderTip => 'اضغط مطولاً لبدء إعادة الترتيب';

  @override
  String get importErrorCannotHandleUrl =>
      'هذا المكون لا يمكنه التعامل مع الرابط المزود.';

  @override
  String get importErrorUnexpectedResponse => 'استجابة غير متوقعة من المكون.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'فشل التحقق من الرابط: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'فشل جلب معلومات المجموعة: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'فشل جلب المسارات: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'فشل حفظ قائمة التشغيل: $error';
  }

  @override
  String get playlistPinToTop => 'تثبيت في الأعلى';

  @override
  String get playlistUnpin => 'إلغاء التثبيت';

  @override
  String get snackbarInvalidFileFormat => 'تنسيق ملف غير صالح';

  @override
  String get snackbarProcessingFile => 'جاري معالجة الملف...';

  @override
  String get pluginManagerTabInstalled => 'المثبتة';

  @override
  String get pluginManagerTabStore => 'متجر المكونات';

  @override
  String get pluginManagerSelectPackage => 'اختر ملف مكون (.bex)';

  @override
  String get pluginManagerOutdatedManifest =>
      'هذا المكون يستخدم إصداراً قديماً. قد لا تعمل بعض الميزات.';

  @override
  String get pluginManagerStatusActive => 'نشط';

  @override
  String get pluginManagerStatusInactive => 'غير نشط';

  @override
  String get pluginRepositoryAddTitle => 'إضافة مستودع مكونات';

  @override
  String get pluginRepositoryAddSubtitle =>
      'الصق رابط JSON للمستودع لاكتشاف وتثبيت المكونات.';

  @override
  String get pluginRepositoryAddAction => 'إضافة مستودع';

  @override
  String get pluginRepositoryTitle => 'مستودعات المكونات';

  @override
  String get pluginRepositorySubtitle => 'اكتشاف المكونات من مصادر خارجية';

  @override
  String get pluginRepositoryEmpty => 'لم يتم إضافة مستودعات بعد';

  @override
  String get pluginRepositoryUnknownUpdate => 'غير معروف';

  @override
  String get pluginRepositoryNoDescription => 'لا يوجد وصف متاح';

  @override
  String get pluginRepositoryUrlCopied => 'تم نسخ رابط المستودع إلى الحافظة';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكون',
      few: '$count مكونات',
      two: 'مكونان',
      one: 'مكون واحد',
      zero: 'لا توجد مكونات',
    );
    return '$_temp0';
  }

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'تم التحديث في $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكون متاح',
      few: '$count مكونات متاحة',
      two: 'مكونان متاحان',
      one: 'مكون واحد متاح',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest => 'بيان قديم. الميزات قد تتعطل.';

  @override
  String get pluginRepositoryUnknownPublisher => 'ناشر غير معروف';

  @override
  String get pluginRepositoryActionRetry => 'إعادة المحاولة';

  @override
  String get pluginRepositoryActionOutdated => 'قديم';

  @override
  String get pluginRepositoryActionInstalled => 'مثبت';

  @override
  String get pluginRepositoryActionInstall => 'تثبيت';

  @override
  String get pluginRepositoryActionUnavailable => 'غير متاح';

  @override
  String get pluginRepositoryInstallFailed => 'فشل التثبيت.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'فشل تنزيل $name.';
  }

  @override
  String get pluginRepositoryErrorLoad =>
      'فشل تحميل المستودعات. يرجى التحقق من اتصالك.';

  @override
  String get pluginRepositoryErrorInvalid => 'رابط مستودع أو تنسيق غير صالح.';

  @override
  String get pluginRepositoryErrorRemove => 'فشل إزالة المستودع.';

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم الاستبدال في $count قائمة$queue.',
      few: 'تم الاستبدال في $count قوائم$queue.',
      two: 'تم الاستبدال في قائمتين$queue.',
      one: 'تم الاستبدال في قائمة واحدة$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'بحث عن الكلمات...';

  @override
  String get lyricsSearchEmptyPrompt => 'اكتب الأغنية أو الفنان للبحث.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'لم يتم العثور على كلمات لـ \"$query\"';
  }

  @override
  String get lyricsSearchApplied => 'تم تطبيق الكلمات بنجاح';

  @override
  String get lyricsSearchFetchFailed => 'فشل جلب الكلمات';

  @override
  String get lyricsSearchPreview => 'معاينة';

  @override
  String get lyricsSearchPreviewTooltip => 'معاينة الكلمات';

  @override
  String get lyricsSearchSynced => 'متزامن';

  @override
  String get lyricsSearchPreviewLoadFailed => 'فشل تحميل المعاينة.';

  @override
  String get lyricsSearchApplyAction => 'تطبيق الكلمات';

  @override
  String get lyricsSettingsSearchTitle => 'بحث مخصص للكلمات';

  @override
  String get lyricsSettingsSearchSubtitle => 'ابحث عن نسخ بديلة أونلاين';

  @override
  String get lyricsSettingsSyncTitle => 'تعديل المزامنة';

  @override
  String get lyricsSettingsSyncSubtitle =>
      'عالج الكلمات السريعة أو البطيئة جداً';

  @override
  String get lyricsSettingsSaveTitle => 'حفظ أوفلاين';

  @override
  String get lyricsSettingsSaveSubtitle => 'تخزين الكلمات على جهازك';

  @override
  String get lyricsSettingsDeleteTitle => 'حذف الكلمات المحفوظة';

  @override
  String get lyricsSettingsDeleteSubtitle => 'إزالة بيانات الكلمات أوفلاين';

  @override
  String get lyricsSyncTapToReset => 'اضغط لإعادة التعيين';

  @override
  String get upNextTitle => 'التالي';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر في القائمة',
      few: '$count عناصر في القائمة',
      two: 'عنصران في القائمة',
      one: 'عنصر واحد في القائمة',
      zero: 'لا توجد عناصر',
    );
    return '$_temp0';
  }

  @override
  String get tooltipCopyToClipboard => 'نسخ للحافظة';

  @override
  String get snackbarCopiedToClipboard => 'تم النسخ للحافظة';

  @override
  String get tooltipSongInfo => 'معلومات الأغنية';

  @override
  String get snackbarCannotDeletePlayingSong =>
      'لا يمكن حذف الأغنية المشغلة حالياً';

  @override
  String get playerLoopOff => 'إيقاف';

  @override
  String get playerLoopOne => 'تكرار واحد';

  @override
  String get playerLoopAll => 'تكرار الكل';

  @override
  String get snackbarOpeningAlbumPage => 'جاري فتح صفحة الألبوم الأصلية.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'إصدار جديد من Beats متاح الآن!\n\nالإصدار: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'تم تثبيت المكون \"$id\" بنجاح';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'تم حذف المكون \"$id\" بنجاح';
  }

  @override
  String get pluginBootstrapTitle => 'بدء إعداد Beats';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'إعداد محرك المكونات... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'هذا يحدث مرة واحدة فقط.';

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
  String get playerQueue => 'قائمة الانتظار';

  @override
  String get playerFullscreenLyrics => 'كلمات بملء الشاشة';

  @override
  String get localMusicEmpty => 'لم يتم العثور على موسيقى محلية';

  @override
  String get localMusicSearchEmpty => 'لم يتم العثور على مسارات تطابق بحثك.';

  @override
  String get localMusicMusicFolders => 'مجلدات الموسيقى';

  @override
  String get buttonShare => 'مشاركة';

  @override
  String get dialogDeletePlugin => 'حذف المكون الإضافي؟';

  @override
  String dialogDeletePluginMessage(String name) {
    return 'هل أنت متأكد أنك تريد حذف \"$name\"؟ سيؤدي هذا إلى إزالة ملفاته نهائياً.';
  }

  @override
  String get playlistMoreOptions => 'المزيد من الخيارات';

  @override
  String get settingsLocation => 'الموقع';

  @override
  String pluginRepositoryError(String message) {
    return 'خطأ: $message';
  }

  @override
  String get snackbarPlaylistQueued => 'تمت إضافة قائمة التشغيل للتنزيل';

  @override
  String get snackbarNoInternet => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get snackbarImportFailed => 'فشل الاستيراد!';

  @override
  String get snackbarImportCompleted => 'اكتمل الاستيراد';

  @override
  String get snackbarBackupFailed => 'فشل النسخ الاحتياطي!';

  @override
  String snackbarExportedTo(String path) {
    return 'تم التصدير إلى: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'تم نسخ معرف الوسائط';

  @override
  String get snackbarNoLinkAvailable => 'لا يوجد رابط متاح';

  @override
  String snackbarPreparingDownload(String title) {
    return 'جاري تحضير تنزيل $title...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title تم تنزيله بالفعل.';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title موجود بالفعل في القائمة.';
  }

  @override
  String snackbarDownloaded(String title) {
    return 'تم تنزيل $title';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'خطأ: خدمة التنزيل غير متاحة.';

  @override
  String get snackbarDeleteTrackFailDevice => 'فشل حذف المسار من ذاكرة الجهاز.';

  @override
  String get searchHintOfflineMusic => 'بحث في أغانيك...';

  @override
  String get songInfoTitle => 'العنوان';

  @override
  String get songInfoArtist => 'الفنان';

  @override
  String get songInfoAlbum => 'الألبوم';

  @override
  String get songInfoMediaId => 'معرف الوسائط';

  @override
  String get tooltipShuffle => 'تبديل عشوائي';

  @override
  String get tooltipDownloadPlaylist => 'تنزيل قائمة التشغيل';

  @override
  String get tooltipInfo => 'معلومات';

  @override
  String get storageBackupLocation => 'موقع النسخ الاحتياطي';

  @override
  String get storageBackupLocationAndroid => 'التنزيلات / مجلد بيانات التطبيق';

  @override
  String get storageBackupLocationDownloads => 'مجلد التنزيلات';

  @override
  String get storageCreateBackup => 'إنشاء نسخة احتياطية';

  @override
  String get storageCreateBackupSubtitle => 'حفظ إعداداتك وبياناتك في ملف.';

  @override
  String get storageBackupFailed => 'فشل النسخ الاحتياطي!';

  @override
  String get storageAutoBackupSubtitle =>
      'إنشاء نسخة احتياطية من بياناتك تلقائياً وبشكل دوري.';

  @override
  String get storageResetAppSubtitle =>
      'حذف جميع البيانات واستعادة التطبيق لحالته الافتراضية.';

  @override
  String get storageResetConfirmMessage =>
      'هل أنت متأكد؟ سيتم حذف جميع بياناتك ولا يمكن التراجع.';

  @override
  String get storageResetSuccess => 'تم إعادة تعيين التطبيق للحالة الافتراضية.';

  @override
  String get storageLocationDialogTitle => 'موقع النسخ الاحتياطي';

  @override
  String get storageLocationAndroid =>
      'تخزن النسخ في:\n\n1. مجلد التنزيلات\n2. Android/data/ls.Beats.musicplayer/data\n\nانسخ الملف من أي منهما.';

  @override
  String get storageLocationOther =>
      'تخزن النسخ في مجلد التنزيلات. انسخ الملف من هناك.';

  @override
  String get storageRestoreOptionsDesc =>
      'اختر البيانات التي تريد استعادتها. افتراضياً الكل محدد.';

  @override
  String get storageRestoreSelectAll => 'تحديد الكل';

  @override
  String get storageRestoreMediaItems => 'عناصر الوسائط (أغاني، مكتبة)';

  @override
  String get storageRestoreSearchHistory => 'سجل البحث';

  @override
  String get storageRestoreNoFile => 'لم يتم اختيار ملف.';

  @override
  String get storageRestoreSaveFailed => 'فشل حفظ الملف المختار.';

  @override
  String get storageRestoreConfirmPrefix =>
      'سيؤدي هذا لاستبدال ودمج الأجزاء المختارة ببيانات النسخة:';

  @override
  String get storageRestoreConfirmSuffix =>
      'سيتم تعديل بياناتك الحالية. هل أنت متأكد؟';

  @override
  String get storageRestoreNo => 'لا';

  @override
  String get storageRestoreMediaBullet => '• عناصر الوسائط';

  @override
  String get storageRestoreHistoryBullet => '• سجل البحث';

  @override
  String get storageUnexpectedError => 'حدث خطأ غير متوقع أثناء الاستعادة.';

  @override
  String get storageRestoreCompleted => 'اكتملت الاستعادة';

  @override
  String get storageRestoreSuccessMessage =>
      'تمت استعادة البيانات بنجاح. يفضل إعادة تشغيل التطبيق الآن.';

  @override
  String get storageRestoreFailedMessage => 'فشلت العملية بالأخطاء التالية:';

  @override
  String get storageRestoreUnknownError => 'حدث خطأ غير معروف.';

  @override
  String get storageRestoreRestartHint =>
      'يرجى إعادة تشغيل التطبيق لضمان الاتساق.';

  @override
  String get updateAppUpdatesHeader => 'تحديثات التطبيق';

  @override
  String get playlistTypeAlbum => 'ألبوم';

  @override
  String get playlistTypePlaylist => 'قائمة تشغيل';

  @override
  String get pluginManagerDowngradeTitle => 'تنزيل إصدار أقدم؟';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return 'أنت تثبت إصداراً أقدم أو مماثلاً لـ \"$name\". هل تود الاستمرار؟';
  }

  @override
  String get pluginManagerDowngradeAction => 'التثبيت على أي حال';

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count قائمة',
      few: '$count قوائم',
      two: 'قائمتين',
      one: 'قائمة واحدة',
    );
    return 'تم الاستبدال في $_temp0$queue.';
  }

  @override
  String get eqResetTooltip => 'إعادة تعيين';

  @override
  String get importBeatsFiles => 'استيراد ملفات Beats';

  @override
  String get importResolving => 'جاري التحليل...';

  @override
  String get importReviewTitle => 'مراجعة الاستيراد';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$resolved تم تحليلها، $failed فشلت من أصل $total';
  }

  @override
  String get importAutoMatched => 'طابق تلقائياً';

  @override
  String get importUserSelected => 'محدد';

  @override
  String get importNoMatch => 'لم يتم العثور على مطابقة';

  @override
  String get snackbarImportingMedia => 'جاري استيراد عناصر الوسائط..';

  @override
  String get snackbarPlaylistSaved => 'تم حفظ قائمة التشغيل في المكتبة!';

  @override
  String get snackbarMediaItemImported => 'تم استيراد عنصر الوسائط';

  @override
  String get snackbarPlaylistImported => 'تم استيراد قائمة التشغيل';

  @override
  String get snackbarOpenImportForUrl => 'افتح شاشة الاستيراد لمواصلة العملية.';

  @override
  String snackbarPreparingShare(String title) {
    return 'جاري تحضير $title للمشاركة';
  }

  @override
  String snackbarPreparingExport(String title) {
    return 'جاري تحضير $title للتصدير.';
  }

  @override
  String get upNextAutoPlay => 'تشغيل تلقائي';

  @override
  String pluginSnackbarLoaded(String id) {
    return 'تم تحميل المكون \"$id\"';
  }

  @override
  String get pluginBootstrapErrorTitle => 'اتصال بطيء جداً';

  @override
  String get pluginBootstrapErrorBody =>
      'تعذر تثبيت بعض المكونات. يمكنك استخدام Beats وستتم المحاولة مرة أخرى لاحقاً.';

  @override
  String get pluginBootstrapContinue => 'الاستمرار على أي حال';

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
