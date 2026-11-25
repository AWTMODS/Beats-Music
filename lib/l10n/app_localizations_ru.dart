// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get onboardingTitle => 'Добро пожаловать в Beats';

  @override
  String get onboardingSubtitle => 'Давайте настроим ваш язык и регион.';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get navHome => 'Главная';

  @override
  String get navLibrary => 'Медиатека';

  @override
  String get navSearch => 'Поиск';

  @override
  String get navLocal => 'Локально';

  @override
  String get navOffline => 'Оффлайн';

  @override
  String get playerEnjoyingFrom => 'Слушаете из';

  @override
  String get playerPlayWithMix => 'Автовоспроизведение микса';

  @override
  String get playerPlayNext => 'Играть следующим';

  @override
  String get playerAddToQueue => 'Добавить в очередь';

  @override
  String get playerAddToFavorites => 'Добавить в избранное';

  @override
  String get playerNoLyricsFound => 'Текст песни не найден';

  @override
  String get playerLyricsNoPlugin =>
      'Поставщик текстов не настроен. Перейдите в Настройки → Плагины для установки.';

  @override
  String get localMusicTitle => 'Локально';

  @override
  String get localMusicGrantPermission => 'Разрешить доступ';

  @override
  String get localMusicStorageAccessRequired => 'Требуется доступ к памяти';

  @override
  String get localMusicStorageAccessDesc =>
      'Пожалуйста, разрешите доступ для сканирования и воспроизведения аудиофайлов на вашем устройстве.';

  @override
  String get localMusicAddFolder => 'Добавить папку';

  @override
  String get localMusicScanNow => 'Сканировать сейчас';

  @override
  String localMusicScanFailed(String message) {
    return 'Ошибка сканирования: $message';
  }

  @override
  String get localMusicScanning =>
      'Сканирование устройства на наличие аудиофайлов...';

  @override
  String get localMusicShuffle => 'Перемешать';

  @override
  String get localMusicPlayAll => 'Играть все';

  @override
  String get localMusicSearchHint => 'Поиск локальной музыки...';

  @override
  String get localMusicRescanDevice => 'Пересканировать устройство';

  @override
  String get buttonCancel => 'Отмена';

  @override
  String get buttonDelete => 'Удалить';

  @override
  String get buttonOk => 'ОК';

  @override
  String get buttonUpdate => 'Обновить';

  @override
  String get buttonDownload => 'Скачать';

  @override
  String get buttonLater => 'Позже';

  @override
  String get buttonInfo => 'Инфо';

  @override
  String get buttonMore => 'Еще';

  @override
  String get dialogDeleteTrack => 'Удалить трек';

  @override
  String dialogDeleteTrackMessage(String title) {
    return 'Вы уверены, что хотите удалить «$title» с вашего устройства? Это действие нельзя отменить.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Этот трек также будет удален из:';

  @override
  String get dialogDontAskAgain => 'Больше не спрашивать';

  @override
  String get dialogUpdateAvailable => 'Доступно обновление';

  @override
  String get dialogUpdateNow => 'Обновить сейчас';

  @override
  String get dialogDownloadPlaylist => 'Скачать плейлист';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return 'Хотите скачать $count песен из «$title»? Они будут добавлены в очередь загрузки.';
  }

  @override
  String get dialogDownloadAll => 'Скачать все';

  @override
  String get playlistEdit => 'Изменить плейлист';

  @override
  String get playlistShareFile => 'Поделиться файлом';

  @override
  String get playlistExportFile => 'Экспортировать файл';

  @override
  String get playlistPlay => 'Играть';

  @override
  String get playlistAddToQueue => 'Добавить плейлист в очередь';

  @override
  String get playlistShare => 'Поделиться плейлистом';

  @override
  String get playlistDelete => 'Удалить плейлист';

  @override
  String get playlistEmptyState => 'Здесь пока нет песен!';

  @override
  String get playlistAvailableOffline => 'Доступно оффлайн';

  @override
  String get playlistShuffle => 'Перемешать';

  @override
  String get playlistNoMatchSearch => 'Плейлисты не найдены';

  @override
  String get playlistCreateNew => 'Создать плейлист';

  @override
  String get playlistCreateFirstOne => 'Плейлистов пока нет. Создайте первый!';

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
      other: '$count песен',
      few: '$count песни',
      one: '1 песня',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '«$title» удален из $playlist';
  }

  @override
  String get playlistFailedToLoad => 'Не удалось загрузить плейлист';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsPlugins => 'Плагины';

  @override
  String get settingsPluginsSubtitle =>
      'Установка, загрузка и управление плагинами.';

  @override
  String get settingsUpdates => 'Обновления';

  @override
  String get settingsUpdatesSubtitle => 'Проверить наличие обновлений';

  @override
  String get settingsDownloads => 'Загрузки';

  @override
  String get settingsDownloadsSubtitle => 'Путь, качество загрузки и др.';

  @override
  String get settingsLocalTracks => 'Локальные треки';

  @override
  String get settingsLocalTracksSubtitle =>
      'Сканирование, папки и автосканирование.';

  @override
  String get settingsPlayer => 'Настройки плеера';

  @override
  String get settingsPlayerSubtitle => 'Качество стриминга, автоплей и др.';

  @override
  String get settingsPluginDefaults => 'Стандартные плагины';

  @override
  String get settingsPluginDefaultsSubtitle => 'Источники поиска и приоритеты.';

  @override
  String get settingsUIElements => 'Интерфейс и Сервисы';

  @override
  String get settingsUIElementsSubtitle => 'Автопрокрутка, визуальные правки.';

  @override
  String get settingsLastFM => 'Настройки Last.FM';

  @override
  String get settingsLastFMSubtitle => 'API ключ, секрет и скробблинг.';

  @override
  String get settingsStorage => 'Хранилище';

  @override
  String get settingsStorageSubtitle => 'Бэкап, кэш, история, восстановление.';

  @override
  String get settingsLanguageCountry => 'Язык и Страна';

  @override
  String get settingsLanguageCountrySubtitle => 'Выберите язык и регион.';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsAboutSubtitle => 'Версия, разработчик и др.';

  @override
  String get settingsScanning => 'Сканирование';

  @override
  String get settingsMusicFolders => 'Музыкальные папки';

  @override
  String get settingsQuality => 'Качество';

  @override
  String get settingsHistory => 'История';

  @override
  String get settingsBackupRestore => 'Бэкап и Восстановление';

  @override
  String get settingsAutomatic => 'Автоматически';

  @override
  String get settingsDangerZone => 'Опасная зона';

  @override
  String get settingsScrobbling => 'Скробблинг';

  @override
  String get settingsAuthentication => 'Аутентификация';

  @override
  String get settingsHomeScreen => 'Главный экран';

  @override
  String get settingsChartVisibility => 'Видимость чартов';

  @override
  String get dialogAddingToDownloadQueue => 'Добавление в очередь загрузки';

  @override
  String get emptyNoInternet => 'Нет подключения к интернету!';

  @override
  String get emptyNoContentPlugin =>
      'Плагин контента не загружен. Загрузите его в менеджере.';

  @override
  String get emptyRefreshingSource =>
      'Обновление источника... Предыдущий недоступен.';

  @override
  String get emptyNoTracks => 'Треки отсутствуют';

  @override
  String get emptyNoResults => 'Ничего не найдено';

  @override
  String snackbarDeletedTrack(String title) {
    return 'Удалено: «$title»';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Не удалось удалить «$title»';
  }

  @override
  String get snackbarAddedToNextQueue => 'Будет воспроизведено следующим';

  @override
  String get snackbarAddedToQueue => 'Добавлено в очередь';

  @override
  String snackbarAddedToLiked(String title) {
    return '«$title» добавлено в любимые!!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Сейчас играет: $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return 'Плейлист «$name» в очереди';
  }

  @override
  String get snackbarPlaylistUpdated => 'Плейлист обновлен!';

  @override
  String get snackbarLinkCopied => 'Ссылка скопирована';

  @override
  String get snackbarCouldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return '$count песен добавлено в очередь загрузки';
  }

  @override
  String get searchHintExplore => 'Что вы хотите послушать?';

  @override
  String get searchHintLibrary => 'Поиск в медиатеке...';

  @override
  String get searchHintPlaylists => 'Поиск плейлистов...';

  @override
  String get searchStartTyping => 'Начните вводить для поиска...';

  @override
  String get searchNoSuggestions => 'Варианты не найдены!';

  @override
  String get searchNoResults =>
      'Результатов нет!\nПопробуйте другой запрос или источник.';

  @override
  String get searchFailed => 'Поиск не удался!';

  @override
  String get searchDiscover => 'Откройте для себя музыку...';

  @override
  String get searchSources => 'ИСТОЧНИКИ';

  @override
  String get searchNoPlugins => 'Нет установленных плагинов';

  @override
  String get searchTracks => 'Треки';

  @override
  String get searchAlbums => 'Альбомы';

  @override
  String get searchArtists => 'Исполнители';

  @override
  String get searchPlaylists => 'Плейлисты';

  @override
  String get exploreDiscover => 'Обзор';

  @override
  String get exploreRecently => 'Недавние';

  @override
  String get exploreLastFmPicks => 'Выбор Last.Fm';

  @override
  String get exploreFailedToLoad => 'Не удалось загрузить разделы главной.';

  @override
  String get libraryTitle => 'Медиатека';

  @override
  String get libraryEmptyState => 'Ваша медиатека пустует. Добавьте музыки!';

  @override
  String libraryIn(String playlistName) {
    return 'в $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Добавить в плейлист';

  @override
  String get menuSmartReplace => 'Умная замена';

  @override
  String get menuShare => 'Поделиться';

  @override
  String get menuAvailableOffline => 'Доступно оффлайн';

  @override
  String get menuDownload => 'Скачать';

  @override
  String get menuOpenOriginalLink => 'Открыть оригинал';

  @override
  String get menuDeleteTrack => 'Удалить';

  @override
  String get tooltipRemoveFromLibrary => 'Удалить из медиатеки';

  @override
  String get tooltipSaveToLibrary => 'Сохранить в медиатеку';

  @override
  String get tooltipOpenOriginalLink => 'Открыть в оригинале';

  @override
  String get tooltipAvailableOffline => 'Доступно оффлайн';

  @override
  String get tooltipMoreOptions => 'Дополнительно';

  @override
  String get appuiTitle => 'Интерфейс и Сервисы';

  @override
  String get appuiAutoSlideCharts => 'Автопрокрутка чартов';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Автоматически прокручивать чарты на главной.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Показывать рекомендации Last.FM. Нужен вход.';

  @override
  String get appuiNoChartsAvailable => 'Чарты недоступны. Загрузите плагин.';

  @override
  String get appuiLoginToLastFm => 'Пожалуйста, сначала войдите в Last.FM.';

  @override
  String get appuiShowInCarousel => 'Показывать в карусели на главной.';

  @override
  String get countrySettingTitle => 'Страна и Язык';

  @override
  String get countrySettingAutoDetect => 'Автоопределение страны';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Определять регион автоматически при запуске.';

  @override
  String get countrySettingCountryLabel => 'Страна';

  @override
  String get countrySettingLanguageLabel => 'Язык';

  @override
  String get countrySettingSystemDefault => 'Системный';

  @override
  String get downloadSettingTitle => 'Загрузки';

  @override
  String get downloadSettingQuality => 'Качество загрузки';

  @override
  String get downloadSettingQualitySubtitle =>
      'Предпочтительный битрейт для скачанных треков.';

  @override
  String get downloadSettingFolder => 'Папка загрузок';

  @override
  String get downloadSettingResetFolder => 'Сбросить папку загрузок';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Вернуть папку по умолчанию.';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'Скробблинг треков';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Отправлять прослушивания в профиль Last.FM.';

  @override
  String get lastfmAuthFirst => 'Сначала настройте API Last.FM.';

  @override
  String get lastfmAuthenticatedAs => 'Вход выполнен как';

  @override
  String get lastfmAuthFailed => 'Ошибка аутентификации:';

  @override
  String get lastfmNotAuthenticated => 'Вход не выполнен';

  @override
  String get lastfmSteps =>
      'Шаги:\n1. Создайте аккаунт на Last.FM\n2. Получите API Key на last.fm/api/account/create\n3. Введите Key и Secret ниже\n4. Нажмите «Start Auth» и подтвердите в браузере\n5. Нажмите «Get Session Key» для завершения';

  @override
  String get lastfmApiKey => 'API Key';

  @override
  String get lastfmApiSecret => 'API Secret';

  @override
  String get lastfmStartAuth => '1. Начать авторизацию';

  @override
  String get lastfmGetSession => '2. Сохранить сессию';

  @override
  String get lastfmRemoveKeys => 'Удалить ключи';

  @override
  String get lastfmStartAuthFirst =>
      'Сначала начните авторизацию и подтвердите в браузере.';

  @override
  String get localSettingTitle => 'Локальные треки';

  @override
  String get localSettingAutoScan => 'Сканировать при запуске';

  @override
  String get localSettingAutoScanSubtitle =>
      'Автоматический поиск новой музыки при запуске.';

  @override
  String get localSettingLastScan => 'Последнее сканирование';

  @override
  String get localSettingNeverScanned => 'Никогда';

  @override
  String get localSettingScanInProgress => 'Сканирование...';

  @override
  String get localSettingScanNowSubtitle =>
      'Запустить полное сканирование вручную.';

  @override
  String get localSettingNoFolders =>
      'Папки не добавлены. Добавьте для начала.';

  @override
  String get localSettingAddFolder => 'Добавить папку';

  @override
  String get playerSettingTitle => 'Настройки плеера';

  @override
  String get playerSettingStreamingHeader => 'Стриминг';

  @override
  String get playerSettingStreamQuality => 'Качество стриминга';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Битрейт для проигрывания онлайн.';

  @override
  String get playerSettingQualityLow => 'Низкое';

  @override
  String get playerSettingQualityMedium => 'Среднее';

  @override
  String get playerSettingQualityHigh => 'Высокое';

  @override
  String get playerSettingPlaybackHeader => 'Воспроизведение';

  @override
  String get playerSettingAutoPlay => 'Автоплей';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Добавлять похожие песни в конец очереди.';

  @override
  String get playerSettingAutoFallback => 'Автозамена источника';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Если плагин недоступен, пробовать другие варианты.';

  @override
  String get playerSettingCrossfade => 'Перекрестное затухание';

  @override
  String get playerSettingCrossfadeOff => 'Выкл';

  @override
  String get playerSettingCrossfadeInstant => 'Мгновенная смена треков';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'Слияние в течение $seconds сек.';
  }

  @override
  String get playerSettingEqualizer => 'Эквалайзер';

  @override
  String get playerSettingEqualizerActive => 'Активен';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Включен — пресет «$preset»';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      '10-полосный эквалайзер через FFmpeg.';

  @override
  String get pluginDefaultsTitle => 'Стандартные плагины';

  @override
  String get pluginDefaultsDiscoverHeader => 'Источник обзора';

  @override
  String get pluginDefaultsNoResolver => 'Плагины контента не найдены.';

  @override
  String get pluginDefaultsAutomaticSubtitle =>
      'Использовать первый доступный.';

  @override
  String get pluginDefaultsPriorityHeader => 'Приоритет резолверов';

  @override
  String get pluginDefaultsNoPriority => 'Резолверы не загружены.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Перетащите для изменения. Верхние пробуются первыми.';

  @override
  String get pluginDefaultsLyricsHeader => 'Приоритет текстов';

  @override
  String get pluginDefaultsLyricsNone => 'Поставщики текстов не загружены.';

  @override
  String get pluginDefaultsLyricsDesc => 'Порядок поиска текстов песен.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Поисковые предложения';

  @override
  String get pluginDefaultsSuggestionsNone =>
      'Поставщики предложений не загружены.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Нет';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle =>
      'Только история поиска.';

  @override
  String get storageSettingTitle => 'Хранилище';

  @override
  String get storageClearHistoryEvery => 'Очищать историю каждые';

  @override
  String get storageClearHistorySubtitle =>
      'Автоматически удалять историю прослушиваний.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      few: '$count дня',
      one: '1 день',
    );
    return '$_temp0';
  }

  @override
  String storageBackupCreatedAt(String path) {
    return 'Бэкап создан в $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Не удалось поделиться бэкапом: $error';
  }

  @override
  String get storageRestoreBackup => 'Восстановить из бэкапа';

  @override
  String get storageRestoreBackupSubtitle => 'Восстановить данные из файла.';

  @override
  String get storageAutoBackup => 'Автобэкап';

  @override
  String get storageAutoLyrics => 'Автосохранение текста';

  @override
  String get storageAutoLyricsSubtitle =>
      'Сохранять текст песни при прослушивании.';

  @override
  String get storageResetApp => 'Сброс Beats';

  @override
  String get storageResetConfirmTitle => 'Подтверждение сброса';

  @override
  String get storageResetButton => 'Сбросить';

  @override
  String get storageRestoreOptionsTitle => 'Параметры восстановления';

  @override
  String get storageRestoreContinue => 'Продолжить';

  @override
  String get storageRestoreConfirmTitle => 'Подтверждение восстановления';

  @override
  String get storageRestoreYes => 'Да, восстановить';

  @override
  String get storageRestoring => 'Восстановление... Пожалуйста, подождите.';

  @override
  String get storageRestoreFailedTitle => 'Восстановление не удалось';

  @override
  String get updateSettingTitle => 'Обновления';

  @override
  String get updateCheckForUpdates => 'Проверить обновления';

  @override
  String get updateCheckSubtitle => 'Поиск новой версии Beats.';

  @override
  String get updateAutoNotify => 'Автоуведомление';

  @override
  String get updateAutoNotifySubtitle =>
      'Сообщать о наличии обновлений при запуске.';

  @override
  String get updateCheckTitle => 'Поиск';

  @override
  String get updateUpToDate => 'Beats обновлен до последней версии!';

  @override
  String get updateViewPreRelease => 'Посмотреть тестовые версии';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Текущая версия: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable => 'Доступна новая версия Beats!!';

  @override
  String updateVersion(String ver, String build) {
    return 'Версия: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Скачать сейчас';

  @override
  String get updateChecking => 'Проверка обновлений...';

  @override
  String get timerTitle => 'Таймер сна';

  @override
  String get timerInterludeMessage => 'Готовьтесь к тишине через...';

  @override
  String get timerHours => 'Часы';

  @override
  String get timerMinutes => 'Минуты';

  @override
  String get timerSeconds => 'Секунды';

  @override
  String get timerStop => 'Остановить таймер';

  @override
  String get timerFinishedMessage => 'Музыка замолкла. Приятных снов 🥰.';

  @override
  String get timerGotIt => 'Понятно!';

  @override
  String get timerSetTimeError => 'Укажите время';

  @override
  String get timerStart => 'Запустить таймер';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsEmpty => 'Пока уведомлений нет!';

  @override
  String get recentsTitle => 'История';

  @override
  String playlistByCreator(String creator) {
    return 'от $creator';
  }

  @override
  String get playlistYou => 'Вы';

  @override
  String get pluginManagerTitle => 'Плагины';

  @override
  String get pluginManagerEmpty =>
      'Нет установленных плагинов.\nНажмите +, чтобы добавить .bex файл.';

  @override
  String get pluginManagerFilterAll => 'Все';

  @override
  String get pluginManagerFilterContent => 'Контент';

  @override
  String get pluginManagerFilterCharts => 'Чарты';

  @override
  String get pluginManagerFilterLyrics => 'Тексты';

  @override
  String get pluginManagerFilterSuggestions => 'Предложения';

  @override
  String get pluginManagerFilterImporters => 'Импортеры';

  @override
  String get pluginManagerTooltipRefresh => 'Обновить';

  @override
  String get pluginManagerTooltipInstall => 'Установить плагин';

  @override
  String get pluginManagerNoMatch => 'Ничего не найдено';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Ошибка выбора: $error';
  }

  @override
  String get pluginManagerInstalling => 'Установка...';

  @override
  String get pluginManagerTypeContentResolver => 'Резолвер';

  @override
  String get pluginManagerTypeChartProvider => 'Чарты';

  @override
  String get pluginManagerTypeLyricsProvider => 'Тексты';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Предложения';

  @override
  String get pluginManagerTypeContentImporter => 'Импортер';

  @override
  String get pluginManagerDeleteTitle => 'Удалить плагин?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return 'Вы уверены? «$name» будет удален.';
  }

  @override
  String get pluginManagerDeleteAction => 'Удалить';

  @override
  String get pluginManagerCancel => 'Отмена';

  @override
  String get pluginManagerEnablePlugin => 'Включить';

  @override
  String get pluginManagerUnloadPlugin => 'Выгрузить';

  @override
  String get pluginManagerDeleting => 'Удаление...';

  @override
  String get pluginManagerApiKeysTitle => 'API Ключи';

  @override
  String get pluginManagerApiKeysSaved => 'Ключи сохранены';

  @override
  String get pluginManagerSave => 'Сохранить';

  @override
  String get pluginManagerDetailVersion => 'Версия';

  @override
  String get pluginManagerDetailType => 'Тип';

  @override
  String get pluginManagerDetailPublisher => 'Издатель';

  @override
  String get pluginManagerDetailLastUpdated => 'Обновлено';

  @override
  String get pluginManagerDetailCreated => 'Создано';

  @override
  String get pluginManagerDetailHomepage => 'Сайт';

  @override
  String get pluginManagerDeleteStorageTitle => 'Удалить данные?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return 'Удалить также ключи и настройки «$name»?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Оставить';

  @override
  String get pluginManagerDeleteStorageRemove => 'Удалить';

  @override
  String get segmentsSheetTitle => 'Сегменты';

  @override
  String get segmentsSheetEmpty => 'Сегменты отсутствуют';

  @override
  String get segmentsSheetUntitled => 'Без названия';

  @override
  String get smartReplaceTitle => 'Умная замена';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Выберите замену для «$title».';
  }

  @override
  String get smartReplaceClose => 'Закрыть';

  @override
  String get smartReplaceNoMatch => 'Замена не найдена';

  @override
  String get smartReplaceNoMatchSubtitle =>
      'Плагины не вернули точных совпадений.';

  @override
  String get smartReplaceBestMatch => 'Лучшее совпадение';

  @override
  String get smartReplaceSearchFailed => 'Поиск не удался';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Ошибка замены: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Замена применена$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' и в очереди';

  @override
  String get playerUnknownQueue => 'Неизвестно';

  @override
  String playerLiked(String title) {
    return '«$title» в избранном!';
  }

  @override
  String playerUnliked(String title) {
    return '«$title» удалено из избранного!';
  }

  @override
  String get offlineNoDownloads => 'Загрузок нет';

  @override
  String get offlineTitle => 'Оффлайн';

  @override
  String get offlineSearchHint => 'Поиск в песнях...';

  @override
  String get offlineRefreshTooltip => 'Обновить загрузки';

  @override
  String get offlineCloseSearch => 'Закрыть поиск';

  @override
  String get offlineSearchTooltip => 'Поиск';

  @override
  String get offlineOpenFailed => 'Не удалось открыть трек. Обновите список.';

  @override
  String get offlinePlayFailed => 'Не удалось воспроизвести песню оффлайн.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count треков',
      few: '$count трека',
      one: '1 трек',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Не удалось загрузить альбом';

  @override
  String get aboutCraftingSubtitle => 'Симфонии в коде.';

  @override
  String get aboutFollowGitHub => 'Следить на GitHub';

  @override
  String get aboutSendInquiry => 'Бизнес-запрос';

  @override
  String get aboutCreativeHighlights => 'Обновления и творчество';

  @override
  String get aboutTipQuote => 'Нравится Beats? Чаевые помогут проекту цвести. ';

  @override
  String get aboutTipButton => 'Хочу помочь';

  @override
  String get aboutTipDesc => 'Для развития Beats.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Детали песни';

  @override
  String get songInfoSectionTechnical => 'Техданные';

  @override
  String get songInfoSectionActions => 'Действия';

  @override
  String get songInfoLabelTitle => 'Название';

  @override
  String get songInfoLabelArtist => 'Исполнитель';

  @override
  String get songInfoLabelAlbum => 'Альбом';

  @override
  String get songInfoLabelDuration => 'Длительность';

  @override
  String get songInfoLabelSource => 'Источник';

  @override
  String get songInfoLabelMediaId => 'Media ID';

  @override
  String get songInfoLabelPluginId => 'Plugin ID';

  @override
  String get songInfoCopyId => 'Копировать ID';

  @override
  String get songInfoCopyLink => 'Копировать ссылку';

  @override
  String get songInfoOpenBrowser => 'Открыть в браузере';

  @override
  String get songInfoIdCopied => 'ID скопирован';

  @override
  String get songInfoLinkCopied => 'Ссылка скопирована';

  @override
  String get songInfoNoLink => 'Ссылка недоступна';

  @override
  String get songInfoOpenFailed => 'Не удалось открыть';

  @override
  String get songInfoUpdateMetadata => 'Обновить метаданные';

  @override
  String get songInfoMetadataUpdated => 'Данные обновлены';

  @override
  String get songInfoMetadataUpdateFailed => 'Ошибка обновления';

  @override
  String get songInfoMetadataUnavailable => 'Обновление недоступно';

  @override
  String get songInfoSearchTitle => 'Искать в Beats';

  @override
  String get songInfoSearchArtist => 'Искать артиста';

  @override
  String get songInfoSearchAlbum => 'Искать альбом';

  @override
  String get eqTitle => 'Эквалайзер';

  @override
  String get chartNoItems => 'Список пуст';

  @override
  String get chartLoadFailed => 'Ошибка загрузки чарта';

  @override
  String get chartPlay => 'Играть';

  @override
  String get chartResolving => 'Обработка';

  @override
  String get chartReady => 'Готово';

  @override
  String get chartAddToPlaylist => 'В плейлист';

  @override
  String get chartNoResolver => 'Резолвер не найден.';

  @override
  String get chartResolveFailed => 'Ошибка. Ищем замену...';

  @override
  String get chartNoResolverAdd => 'Резолвер не загружен.';

  @override
  String get chartNoMatch => 'Совпадений нет. Ищите вручную.';

  @override
  String get chartStatPeak => 'Пик';

  @override
  String get chartStatWeeks => 'Недель';

  @override
  String get chartStatChange => 'Изменение';

  @override
  String menuSharePreparing(String title) {
    return 'Подготовка «$title» для отправки.';
  }

  @override
  String get menuOpenLinkFailed => 'Не удалось открыть';

  @override
  String get localMusicFolders => 'Папки';

  @override
  String get localMusicRemoveFolder => 'Удалить папку';

  @override
  String get localMusicCloseSearch => 'Закрыть';

  @override
  String get localMusicOpenSearch => 'Поиск';

  @override
  String get localMusicNoMusicFound => 'Музыка не найдена';

  @override
  String get localMusicNoSearchResults => 'Ничего не найдено.';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count треков',
      few: '$count трека',
      one: '1 трек',
      zero: 'Нет треков',
    );
    return '$_temp0';
  }

  @override
  String get importSongsTitle => 'Импорт песен';

  @override
  String get importNoPluginsLoaded =>
      'Импортеры не найдены. Установите один для импорта.';

  @override
  String get importBloomeeFiles => 'Import Beats Files';

  @override
  String get importM3UFiles => 'Плейлист M3U';

  @override
  String get importM3UNameDialogTitle => 'Название плейлиста';

  @override
  String get importM3UNameHint => 'Введите название';

  @override
  String get importM3UNoTracks => 'Треки в M3U не найдены.';

  @override
  String get importNoteTitle => 'Заметка';

  @override
  String get importNoteMessage =>
      'Только файлы Beats поддерживаются полностью. Продолжить?';

  @override
  String get importTitle => 'Импорт';

  @override
  String get importCheckingUrl => 'Проверка URL...';

  @override
  String get importFetchingTracks => 'Получение треков...';

  @override
  String get importSavingToLibrary => 'Сохранение...';

  @override
  String get importPasteUrlHint => 'URL плейлиста или альбома';

  @override
  String get importAction => 'Импорт';

  @override
  String importTrackCount(int count) {
    return '$count треков';
  }

  @override
  String importResolvingProgress(int done, int total) {
    return 'Обработка: $done / $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Сохранить $count треков';
  }

  @override
  String importTracksSaved(int count) {
    return '$count треков сохранено!';
  }

  @override
  String get importDone => 'Готово';

  @override
  String get importMore => 'Импортировать еще';

  @override
  String get importUnknownError => 'Неизвестная ошибка';

  @override
  String get importTryAgain => 'Повторить';

  @override
  String get importSkipTrack => 'Пропустить трек';

  @override
  String get importMatchOptions => 'Опции совпадений';

  @override
  String get importSkipped => 'Пропущено';

  @override
  String get importReorderTip => 'Удерживайте для изменения порядка';

  @override
  String get importErrorCannotHandleUrl => 'Плагин не поддерживает этот URL.';

  @override
  String get importErrorUnexpectedResponse => 'Неожиданный ответ плагина.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Ошибка проверки: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Не удалось получить информацию о коллекции: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Не удалось получить треки: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Не удалось сохранить плейлист: $error';
  }

  @override
  String get playlistPinToTop => 'Закрепить';

  @override
  String get playlistUnpin => 'Открепить';

  @override
  String get snackbarInvalidFileFormat => 'Неверный формат';

  @override
  String get snackbarProcessingFile => 'Обработка файла...';

  @override
  String get pluginManagerTabInstalled => 'Установлено';

  @override
  String get pluginManagerTabStore => 'Магазин';

  @override
  String get pluginManagerSelectPackage => 'Выберите .bex файл';

  @override
  String get pluginManagerOutdatedManifest =>
      'Старый манифест. Ошибки вероятны.';

  @override
  String get pluginManagerStatusActive => 'Активен';

  @override
  String get pluginManagerStatusInactive => 'Не активен';

  @override
  String get pluginRepositoryAddTitle => 'Добавить репозиторий плагинов';

  @override
  String get pluginRepositoryAddSubtitle => 'Вставьте URL JSON репозитория.';

  @override
  String get pluginRepositoryAddAction => 'Добавить';

  @override
  String get pluginRepositoryTitle => 'Репозитории плагинов';

  @override
  String get pluginRepositorySubtitle =>
      'Поиск плагинов в удаленных источниках';

  @override
  String get pluginRepositoryEmpty => 'Репозитории пока не добавлены';

  @override
  String get pluginRepositoryUnknownUpdate => 'Неизвестно';

  @override
  String get pluginRepositoryNoDescription => 'Описание отсутствует';

  @override
  String get pluginRepositoryUrlCopied => 'URL скопирован в буфер обмена';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count плагинов',
      few: '$count плагина',
      one: '1 плагин',
    );
    return '$_temp0';
  }

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Обновлено $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count доступно',
      one: '1 доступен',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest => 'Устаревший манифест.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Неизвестен';

  @override
  String get pluginRepositoryActionRetry => 'Повторить';

  @override
  String get pluginRepositoryActionOutdated => 'Устарело';

  @override
  String get pluginRepositoryActionInstalled => 'Установлено';

  @override
  String get pluginRepositoryActionInstall => 'Установить';

  @override
  String get pluginRepositoryActionUnavailable => 'Недоступно';

  @override
  String get pluginRepositoryInstallFailed => 'Ошибка установки.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'Ошибка загрузки $name.';
  }

  @override
  String get pluginRepositoryErrorLoad =>
      'Ошибка загрузки. Проверьте соединение.';

  @override
  String get pluginRepositoryErrorInvalid => 'Неверный URL или формат.';

  @override
  String get pluginRepositoryErrorRemove => 'Ошибка удаления репозитория.';

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Заменено в $count плейлистах$queue.',
      one: 'Заменено в 1 плейлисте$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'Поиск текста...';

  @override
  String get lyricsSearchEmptyPrompt => 'Введите песню или артиста.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Текст для «$query» не найден';
  }

  @override
  String get lyricsSearchApplied => 'Текст успешно применен';

  @override
  String get lyricsSearchFetchFailed => 'Ошибка получения текста';

  @override
  String get lyricsSearchPreview => 'Предпросмотр';

  @override
  String get lyricsSearchPreviewTooltip => 'Посмотреть текст';

  @override
  String get lyricsSearchSynced => 'СИНХР';

  @override
  String get lyricsSearchPreviewLoadFailed => 'Ошибка загрузки превью.';

  @override
  String get lyricsSearchApplyAction => 'Применить';

  @override
  String get lyricsSettingsSearchTitle => 'Поиск текста';

  @override
  String get lyricsSettingsSearchSubtitle => 'Другие версии онлайн';

  @override
  String get lyricsSettingsSyncTitle => 'Синхронизация';

  @override
  String get lyricsSettingsSyncSubtitle => 'Исправить опоздание текста';

  @override
  String get lyricsSettingsSaveTitle => 'Сохранить';

  @override
  String get lyricsSettingsSaveSubtitle => 'Сохранить на устройство';

  @override
  String get lyricsSettingsDeleteTitle => 'Удалить сохраненные';

  @override
  String get lyricsSettingsDeleteSubtitle => 'Очистить локальный кэш текста';

  @override
  String get lyricsSyncTapToReset => 'Сбросить';

  @override
  String get upNextTitle => 'Далее';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count песен в очереди',
      one: '1 песня в очереди',
    );
    return '$_temp0';
  }

  @override
  String get tooltipCopyToClipboard => 'Копировать';

  @override
  String get snackbarCopiedToClipboard => 'Скопировано';

  @override
  String get tooltipSongInfo => 'Инфо';

  @override
  String get snackbarCannotDeletePlayingSong => 'Нельзя удалить текущую песню';

  @override
  String get playerLoopOff => 'Выкл';

  @override
  String get playerLoopOne => 'Одна';

  @override
  String get playerLoopAll => 'Все';

  @override
  String get snackbarOpeningAlbumPage => 'Открытие страницы альбома.';

  @override
  String updateAvailableBody(String ver, String build) {
    return 'Новая версия Beats!\n\nВерсия: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return 'Плагин «$id» установлен';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Плагин «$id» удален';
  }

  @override
  String get pluginBootstrapTitle => 'Настройка Beats';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Движок плагинов... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'Только при первом запуске.';

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
  String get playerQueue => 'Очередь';

  @override
  String get playerFullscreenLyrics => 'Текст на весь экран';

  @override
  String get localMusicEmpty => 'Локальная музыка не найдена';

  @override
  String get localMusicSearchEmpty =>
      'Треки, соответствующие вашему запросу, не найдены.';

  @override
  String get localMusicMusicFolders => 'Музыкальные папки';

  @override
  String get buttonShare => 'Поделиться';

  @override
  String get dialogDeletePlugin => 'Удалить плагин?';

  @override
  String dialogDeletePluginMessage(String name) {
    return 'Вы уверены, что хотите удалить «$name»? Его файлы будут безвозвратно удалены.';
  }

  @override
  String get playlistMoreOptions => 'Дополнительно';

  @override
  String get settingsLocation => 'Местоположение';

  @override
  String pluginRepositoryError(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get snackbarPlaylistQueued => 'Плейлист добавлен в загрузки';

  @override
  String get snackbarNoInternet => 'Нет подключения к интернету.';

  @override
  String get snackbarImportFailed => 'Импорт не удался!';

  @override
  String get snackbarImportCompleted => 'Импорт завершен';

  @override
  String get snackbarBackupFailed => 'Бэкап не удался!';

  @override
  String snackbarExportedTo(String path) {
    return 'Экспортировано в: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'Media ID скопирован';

  @override
  String get snackbarNoLinkAvailable => 'Ссылка недоступна';

  @override
  String snackbarPreparingDownload(String title) {
    return 'Подготовка к загрузке «$title»...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '«$title» уже скачан.';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '«$title» уже в очереди.';
  }

  @override
  String snackbarDownloaded(String title) {
    return 'Скачано: $title';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'Ошибка: Сервис загрузки недоступен.';

  @override
  String get snackbarDeleteTrackFailDevice =>
      'Ошибка удаления файла с устройства.';

  @override
  String get searchHintOfflineMusic => 'Поиск в ваших песнях...';

  @override
  String get songInfoTitle => 'Название';

  @override
  String get songInfoArtist => 'Исполнитель';

  @override
  String get songInfoAlbum => 'Альбом';

  @override
  String get songInfoMediaId => 'Media ID';

  @override
  String get tooltipShuffle => 'Перемешать';

  @override
  String get tooltipDownloadPlaylist => 'Скачать плейлист';

  @override
  String get tooltipInfo => 'Инфо';

  @override
  String get storageBackupLocation => 'Место бэкапа';

  @override
  String get storageBackupLocationAndroid => 'Загрузки / Папка приложения';

  @override
  String get storageBackupLocationDownloads => 'Папка «Загрузки»';

  @override
  String get storageCreateBackup => 'Создать бэкап';

  @override
  String get storageCreateBackupSubtitle =>
      'Сохранить настройки и данные в файл.';

  @override
  String get storageBackupFailed => 'Создание бэкапа не удалось!';

  @override
  String get storageAutoBackupSubtitle =>
      'Создавать резервные копии автоматически.';

  @override
  String get storageResetAppSubtitle =>
      'Удалить все данные и вернуть настройки к заводским.';

  @override
  String get storageResetConfirmMessage =>
      'Вы уверены? Это удалит все данные без возможности восстановления.';

  @override
  String get storageResetSuccess =>
      'Приложение сброшено к исходному состоянию.';

  @override
  String get storageLocationDialogTitle => 'Путь бэкапа';

  @override
  String get storageLocationAndroid =>
      'Бэкапы находятся в:\n1. Папка «Загрузки»\n2. Android/data/ls.Beats.musicplayer/data';

  @override
  String get storageLocationOther => 'Бэкапы сохранены в папке «Загрузки».';

  @override
  String get storageRestoreOptionsDesc => 'Выберите данные для восстановления.';

  @override
  String get storageRestoreSelectAll => 'Выбрать все';

  @override
  String get storageRestoreMediaItems => 'Медиаданные (песни, библиотека)';

  @override
  String get storageRestoreSearchHistory => 'История поиска';

  @override
  String get storageRestoreNoFile => 'Файл не выбран.';

  @override
  String get storageRestoreSaveFailed =>
      'Ошибка при сохранении выбранного файла.';

  @override
  String get storageRestoreConfirmPrefix =>
      'Это перезапишет и объединит данные с бэкапом:';

  @override
  String get storageRestoreConfirmSuffix => 'Вы уверены?';

  @override
  String get storageRestoreNo => 'Нет';

  @override
  String get storageRestoreMediaBullet => '• Медиаданные';

  @override
  String get storageRestoreHistoryBullet => '• История поиска';

  @override
  String get storageUnexpectedError =>
      'Произошла непредвиденная ошибка при восстановлении.';

  @override
  String get storageRestoreCompleted => 'Восстановление завершено';

  @override
  String get storageRestoreSuccessMessage =>
      'Данные восстановлены. Рекомендуется перезапустить приложение.';

  @override
  String get storageRestoreFailedMessage => 'Ошибки в процессе:';

  @override
  String get storageRestoreUnknownError => 'Произошла неизвестная ошибка.';

  @override
  String get storageRestoreRestartHint =>
      'Пожалуйста, перезапустите приложение.';

  @override
  String get updateAppUpdatesHeader => 'Приложение';

  @override
  String get playlistTypeAlbum => 'Альбом';

  @override
  String get playlistTypePlaylist => 'Плейлист';

  @override
  String get pluginManagerDowngradeTitle => 'Откат версии?';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return 'Вы устанавливаете старую версию. Продолжить?';
  }

  @override
  String get pluginManagerDowngradeAction => 'Все равно установить';

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count плейлистах',
      few: '$count плейлистах',
      one: '1 плейлисте',
    );
    return 'Заменено в $_temp0$queue.';
  }

  @override
  String get eqResetTooltip => 'Сброс';

  @override
  String get importBeatsFiles => 'Файлы Beats';

  @override
  String get importResolving => 'Анализ...';

  @override
  String get importReviewTitle => 'Итоги импорта';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$resolved успешно, $failed ошибка из $total';
  }

  @override
  String get importAutoMatched => 'Авто';

  @override
  String get importUserSelected => 'Выбрано';

  @override
  String get importNoMatch => 'Нет совпадений';

  @override
  String get snackbarImportingMedia => 'Импорт медиаданных...';

  @override
  String get snackbarPlaylistSaved => 'Плейлист сохранен!';

  @override
  String get snackbarMediaItemImported => 'Медиафайл импортирован';

  @override
  String get snackbarPlaylistImported => 'Плейлист импортирован';

  @override
  String get snackbarOpenImportForUrl => 'Откройте экран импорта.';

  @override
  String snackbarPreparingShare(String title) {
    return 'Подготовка «$title»...';
  }

  @override
  String snackbarPreparingExport(String title) {
    return 'Экспорт «$title»...';
  }

  @override
  String get upNextAutoPlay => 'Авто';

  @override
  String pluginSnackbarLoaded(String id) {
    return 'Плагин «$id» загружен';
  }

  @override
  String get pluginBootstrapErrorTitle => 'Медленное соединение';

  @override
  String get pluginBootstrapErrorBody =>
      'Некоторые плагины не загружены. Повтор позже.';

  @override
  String get pluginBootstrapContinue => 'Продолжить';

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
