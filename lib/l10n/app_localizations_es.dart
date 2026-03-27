// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get onboardingTitle => 'Bienvenido a Beats';

  @override
  String get onboardingSubtitle => 'Configuremos tu idioma y región.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get navHome => 'Inicio';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navLocal => 'Local';

  @override
  String get navOffline => 'Sin conexión';

  @override
  String get playerEnjoyingFrom => 'Escuchando desde';

  @override
  String get playerQueue => 'Cola';

  @override
  String get playerPlayWithMix => 'Reproducción automática';

  @override
  String get playerPlayNext => 'Reproducir siguiente';

  @override
  String get playerAddToQueue => 'Añadir a la cola';

  @override
  String get playerAddToFavorites => 'Añadir a favoritos';

  @override
  String get playerNoLyricsFound => 'No se encontraron letras';

  @override
  String get playerLyricsNoPlugin =>
      'No hay proveedor de letras configurado. Ve a Ajustes → Complementos para instalar uno.';

  @override
  String get playerFullscreenLyrics => 'Letras en pantalla completa';

  @override
  String get localMusicTitle => 'Local';

  @override
  String get localMusicGrantPermission => 'Conceder permiso';

  @override
  String get localMusicStorageAccessRequired =>
      'Acceso al almacenamiento requerido';

  @override
  String get localMusicStorageAccessDesc =>
      'Por favor, concede permiso para escanear y reproducir archivos de audio almacenados en tu dispositivo.';

  @override
  String get localMusicAddFolder => 'Añadir carpeta de música';

  @override
  String get localMusicScanNow => 'Escanear ahora';

  @override
  String localMusicScanFailed(String message) {
    return 'Error de escaneo: $message';
  }

  @override
  String get localMusicScanning =>
      'Escaneando el dispositivo en busca de archivos de audio...';

  @override
  String get localMusicEmpty => 'No se encontró música local';

  @override
  String get localMusicSearchEmpty =>
      'No se encontraron pistas que coincidan con tu búsqueda.';

  @override
  String get localMusicShuffle => 'Aleatorio';

  @override
  String get localMusicPlayAll => 'Reproducir todo';

  @override
  String get localMusicSearchHint => 'Buscar música local...';

  @override
  String get localMusicRescanDevice => 'Re-escanear dispositivo';

  @override
  String get localMusicRemoveFolder => 'Eliminar carpeta';

  @override
  String get localMusicMusicFolders => 'Carpetas de música';

  @override
  String localMusicTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
      zero: 'Sin pistas',
    );
    return '$_temp0';
  }

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonDelete => 'Eliminar';

  @override
  String get buttonOk => 'Aceptar';

  @override
  String get buttonUpdate => 'Actualizar';

  @override
  String get buttonDownload => 'Descargar';

  @override
  String get buttonShare => 'Compartir';

  @override
  String get buttonLater => 'Más tarde';

  @override
  String get buttonInfo => 'Información';

  @override
  String get buttonMore => 'Más';

  @override
  String get dialogDeleteTrack => 'Eliminar pista';

  @override
  String dialogDeleteTrackMessage(String title) {
    return '¿Estás seguro de que quieres eliminar \"$title\" de tu dispositivo? Esta acción no se puede deshacer.';
  }

  @override
  String get dialogDeleteTrackLinkedPlaylists =>
      'Esta pista también se eliminará de:';

  @override
  String get dialogDontAskAgain => 'No volver a preguntar';

  @override
  String get dialogDeletePlugin => '¿Eliminar complemento?';

  @override
  String dialogDeletePluginMessage(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"? Esto eliminará permanentemente sus archivos.';
  }

  @override
  String get dialogUpdateAvailable => 'Actualización disponible';

  @override
  String get dialogUpdateNow => 'Actualizar ahora';

  @override
  String get dialogDownloadPlaylist => 'Descargar lista de reproducción';

  @override
  String dialogDownloadPlaylistMessage(int count, String title) {
    return '¿Quieres descargar $count canciones de \"$title\"? Se añadirán a la cola de descarga.';
  }

  @override
  String get dialogDownloadAll => 'Descargar todo';

  @override
  String get playlistEdit => 'Editar lista';

  @override
  String get playlistShareFile => 'Compartir archivo';

  @override
  String get playlistExportFile => 'Exportar archivo';

  @override
  String get playlistPlay => 'Reproducir';

  @override
  String get playlistAddToQueue => 'Añadir lista a la cola';

  @override
  String get playlistShare => 'Compartir lista';

  @override
  String get playlistDelete => 'Eliminar lista';

  @override
  String get playlistEmptyState => '¡No hay canciones aún!';

  @override
  String get playlistAvailableOffline => 'Disponible sin conexión';

  @override
  String get playlistShuffle => 'Aleatorio';

  @override
  String get playlistMoreOptions => 'Más opciones';

  @override
  String get playlistNoMatchSearch => 'Ninguna lista coincide con tu búsqueda';

  @override
  String get playlistCreateNew => 'Crear nueva lista';

  @override
  String get playlistCreateFirstOne =>
      'No hay listas aún. ¡Crea una para empezar!';

  @override
  String playlistSongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
    );
    return '$_temp0';
  }

  @override
  String playlistRemovedTrack(String title, String playlist) {
    return '$title eliminada de $playlist';
  }

  @override
  String get playlistFailedToLoad => 'Error al cargar la lista de reproducción';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsPlugins => 'Complementos';

  @override
  String get settingsPluginsSubtitle =>
      'Instala, carga y gestiona complementos.';

  @override
  String get settingsUpdates => 'Actualizaciones';

  @override
  String get settingsUpdatesSubtitle => 'Buscar nuevas actualizaciones';

  @override
  String get settingsDownloads => 'Descargas';

  @override
  String get settingsDownloadsSubtitle => 'Ruta, calidad de descarga y más...';

  @override
  String get settingsLocalTracks => 'Pistas locales';

  @override
  String get settingsLocalTracksSubtitle =>
      'Escaneo, gestión de carpetas y auto-escaneo.';

  @override
  String get settingsPlayer => 'Ajustes de reproducción';

  @override
  String get settingsPlayerSubtitle => 'Calidad, reproducción automática, etc.';

  @override
  String get settingsPluginDefaults => 'Ajustes por defecto';

  @override
  String get settingsPluginDefaultsSubtitle =>
      'Fuente de descubrimiento y prioridades.';

  @override
  String get settingsUIElements => 'Interfaz y servicios';

  @override
  String get settingsUIElementsSubtitle =>
      'Ajustes visuales, servicios automáticos.';

  @override
  String get settingsLastFM => 'Ajustes de Last.FM';

  @override
  String get settingsLastFMSubtitle => 'Clave API, Secreto y scrobbling.';

  @override
  String get settingsStorage => 'Almacenamiento';

  @override
  String get settingsStorageSubtitle =>
      'Copia de seguridad, caché, historial...';

  @override
  String get settingsLanguageCountry => 'Idioma y país';

  @override
  String get settingsLanguageCountrySubtitle => 'Selecciona tu idioma y país.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutSubtitle =>
      'Información de la app, versión, desarrollador...';

  @override
  String get settingsScanning => 'Escaneando';

  @override
  String get settingsMusicFolders => 'Carpetas de música';

  @override
  String get settingsQuality => 'Calidad';

  @override
  String get settingsHistory => 'Historial';

  @override
  String get settingsBackupRestore => 'Copia y restauración';

  @override
  String get settingsAutomatic => 'Automático';

  @override
  String get settingsDangerZone => 'Zona de peligro';

  @override
  String get settingsScrobbling => 'Scrobbling';

  @override
  String get settingsAuthentication => 'Autenticación';

  @override
  String get settingsHomeScreen => 'Pantalla de inicio';

  @override
  String get settingsChartVisibility => 'Visibilidad de listas';

  @override
  String get settingsLocation => 'Ubicación';

  @override
  String get pluginRepositoryTitle => 'Repositorios de complementos';

  @override
  String get pluginRepositorySubtitle =>
      'Descubre complementos desde fuentes remotas';

  @override
  String get pluginRepositoryAddAction => 'Añadir repositorio';

  @override
  String get pluginRepositoryAddTitle => 'Añadir repositorio de complementos';

  @override
  String get pluginRepositoryAddSubtitle =>
      'Pega la URL del JSON del repositorio.';

  @override
  String get pluginRepositoryEmpty => 'No hay repositorios añadidos aún';

  @override
  String get pluginRepositoryUrlCopied =>
      'URL del repositorio copiada al portapapeles';

  @override
  String get pluginRepositoryNoDescription => 'Sin descripción disponible';

  @override
  String get pluginRepositoryUnknownUpdate => 'Desconocido';

  @override
  String pluginRepositoryPluginsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count complementos',
      one: '1 complemento',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryErrorLoad =>
      'Error al cargar repositorios. Revisa tu conexión.';

  @override
  String get pluginRepositoryErrorInvalid =>
      'URL o formato de repositorio inválido.';

  @override
  String get pluginRepositoryErrorRemove => 'Error al eliminar el repositorio.';

  @override
  String pluginRepositoryError(String message) {
    return 'Error: $message';
  }

  @override
  String get dialogAddingToDownloadQueue => 'Añadiendo a la cola de descarga';

  @override
  String get emptyNoInternet => '¡Sin conexión a Internet!';

  @override
  String get emptyNoContentPlugin =>
      'No hay complemento de contenido cargado. Carga uno en el Gestor.';

  @override
  String get emptyRefreshingSource => 'Refrescando fuente de Descubrimiento...';

  @override
  String get emptyNoTracks => 'No hay pistas disponibles';

  @override
  String get emptyNoResults => 'No se encontraron coincidencias';

  @override
  String snackbarDeletedTrack(String title) {
    return 'Eliminado \"$title\"';
  }

  @override
  String snackbarDeleteFailed(String title) {
    return 'Error al eliminar \"$title\"';
  }

  @override
  String get snackbarAddedToNextQueue => 'Añadido como siguiente en la cola';

  @override
  String get snackbarAddedToQueue => 'Añadido a la cola';

  @override
  String snackbarAddedToLiked(String title) {
    return '¡$title añadido a \'Me gusta\'!';
  }

  @override
  String snackbarNowPlaying(String name) {
    return 'Reproduciendo $name';
  }

  @override
  String snackbarPlaylistAddedToQueue(String name) {
    return 'Lista $name añadida a la cola';
  }

  @override
  String get snackbarPlaylistQueued => 'Lista añadida a la cola de descarga';

  @override
  String get snackbarPlaylistUpdated => '¡Lista actualizada!';

  @override
  String get snackbarNoInternet => 'Sin conexión a Internet.';

  @override
  String get snackbarImportFailed => '¡Error en la importación!';

  @override
  String get snackbarImportCompleted => 'Importación completada';

  @override
  String get snackbarBackupFailed => '¡Error en la copia de seguridad!';

  @override
  String snackbarExportedTo(String path) {
    return 'Exportado a: $path';
  }

  @override
  String get snackbarMediaIdCopied => 'ID de medios copiado';

  @override
  String get snackbarLinkCopied => 'Enlace copiado';

  @override
  String get snackbarNoLinkAvailable => 'No hay enlace disponible';

  @override
  String get snackbarCouldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String snackbarPreparingDownload(String title) {
    return 'Preparando descarga de $title...';
  }

  @override
  String snackbarAlreadyDownloaded(String title) {
    return '$title ya está descargado.';
  }

  @override
  String snackbarAlreadyInQueue(String title) {
    return '$title ya está en la cola.';
  }

  @override
  String snackbarDownloaded(String title) {
    return 'Descargado $title';
  }

  @override
  String get snackbarDownloadServiceUnavailable =>
      'Error: Servicio de descarga no disponible.';

  @override
  String snackbarSongsAddedToQueue(int count) {
    return 'Añadidas $count canciones a la cola';
  }

  @override
  String get snackbarDeleteTrackFailDevice =>
      'Error al eliminar la pista del almacenamiento.';

  @override
  String get searchHintExplore => '¿Qué quieres escuchar?';

  @override
  String get searchHintLibrary => 'Buscar en la biblioteca...';

  @override
  String get searchHintOfflineMusic => 'Buscar en tus canciones...';

  @override
  String get searchHintPlaylists => 'Buscar listas...';

  @override
  String get searchStartTyping => 'Empieza a escribir para buscar...';

  @override
  String get searchNoSuggestions => '¡No hay sugerencias!';

  @override
  String get searchNoResults =>
      '¡Sin resultados!\nPrueba con otra palabra clave.';

  @override
  String get searchFailed => '¡Error en la búsqueda!';

  @override
  String get searchDiscover => 'Descubre música increíble...';

  @override
  String get searchSources => 'FUENTES';

  @override
  String get searchNoPlugins => 'Sin complementos instalados';

  @override
  String get searchTracks => 'Pistas';

  @override
  String get searchAlbums => 'Álbumes';

  @override
  String get searchArtists => 'Artistas';

  @override
  String get searchPlaylists => 'Listas';

  @override
  String get exploreDiscover => 'Descubrir';

  @override
  String get exploreRecently => 'Recientes';

  @override
  String get exploreLastFmPicks => 'Elegidos de Last.Fm';

  @override
  String get exploreFailedToLoad => 'Error al cargar las secciones de inicio.';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryEmptyState =>
      'Tu biblioteca se siente sola. ¡Añade música!';

  @override
  String libraryIn(String playlistName) {
    return 'en $playlistName';
  }

  @override
  String get menuAddToPlaylist => 'Añadir a lista';

  @override
  String get menuSmartReplace => 'Reemplazo inteligente';

  @override
  String get menuShare => 'Compartir';

  @override
  String get menuAvailableOffline => 'Disponible sin conexión';

  @override
  String get menuDownload => 'Descargar';

  @override
  String get menuOpenOriginalLink => 'Abrir enlace original';

  @override
  String get menuDeleteTrack => 'Eliminar';

  @override
  String get songInfoTitle => 'Título';

  @override
  String get songInfoArtist => 'Artista';

  @override
  String get songInfoAlbum => 'Álbum';

  @override
  String get songInfoMediaId => 'ID de medios';

  @override
  String get songInfoCopyId => 'Copiar ID';

  @override
  String get songInfoCopyLink => 'Copiar enlace';

  @override
  String get songInfoOpenBrowser => 'Abrir en el navegador';

  @override
  String get tooltipRemoveFromLibrary => 'Eliminar de la biblioteca';

  @override
  String get tooltipSaveToLibrary => 'Guardar en la biblioteca';

  @override
  String get tooltipOpenOriginalLink => 'Abrir enlace original';

  @override
  String get tooltipShuffle => 'Aleatorio';

  @override
  String get tooltipAvailableOffline => 'Disponible sin conexión';

  @override
  String get tooltipDownloadPlaylist => 'Descargar lista';

  @override
  String get tooltipMoreOptions => 'Más opciones';

  @override
  String get tooltipInfo => 'Info';

  @override
  String get appuiTitle => 'Interfaz y servicios';

  @override
  String get appuiAutoSlideCharts => 'Carrusel automático';

  @override
  String get appuiAutoSlideChartsSubtitle =>
      'Desliza las listas automáticamente.';

  @override
  String get appuiLastFmPicksSubtitle =>
      'Muestra sugerencias de Last.FM. Requiere reinicio.';

  @override
  String get appuiNoChartsAvailable =>
      'No hay listas disponibles. Carga un complemento.';

  @override
  String get appuiLoginToLastFm =>
      'Por favor, inicia sesión en Last.FM primero.';

  @override
  String get appuiShowInCarousel => 'Mostrar en carrusel de inicio.';

  @override
  String get countrySettingTitle => 'País e idioma';

  @override
  String get countrySettingAutoDetect => 'Auto-detectar país';

  @override
  String get countrySettingAutoDetectSubtitle =>
      'Detectar país automáticamente al iniciar.';

  @override
  String get countrySettingCountryLabel => 'País';

  @override
  String get countrySettingLanguageLabel => 'Idioma';

  @override
  String get countrySettingSystemDefault => 'Por defecto del sistema';

  @override
  String get downloadSettingTitle => 'Descargas';

  @override
  String get downloadSettingQuality => 'Calidad de descarga';

  @override
  String get downloadSettingQualitySubtitle =>
      'Bitrate preferido para pistas descargadas.';

  @override
  String get downloadSettingFolder => 'Carpeta de descarga';

  @override
  String get downloadSettingResetFolder => 'Resetear carpeta de descarga';

  @override
  String get downloadSettingResetFolderSubtitle =>
      'Restaurar la ruta por defecto.';

  @override
  String get lastfmTitle => 'Last.FM';

  @override
  String get lastfmScrobbleTracks => 'Scrobble de pistas';

  @override
  String get lastfmScrobbleTracksSubtitle =>
      'Enviar pistas reproducidas a tu perfil.';

  @override
  String get lastfmAuthFirst => 'Primero autentica la API de Last.FM.';

  @override
  String get lastfmAuthenticatedAs => 'Autenticado como';

  @override
  String get lastfmAuthFailed => 'Error de autenticación:';

  @override
  String get lastfmNotAuthenticated => 'No autenticado';

  @override
  String get lastfmSteps =>
      'Pasos:\n1. Crea una cuenta en Last.FM\n2. Genera una clave API\n3. Introduce la clave y el secreto abajo\n4. Pulsa \'Iniciar autenticación\' y aprueba\n5. Guarda la clave de sesión';

  @override
  String get lastfmApiKey => 'Clave API';

  @override
  String get lastfmApiSecret => 'Secreto API';

  @override
  String get lastfmStartAuth => '1. Iniciar autenticación';

  @override
  String get lastfmGetSession => '2. Guardar clave de sesión';

  @override
  String get lastfmRemoveKeys => 'Eliminar claves';

  @override
  String get lastfmStartAuthFirst => 'Inicia la autenticación primero.';

  @override
  String get localSettingTitle => 'Pistas locales';

  @override
  String get localSettingAutoScan => 'Escanear al inicio';

  @override
  String get localSettingAutoScanSubtitle =>
      'Buscar música nueva automáticamente.';

  @override
  String get localSettingLastScan => 'Último escaneo';

  @override
  String get localSettingNeverScanned => 'Nunca';

  @override
  String get localSettingScanInProgress => 'Escaneando...';

  @override
  String get localSettingScanNowSubtitle =>
      'Lanzar escaneo completo manualmente.';

  @override
  String get localSettingNoFolders =>
      'Sin carpetas añadidas. Añade una para empezar.';

  @override
  String get localSettingAddFolder => 'Añadir carpeta';

  @override
  String get playerSettingTitle => 'Ajustes del reproductor';

  @override
  String get playerSettingStreamingHeader => 'Streaming';

  @override
  String get playerSettingStreamQuality => 'Calidad de streaming';

  @override
  String get playerSettingStreamQualitySubtitle =>
      'Bitrate global para reproducción online.';

  @override
  String get playerSettingQualityLow => 'Baja';

  @override
  String get playerSettingQualityMedium => 'Media';

  @override
  String get playerSettingQualityHigh => 'Alta';

  @override
  String get playerSettingPlaybackHeader => 'Reproducción';

  @override
  String get playerSettingAutoPlay => 'Reproducción automática';

  @override
  String get playerSettingAutoPlaySubtitle =>
      'Añadir canciones similares al final.';

  @override
  String get playerSettingAutoFallback => 'Alternativa automática';

  @override
  String get playerSettingAutoFallbackSubtitle =>
      'Si falta un flujo, intentar con otro.';

  @override
  String get playerSettingCrossfade => 'Crossfade';

  @override
  String get playerSettingCrossfadeOff => 'Apagado';

  @override
  String get playerSettingCrossfadeInstant => 'Transición instantánea';

  @override
  String playerSettingCrossfadeBlend(int seconds) {
    return 'Fundido de ${seconds}s';
  }

  @override
  String get playerSettingEqualizer => 'Ecualizador';

  @override
  String get playerSettingEqualizerActive => 'Activo';

  @override
  String playerSettingEqualizerActivePreset(String preset) {
    return 'Habilitado — preset $preset';
  }

  @override
  String get playerSettingEqualizerSubtitle =>
      'Ecualizador de 10 bandas vía FFmpeg.';

  @override
  String get pluginDefaultsTitle => 'Ajustes por defecto';

  @override
  String get pluginDefaultsDiscoverHeader => 'Fuente de descubrimiento';

  @override
  String get pluginDefaultsNoResolver =>
      'Carga un complemento para elegir fuente.';

  @override
  String get pluginDefaultsAutomaticSubtitle => 'Usar el primer cargado.';

  @override
  String get pluginDefaultsPriorityHeader => 'Prioridad de resolución';

  @override
  String get pluginDefaultsNoPriority =>
      'No hay resolutores. Aparecerán aquí al cargar.';

  @override
  String get pluginDefaultsPriorityDesc =>
      'Arrastra para reordenar. Los primeros se intentan antes.';

  @override
  String get pluginDefaultsLyricsHeader => 'Prioridad de letras';

  @override
  String get pluginDefaultsLyricsNone => 'Sin proveedores de letras.';

  @override
  String get pluginDefaultsLyricsDesc => 'Orden de búsqueda de letras.';

  @override
  String get pluginDefaultsSuggestionsHeader => 'Sugerencias de búsqueda';

  @override
  String get pluginDefaultsSuggestionsNone => 'Sin proveedores de sugerencias.';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlyTitle => 'Ninguno';

  @override
  String get pluginDefaultsSuggestionsHistoryOnlySubtitle => 'Solo historial.';

  @override
  String get storageSettingTitle => 'Almacenamiento';

  @override
  String get storageClearHistoryEvery => 'Limpiar historial cada';

  @override
  String get storageClearHistorySubtitle => 'Borrar historial automáticamente.';

  @override
  String storageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get storageBackupLocation => 'Ubicación de copia';

  @override
  String get storageBackupLocationAndroid => 'Descargas / Directorio de la app';

  @override
  String get storageBackupLocationDownloads => 'Directorio de descargas';

  @override
  String get storageCreateBackup => 'Crear copia de seguridad';

  @override
  String get storageCreateBackupSubtitle =>
      'Guardar ajustes y datos en un archivo.';

  @override
  String storageBackupCreatedAt(String path) {
    return 'Copia creada en $path';
  }

  @override
  String storageBackupShareFailed(String error) {
    return 'Error al compartir copia: $error';
  }

  @override
  String get storageBackupFailed => 'Error de copia de seguridad';

  @override
  String get storageRestoreBackup => 'Restaurar copia';

  @override
  String get storageRestoreBackupSubtitle =>
      'Restaurar datos desde un archivo.';

  @override
  String get storageAutoBackup => 'Copia automática';

  @override
  String get storageAutoBackupSubtitle => 'Copia periódica automática.';

  @override
  String get storageAutoLyrics => 'Guardar letras automáticamente';

  @override
  String get storageAutoLyricsSubtitle => 'Guardar letras al reproducir.';

  @override
  String get storageResetApp => 'Resetear Beats';

  @override
  String get storageResetAppSubtitle => 'Borrar todo y volver a fábrica.';

  @override
  String get storageResetConfirmTitle => 'Confirmar reseteo';

  @override
  String get storageResetConfirmMessage =>
      '¿Seguro? Esto borrará todo permanentemente.';

  @override
  String get storageResetButton => 'Resetear';

  @override
  String get storageResetSuccess =>
      'La aplicación ha vuelto a su estado original.';

  @override
  String get storageLocationDialogTitle => 'Ubicación de copia';

  @override
  String get storageLocationAndroid =>
      'Las copias están en:\n\n1. Descargas\n2. Android/data/ls.Beats.musicplayer/data';

  @override
  String get storageLocationOther => 'Las copias están en Descargas.';

  @override
  String get storageRestoreOptionsTitle => 'Opciones de restauración';

  @override
  String get storageRestoreOptionsDesc =>
      'Elige qué restaurar. Todo está seleccionado por defecto.';

  @override
  String get storageRestoreSelectAll => 'Seleccionar todo';

  @override
  String get storageRestoreMediaItems => 'Medios (canciones, biblioteca)';

  @override
  String get storageRestoreSearchHistory => 'Historial de búsqueda';

  @override
  String get storageRestoreContinue => 'Continuar';

  @override
  String get storageRestoreNoFile => 'Sin archivo seleccionado.';

  @override
  String get storageRestoreSaveFailed => 'Error al guardar el archivo.';

  @override
  String get storageRestoreConfirmTitle => 'Confirmar restauración';

  @override
  String get storageRestoreConfirmPrefix =>
      'Se sobrescribirá con los datos del archivo:';

  @override
  String get storageRestoreConfirmSuffix => '¿Seguro que quieres continuar?';

  @override
  String get storageRestoreYes => 'Sí, restaurar';

  @override
  String get storageRestoreNo => 'No';

  @override
  String get storageRestoring => 'Restaurando... espera un momento.';

  @override
  String get storageRestoreMediaBullet => '• Medios';

  @override
  String get storageRestoreHistoryBullet => '• Historial';

  @override
  String get storageUnexpectedError => 'Error inesperado al restaurar.';

  @override
  String get storageRestoreCompleted => 'Restauración completada';

  @override
  String get storageRestoreFailedTitle => 'Error al restaurar';

  @override
  String get storageRestoreSuccessMessage =>
      'Datos restaurados. Reinicia la app ahora.';

  @override
  String get storageRestoreFailedMessage => 'Errores durante el proceso:';

  @override
  String get storageRestoreUnknownError => 'Error desconocido.';

  @override
  String get storageRestoreRestartHint =>
      'Reinicia la app para ver los cambios.';

  @override
  String get updateSettingTitle => 'Actualizaciones';

  @override
  String get updateAppUpdatesHeader => 'App';

  @override
  String get updateCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get updateCheckSubtitle => 'Ver si hay una nueva versión.';

  @override
  String get updateAutoNotify => 'Notificar automáticamente';

  @override
  String get updateAutoNotifySubtitle =>
      'Avisar al abrir si hay una nueva versión.';

  @override
  String get updateCheckTitle => 'Buscando';

  @override
  String get updateUpToDate => '¡Beats🌸 está actualizado!';

  @override
  String get updateViewPreRelease => 'Ver última Pre-Release';

  @override
  String updateCurrentVersion(String curr, String build) {
    return 'Versión actual: $curr + $build';
  }

  @override
  String get updateNewVersionAvailable => '¡Nueva versión disponible!';

  @override
  String updateVersion(String ver, String build) {
    return 'Versión: $ver+$build';
  }

  @override
  String get updateDownloadNow => 'Descargar ahora';

  @override
  String get updateChecking => 'Buscando nuevas versiones...';

  @override
  String get timerTitle => 'Temporizador';

  @override
  String get timerInterludeMessage => 'Preparando el silencio en...';

  @override
  String get timerHours => 'Horas';

  @override
  String get timerMinutes => 'Minutos';

  @override
  String get timerSeconds => 'Segundos';

  @override
  String get timerStop => 'Parar';

  @override
  String get timerFinishedMessage =>
      'Las canciones han descansado. ¡Dulces sueños! 🥰';

  @override
  String get timerGotIt => '¡Entendido!';

  @override
  String get timerSetTimeError => 'Pon un tiempo';

  @override
  String get timerStart => 'Empezar';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsEmpty => 'Sin notificaciones';

  @override
  String get recentsTitle => 'Historial';

  @override
  String playlistByCreator(String creator) {
    return 'por $creator';
  }

  @override
  String get playlistTypeAlbum => 'Álbum';

  @override
  String get playlistTypePlaylist => 'Lista';

  @override
  String get playlistYou => 'Tú';

  @override
  String get pluginManagerTitle => 'Complementos';

  @override
  String get pluginManagerEmpty =>
      'Sin complementos.\nPulsa + para añadir uno.';

  @override
  String get pluginManagerFilterAll => 'Todos';

  @override
  String get pluginManagerFilterContent => 'Contenido';

  @override
  String get pluginManagerFilterCharts => 'Listas de éxitos';

  @override
  String get pluginManagerFilterLyrics => 'Letras';

  @override
  String get pluginManagerFilterSuggestions => 'Sugerencias';

  @override
  String get pluginManagerFilterImporters => 'Importadores';

  @override
  String get pluginManagerTooltipRefresh => 'Refrescar';

  @override
  String get pluginManagerTooltipInstall => 'Instalar';

  @override
  String get pluginManagerNoMatch => 'Sin coincidencias';

  @override
  String pluginManagerPickFailed(String error) {
    return 'Error al elegir: $error';
  }

  @override
  String get pluginManagerInstalling => 'Instalando...';

  @override
  String get pluginManagerTypeContentResolver => 'Resolutor';

  @override
  String get pluginManagerTypeChartProvider => 'Éxitos';

  @override
  String get pluginManagerTypeLyricsProvider => 'Letras';

  @override
  String get pluginManagerTypeSuggestionProvider => 'Sugerencias';

  @override
  String get pluginManagerTypeContentImporter => 'Importador';

  @override
  String get pluginManagerDeleteTitle => '¿Eliminar?';

  @override
  String pluginManagerDeleteMessage(String name) {
    return '¿Seguro que quieres borrar \"$name\"?';
  }

  @override
  String get pluginManagerDeleteAction => 'Borrar';

  @override
  String get pluginManagerCancel => 'Cancelar';

  @override
  String get pluginManagerEnablePlugin => 'Activar';

  @override
  String get pluginManagerUnloadPlugin => 'Desactivar';

  @override
  String get pluginManagerDeleting => 'Borrando...';

  @override
  String get pluginManagerApiKeysTitle => 'Claves API';

  @override
  String get pluginManagerApiKeysSaved => 'Claves guardadas';

  @override
  String get pluginManagerSave => 'Guardar';

  @override
  String get pluginManagerDetailVersion => 'Versión';

  @override
  String get pluginManagerDetailType => 'Tipo';

  @override
  String get pluginManagerDetailPublisher => 'Editor';

  @override
  String get pluginManagerDetailLastUpdated => 'Actualizado';

  @override
  String get pluginManagerDetailCreated => 'Creado';

  @override
  String get pluginManagerDetailHomepage => 'Web';

  @override
  String get pluginManagerDowngradeTitle => '¿Bajar versión?';

  @override
  String pluginManagerDowngradeMessage(String name) {
    return 'Estás instalando una versión igual o anterior.';
  }

  @override
  String get pluginManagerDowngradeAction => 'Instalar de todos modos';

  @override
  String get pluginManagerDeleteStorageTitle => '¿Borrar datos?';

  @override
  String pluginManagerDeleteStorageMessage(String name) {
    return '¿Borrar también claves API y ajustes?';
  }

  @override
  String get pluginManagerDeleteStorageKeep => 'Mantener';

  @override
  String get pluginManagerDeleteStorageRemove => 'Borrar';

  @override
  String get segmentsSheetTitle => 'Segmentos';

  @override
  String get segmentsSheetEmpty => 'Sin segmentos';

  @override
  String get segmentsSheetUntitled => 'Segmento sin título';

  @override
  String get smartReplaceTitle => 'Reemplazo inteligente';

  @override
  String smartReplaceSubtitle(String title) {
    return 'Elige un reemplazo para \"$title\".';
  }

  @override
  String get smartReplaceClose => 'Cerrar';

  @override
  String get smartReplaceNoMatch => 'Sin reemplazo hallado';

  @override
  String get smartReplaceNoMatchSubtitle => 'Sin resultados satisfactorios.';

  @override
  String get smartReplaceBestMatch => 'Mejor opción';

  @override
  String get smartReplaceSearchFailed => 'Error en búsqueda';

  @override
  String smartReplaceApplyFailed(String error) {
    return 'Error al aplicar: $error';
  }

  @override
  String smartReplaceApplied(String queue) {
    return 'Reemplazo aplicado$queue.';
  }

  @override
  String smartReplaceAppliedPlaylists(int count, String plural, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listas',
      one: '1 lista',
    );
    return 'Reemplazado en $_temp0$queue.';
  }

  @override
  String get smartReplaceQueueUpdated => ' y cola actualizada';

  @override
  String get playerUnknownQueue => 'Desconocido';

  @override
  String playerLiked(String title) {
    return '¡Me gusta $title!';
  }

  @override
  String playerUnliked(String title) {
    return '¡Ya no me gusta $title!';
  }

  @override
  String get offlineNoDownloads => 'Sin descargas';

  @override
  String get offlineTitle => 'Offline';

  @override
  String get offlineSearchHint => 'Buscar canciones...';

  @override
  String get offlineRefreshTooltip => 'Refrescar';

  @override
  String get offlineCloseSearch => 'Cerrar';

  @override
  String get offlineSearchTooltip => 'Buscar';

  @override
  String get offlineOpenFailed => 'Error al abrir la pista offline.';

  @override
  String get offlinePlayFailed => 'Error al reproducir la canción offline.';

  @override
  String albumViewTrackCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pistas',
      one: '1 pista',
    );
    return '$_temp0';
  }

  @override
  String get albumViewLoadFailed => 'Error al cargar álbum';

  @override
  String get aboutCraftingSubtitle => 'Sinfonías en código.';

  @override
  String get aboutFollowGitHub => 'Seguir en GitHub';

  @override
  String get aboutSendInquiry => 'Contacto comercial';

  @override
  String get aboutCreativeHighlights => 'Novedades y creatividad';

  @override
  String get aboutTipQuote =>
      '¿Te gusta Beats? Una propina ayuda al proyecto. 🌸';

  @override
  String get aboutTipButton => 'Quiero ayudar';

  @override
  String get aboutTipDesc => 'Para que Beats siga mejorando.';

  @override
  String get aboutGitHub => 'GitHub';

  @override
  String get songInfoSectionDetails => 'Detalles';

  @override
  String get songInfoSectionTechnical => 'Técnico';

  @override
  String get songInfoSectionActions => 'Acciones';

  @override
  String get songInfoLabelTitle => 'Título';

  @override
  String get songInfoLabelArtist => 'Artista';

  @override
  String get songInfoLabelAlbum => 'Álbum';

  @override
  String get songInfoLabelDuration => 'Duración';

  @override
  String get songInfoLabelSource => 'Fuente';

  @override
  String get songInfoLabelMediaId => 'Media ID';

  @override
  String get songInfoLabelPluginId => 'Plugin ID';

  @override
  String get songInfoIdCopied => 'ID copiado';

  @override
  String get songInfoLinkCopied => 'Enlace copiado';

  @override
  String get songInfoNoLink => 'Sin enlace';

  @override
  String get songInfoOpenFailed => 'Error al abrir enlace';

  @override
  String get songInfoUpdateMetadata => 'Refrescar datos';

  @override
  String get songInfoMetadataUpdated => 'Datos actualizados';

  @override
  String get songInfoMetadataUpdateFailed => 'Error al actualizar';

  @override
  String get songInfoMetadataUnavailable => 'Meta-datos no disponibles';

  @override
  String get songInfoSearchTitle => 'Buscar título en Beats';

  @override
  String get songInfoSearchArtist => 'Buscar artista en Beats';

  @override
  String get songInfoSearchAlbum => 'Buscar álbum en Beats';

  @override
  String get eqTitle => 'Ecualizador';

  @override
  String get eqResetTooltip => 'Resetear';

  @override
  String get chartNoItems => 'Lista vacía';

  @override
  String get chartLoadFailed => 'Error al cargar lista';

  @override
  String get chartPlay => 'Reproducir';

  @override
  String get chartResolving => 'Resolviendo';

  @override
  String get chartReady => 'Listo';

  @override
  String get chartAddToPlaylist => 'Añadir a lista';

  @override
  String get chartNoResolver => 'Sin resolutor cargado.';

  @override
  String get chartResolveFailed => 'Error al resolver. Buscando...';

  @override
  String get chartNoResolverAdd => 'Sin resolutor.';

  @override
  String get chartNoMatch => 'Sin coincidencias. Busca manualmente.';

  @override
  String get chartStatPeak => 'Pico';

  @override
  String get chartStatWeeks => 'Semanas';

  @override
  String get chartStatChange => 'Cambio';

  @override
  String menuSharePreparing(String title) {
    return 'Preparando $title para compartir.';
  }

  @override
  String get menuOpenLinkFailed => 'Error al abrir enlace';

  @override
  String get localMusicFolders => 'Carpetas';

  @override
  String get localMusicCloseSearch => 'Cerrar';

  @override
  String get localMusicOpenSearch => 'Buscar';

  @override
  String get localMusicNoMusicFound => 'Sin música local';

  @override
  String get localMusicNoSearchResults => 'Sin resultados';

  @override
  String get importSongsTitle => 'Importar canciones';

  @override
  String get importNoPluginsLoaded => 'Pin un complemento importador.';

  @override
  String get importBeatsFiles => 'Archivos Beats';

  @override
  String get importM3UFiles => 'Lista M3U';

  @override
  String get importM3UNameDialogTitle => 'Nombre de la lista';

  @override
  String get importM3UNameHint => 'Pon un nombre a la lista';

  @override
  String get importM3UNoTracks => 'Sin pistas válidas en M3U.';

  @override
  String get importNoteTitle => 'Aviso';

  @override
  String get importNoteMessage =>
      'Solo archivos de Beats funcionan correctamente.';

  @override
  String get importTitle => 'Importar';

  @override
  String get importCheckingUrl => 'Verificando URL...';

  @override
  String get importFetchingTracks => 'Buscando pistas...';

  @override
  String get importSavingToLibrary => 'Guardando...';

  @override
  String get importPasteUrlHint => 'Pega URL de lista o álbum';

  @override
  String get importAction => 'Importar';

  @override
  String importTrackCount(int count) {
    return '$count pistas';
  }

  @override
  String get importResolving => 'Resolviendo...';

  @override
  String importResolvingProgress(int done, int total) {
    return 'Resolviendo: $done / $total';
  }

  @override
  String get importReviewTitle => 'Resumen';

  @override
  String importReviewSummary(int resolved, int failed, int total) {
    return '$resolved resueltas, $failed fallidas de $total';
  }

  @override
  String importSaveTracks(int count) {
    return 'Guardar $count pistas';
  }

  @override
  String importTracksSaved(int count) {
    return '¡$count pistas guardadas!';
  }

  @override
  String get importDone => 'Hecho';

  @override
  String get importMore => 'Importar más';

  @override
  String get importUnknownError => 'Error desconocido';

  @override
  String get importTryAgain => 'Reintentar';

  @override
  String get importSkipTrack => 'Saltar';

  @override
  String get importMatchOptions => 'Opciones';

  @override
  String get importAutoMatched => 'Auto';

  @override
  String get importUserSelected => 'Manual';

  @override
  String get importSkipped => 'Saltado';

  @override
  String get importNoMatch => 'Sin coincidencia';

  @override
  String get importReorderTip => 'Mantén pulsado para mover';

  @override
  String get importErrorCannotHandleUrl => 'URL no soportada.';

  @override
  String get importErrorUnexpectedResponse => 'Respuesta inesperada.';

  @override
  String importErrorFailedToCheck(String error) {
    return 'Error al verificar: $error';
  }

  @override
  String importErrorFailedToFetchInfo(String error) {
    return 'Error al traer info: $error';
  }

  @override
  String importErrorFailedToFetchTracks(String error) {
    return 'Error al traer canciones: $error';
  }

  @override
  String importErrorFailedToSave(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get playlistPinToTop => 'Fijar arriba';

  @override
  String get playlistUnpin => 'Quitar fijado';

  @override
  String get snackbarImportingMedia => 'Importando...';

  @override
  String get snackbarPlaylistSaved => '¡Lista guardada!';

  @override
  String get snackbarInvalidFileFormat => 'Formato inválido';

  @override
  String get snackbarMediaItemImported => 'Medio importado';

  @override
  String get snackbarPlaylistImported => 'Lista importada';

  @override
  String get snackbarOpenImportForUrl => 'Abre Importar para continuar.';

  @override
  String get snackbarProcessingFile => 'Procesando...';

  @override
  String snackbarPreparingShare(String title) {
    return 'Preparando $title...';
  }

  @override
  String snackbarPreparingExport(String title) {
    return 'Preparando exportación de $title...';
  }

  @override
  String get pluginManagerTabInstalled => 'Instalados';

  @override
  String get pluginManagerTabStore => 'Tienda';

  @override
  String get pluginManagerSelectPackage => 'Selecciona .bex';

  @override
  String get pluginManagerOutdatedManifest =>
      'Manifiesto antiguo. Riesgo de errores.';

  @override
  String get pluginManagerStatusActive => 'Activo';

  @override
  String get pluginManagerStatusInactive => 'Inactivo';

  @override
  String pluginRepositoryUpdatedOn(String date) {
    return 'Actualizado $date';
  }

  @override
  String pluginRepositoryAvailableCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count disponibles',
      one: '1 disponible',
    );
    return '$_temp0';
  }

  @override
  String get pluginRepositoryOutdatedManifest => 'Manifiesto obsoleto.';

  @override
  String get pluginRepositoryUnknownPublisher => 'Editor desconocido';

  @override
  String get pluginRepositoryActionRetry => 'Reintentar';

  @override
  String get pluginRepositoryActionOutdated => 'Obsolesto';

  @override
  String get pluginRepositoryActionInstalled => 'Instalado';

  @override
  String get pluginRepositoryActionInstall => 'Instalar';

  @override
  String get pluginRepositoryActionUnavailable => 'No disponible';

  @override
  String get pluginRepositoryInstallFailed => 'Error de instalación.';

  @override
  String pluginRepositoryDownloadFailed(String name) {
    return 'Error al descargar $name.';
  }

  @override
  String smartReplaceAppliedPlaylistsSummary(int count, String queue) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reemplazado en $count listas$queue.',
      one: 'Reemplazado en 1 lista$queue.',
    );
    return '$_temp0';
  }

  @override
  String get lyricsSearchFieldLabel => 'Buscar letras...';

  @override
  String get lyricsSearchEmptyPrompt => 'Busca por canción o artista.';

  @override
  String lyricsSearchNoResults(String query) {
    return 'Sin letras para \"$query\"';
  }

  @override
  String get lyricsSearchApplied => 'Letras aplicadas';

  @override
  String get lyricsSearchFetchFailed => 'Error al traer letras';

  @override
  String get lyricsSearchPreview => 'Vista previa';

  @override
  String get lyricsSearchPreviewTooltip => 'Ver letras';

  @override
  String get lyricsSearchSynced => 'SINCRONIZADO';

  @override
  String get lyricsSearchPreviewLoadFailed => 'Error al cargar vista.';

  @override
  String get lyricsSearchApplyAction => 'Aplicar letras';

  @override
  String get lyricsSettingsSearchTitle => 'Búsqueda personalizada';

  @override
  String get lyricsSettingsSearchSubtitle => 'Busca otras versiones';

  @override
  String get lyricsSettingsSyncTitle => 'Ajustar sincronización';

  @override
  String get lyricsSettingsSyncSubtitle => 'Arregla retrasos';

  @override
  String get lyricsSettingsSaveTitle => 'Guardar';

  @override
  String get lyricsSettingsSaveSubtitle => 'Guardar en el dispositivo';

  @override
  String get lyricsSettingsDeleteTitle => 'Borrar guardadas';

  @override
  String get lyricsSettingsDeleteSubtitle => 'Eliminar letras offline';

  @override
  String get lyricsSyncTapToReset => 'Pulsa para resetear';

  @override
  String get upNextTitle => 'Siguiente';

  @override
  String upNextItemsInQueue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos en cola',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get upNextAutoPlay => 'Auto';

  @override
  String get tooltipCopyToClipboard => 'Copiar';

  @override
  String get snackbarCopiedToClipboard => 'Copiado al portapapeles';

  @override
  String get tooltipSongInfo => 'Información';

  @override
  String get snackbarCannotDeletePlayingSong => 'No puedes borrar lo que suena';

  @override
  String get playerLoopOff => 'Apagado';

  @override
  String get playerLoopOne => 'Una';

  @override
  String get playerLoopAll => 'Todo';

  @override
  String get snackbarOpeningAlbumPage => 'Abriendo página del álbum.';

  @override
  String updateAvailableBody(String ver, String build) {
    return '¡Nueva versión de Beats🌸!\n\nVersión: $ver+$build';
  }

  @override
  String pluginSnackbarInstalled(String id) {
    return '¡Complemento \"$id\" instalado!';
  }

  @override
  String pluginSnackbarLoaded(String id) {
    return 'Complemento \"$id\" cargado';
  }

  @override
  String pluginSnackbarDeleted(String id) {
    return 'Complemento \"$id\" borrado';
  }

  @override
  String get pluginBootstrapTitle => 'Preparando Beats';

  @override
  String pluginBootstrapProgress(int percent) {
    return 'Motor de complementos... $percent%';
  }

  @override
  String get pluginBootstrapHint => 'Solo la primera vez.';

  @override
  String get pluginBootstrapErrorTitle => 'Conexión lenta';

  @override
  String get pluginBootstrapErrorBody =>
      'Algunos fallaron. Reintentaremos luego.';

  @override
  String get pluginBootstrapContinue => 'Continuar';
}
