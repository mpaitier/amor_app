// ============================================================================
// DEPENDENCY INJECTION CONTAINER
// ============================================================================
// Manual composition root: wires data sources, repositories and use cases
// for every feature. Exposed as a single top-level instance `sl`
// (service locator), read by screens/widgets when creating their ViewModels.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import 'core/session/current_couple.dart';

// --- Auth feature ---
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/watch_auth_state.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/register_with_email.dart';
import 'features/auth/domain/usecases/send_password_reset.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/delete_account.dart';

// --- Couple feature ---
import 'features/couple/data/datasources/couple_remote_datasource.dart';
import 'features/couple/data/repositories/couple_repository_impl.dart';
import 'features/couple/domain/repositories/couple_repository.dart';
import 'features/couple/domain/usecases/watch_current_couple.dart';
import 'features/couple/domain/usecases/create_couple.dart';
import 'features/couple/domain/usecases/join_couple.dart';
import 'features/couple/domain/usecases/update_member_profile.dart';
import 'features/couple/domain/usecases/request_couple_end.dart';
import 'features/couple/domain/usecases/respond_to_couple_end.dart';
import 'features/couple/domain/usecases/cancel_couple_end.dart';

// --- Timeline feature ---
import 'features/timeline/data/datasources/timeline_remote_datasource.dart';
import 'features/timeline/data/datasources/image_local_datasource.dart';
import 'features/timeline/data/datasources/image_remote_datasource.dart';
import 'features/timeline/data/repositories/timeline_repository_impl.dart';
import 'features/timeline/data/repositories/image_repository_impl.dart';
import 'features/timeline/domain/repositories/timeline_repository.dart';
import 'features/timeline/domain/repositories/image_repository.dart';
import 'features/timeline/domain/usecases/watch_timeline_events.dart';
import 'features/timeline/domain/usecases/add_timeline_event.dart';
import 'features/timeline/domain/usecases/update_timeline_event.dart';
import 'features/timeline/domain/usecases/delete_timeline_event.dart';
import 'features/timeline/domain/usecases/pick_images_from_gallery.dart';
import 'features/timeline/domain/usecases/take_photo.dart';
import 'features/timeline/domain/usecases/upload_images.dart';

// --- Place feature ---
import 'features/place/data/datasources/place_remote_datasource.dart';
import 'features/place/data/repositories/place_repository_impl.dart';
import 'features/place/domain/repositories/place_repository.dart';
import 'features/place/domain/usecases/search_places.dart';

// --- Gif feature ---
import 'features/gif/data/datasources/gif_remote_datasource.dart';
import 'features/gif/data/repositories/gif_repository_impl.dart';
import 'features/gif/domain/repositories/gif_repository.dart';
import 'features/gif/domain/usecases/get_random_gif.dart';

// --- Notifications feature ---
import 'features/notifications/data/datasources/device_identity_datasource.dart';
import 'features/notifications/data/datasources/push_notification_datasource.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/data/datasources/local_notification_datasource.dart';
import 'features/notifications/domain/usecases/initialize_notifications.dart';
import 'features/notifications/domain/usecases/get_device_id.dart';
import 'features/notifications/domain/usecases/register_device_token.dart';
import 'features/notifications/domain/usecases/unregister_device_token.dart';
import 'features/notifications/data/datasources/notification_preferences_remote_datasource.dart';
import 'features/notifications/data/repositories/notification_preferences_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_preferences_repository.dart';
import 'features/notifications/domain/usecases/watch_notification_preferences.dart';
import 'features/notifications/domain/usecases/save_notification_preferences.dart';

// --- Calendar feature ---
import 'features/calendar/domain/usecases/group_events_by_day.dart';
import 'features/calendar/domain/usecases/build_special_days.dart';

// --- Important dates feature ---
import 'features/important_dates/data/datasources/important_date_remote_datasource.dart';
import 'features/important_dates/data/repositories/important_date_repository_impl.dart';
import 'features/important_dates/domain/repositories/important_date_repository.dart';
import 'features/important_dates/domain/usecases/watch_important_dates.dart';
import 'features/important_dates/domain/usecases/add_important_date.dart';
import 'features/important_dates/domain/usecases/update_important_date.dart';
import 'features/important_dates/domain/usecases/delete_important_date.dart';

// --- Settings feature ---
import 'features/settings/data/datasources/couple_settings_remote_datasource.dart';
import 'features/settings/data/repositories/couple_settings_repository_impl.dart';
import 'features/settings/domain/repositories/couple_settings_repository.dart';
import 'features/settings/domain/usecases/watch_couple_settings.dart';
import 'features/settings/domain/usecases/save_couple_settings.dart';
import 'features/settings/domain/usecases/get_gif_search_term.dart';

// --- Color history feature ---
import 'features/color_history/data/datasources/color_history_local_datasource.dart';
import 'features/color_history/data/repositories/color_history_repository_impl.dart';
import 'features/color_history/domain/repositories/color_history_repository.dart';
import 'features/color_history/domain/usecases/get_recent_colors.dart';
import 'features/color_history/domain/usecases/add_recent_color.dart';
import 'features/color_history/domain/usecases/remove_recent_color.dart';

// --- Service locator singleton ---
class ServiceLocator {
  ServiceLocator._internal();
  static final ServiceLocator instance = ServiceLocator._internal();

  // --- External packages ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final http.Client _httpClient = http.Client();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // --- Relation active, lue par les data sources rangées sous
  // --- couples/{coupleId}/ ---
  final CurrentCouple currentCouple = CurrentCouple();

  // --- Auth: data source, repository, use cases ---
  late final AuthRemoteDataSource authRemoteDataSource = AuthRemoteDataSource(
    auth: _auth,
    googleSignIn: _googleSignIn,
    functions: _functions,
  );
  late final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );
  late final WatchAuthState watchAuthState = WatchAuthState(authRepository);
  late final SignInWithGoogle signInWithGoogle =
      SignInWithGoogle(authRepository);
  late final SignInWithEmail signInWithEmail = SignInWithEmail(authRepository);
  late final RegisterWithEmail registerWithEmail =
      RegisterWithEmail(authRepository);
  late final SendPasswordReset sendPasswordReset =
      SendPasswordReset(authRepository);
  late final SignOut signOut = SignOut(authRepository);
  late final DeleteAccount deleteAccount = DeleteAccount(authRepository);

  // --- Couple: data source, repository, use cases ---
  late final CoupleRemoteDataSource coupleRemoteDataSource =
      CoupleRemoteDataSource(firestore: _firestore, functions: _functions);
  late final CoupleRepository coupleRepository = CoupleRepositoryImpl(
    remoteDataSource: coupleRemoteDataSource,
  );
  late final WatchCurrentCouple watchCurrentCouple =
      WatchCurrentCouple(coupleRepository);
  late final CreateCouple createCouple = CreateCouple(coupleRepository);
  late final JoinCouple joinCouple = JoinCouple(coupleRepository);
  late final UpdateMemberProfile updateMemberProfile =
      UpdateMemberProfile(coupleRepository);
  late final RequestCoupleEnd requestCoupleEnd =
      RequestCoupleEnd(coupleRepository);
  late final RespondToCoupleEnd respondToCoupleEnd =
      RespondToCoupleEnd(coupleRepository);
  late final CancelCoupleEnd cancelCoupleEnd = CancelCoupleEnd(coupleRepository);

  // --- Timeline: data sources ---
  late final TimelineRemoteDataSource timelineRemoteDataSource =
      TimelineRemoteDataSource(
    firestore: _firestore,
    currentCouple: currentCouple,
  );
  late final ImageLocalDataSource imageLocalDataSource =
      ImageLocalDataSource();
  late final ImageRemoteDataSource imageRemoteDataSource =
      ImageRemoteDataSource(storage: _storage, currentCouple: currentCouple);

  // --- Timeline: repositories ---
  late final TimelineRepository timelineRepository = TimelineRepositoryImpl(
    remoteDataSource: timelineRemoteDataSource,
  );
  late final ImageRepository imageRepository = ImageRepositoryImpl(
    localDataSource: imageLocalDataSource,
    remoteDataSource: imageRemoteDataSource,
  );

  // --- Timeline: use cases ---
  late final WatchTimelineEvents watchTimelineEvents =
      WatchTimelineEvents(timelineRepository);
  late final AddTimelineEvent addTimelineEvent =
      AddTimelineEvent(timelineRepository);
  late final UpdateTimelineEvent updateTimelineEvent =
      UpdateTimelineEvent(timelineRepository);
  late final DeleteTimelineEvent deleteTimelineEvent =
      DeleteTimelineEvent(timelineRepository);
  late final PickImagesFromGallery pickImagesFromGallery =
      PickImagesFromGallery(imageRepository);
  late final TakePhoto takePhoto = TakePhoto(imageRepository);
  late final UploadImages uploadImages = UploadImages(imageRepository);

  // --- Place: data source, repository, use case ---
  late final PlaceRemoteDataSource placeRemoteDataSource =
      PlaceRemoteDataSource(httpClient: _httpClient);
  late final PlaceRepository placeRepository = PlaceRepositoryImpl(
    remoteDataSource: placeRemoteDataSource,
  );
  late final SearchPlaces searchPlaces = SearchPlaces(placeRepository);

  // --- Gif: data source, repository, use case ---
  late final GifRemoteDataSource gifRemoteDataSource =
      GifRemoteDataSource(httpClient: _httpClient);
  late final GifRepository gifRepository = GifRepositoryImpl(
    remoteDataSource: gifRemoteDataSource,
  );
  late final GetRandomGif getRandomGif = GetRandomGif(gifRepository);

  // --- Notifications: data sources, repository, use case ---
late final DeviceIdentityDataSource deviceIdentityDataSource =
  DeviceIdentityDataSource();
late final PushNotificationDataSource pushNotificationDataSource =
    PushNotificationDataSource();
late final LocalNotificationDataSource localNotificationDataSource =
    LocalNotificationDataSource();

late final NotificationRepository notificationRepository =
    NotificationRepositoryImpl(
  pushDataSource: pushNotificationDataSource,
  localDataSource: localNotificationDataSource,
  deviceIdentityDataSource: deviceIdentityDataSource,
  firestore: _firestore,
  currentUid: () => _auth.currentUser?.uid,
);

late final InitializeNotifications initializeNotifications =
    InitializeNotifications(notificationRepository);

late final GetDeviceId getDeviceId = GetDeviceId(notificationRepository);

late final RegisterDeviceToken registerDeviceToken =
    RegisterDeviceToken(notificationRepository);
late final UnregisterDeviceToken unregisterDeviceToken =
    UnregisterDeviceToken(notificationRepository);

  // --- Préférences de notifications de ce téléphone ---
  late final NotificationPreferencesRepository
      notificationPreferencesRepository =
      NotificationPreferencesRepositoryImpl(
    remoteDataSource:
        NotificationPreferencesRemoteDataSource(
      firestore: _firestore,
      currentUid: () => _auth.currentUser?.uid,
    ),
    deviceIdentityDataSource: deviceIdentityDataSource,
  );
  late final WatchNotificationPreferences watchNotificationPreferences =
      WatchNotificationPreferences(notificationPreferencesRepository);
  late final SaveNotificationPreferences saveNotificationPreferences =
      SaveNotificationPreferences(notificationPreferencesRepository);

  // --- Calendar: use case (les souvenirs viennent de la feature timeline) ---
  late final GroupEventsByDay groupEventsByDay = const GroupEventsByDay();
  late final BuildSpecialDays buildSpecialDays = const BuildSpecialDays();

  // --- Important dates: data source, repository, use cases ---
  late final ImportantDateRemoteDataSource importantDateRemoteDataSource =
      ImportantDateRemoteDataSource(
    firestore: _firestore,
    currentCouple: currentCouple,
  );
  late final ImportantDateRepository importantDateRepository =
      ImportantDateRepositoryImpl(
    remoteDataSource: importantDateRemoteDataSource,
  );
  late final WatchImportantDates watchImportantDates =
      WatchImportantDates(importantDateRepository);
  late final AddImportantDate addImportantDate =
      AddImportantDate(importantDateRepository);
  late final UpdateImportantDate updateImportantDate =
      UpdateImportantDate(importantDateRepository);
  late final DeleteImportantDate deleteImportantDate =
      DeleteImportantDate(importantDateRepository);

  // --- Settings: data source, repository, use cases ---
  late final CoupleSettingsRemoteDataSource coupleSettingsRemoteDataSource =
      CoupleSettingsRemoteDataSource(
    firestore: _firestore,
    currentCouple: currentCouple,
  );
  late final CoupleSettingsRepository coupleSettingsRepository =
      CoupleSettingsRepositoryImpl(
    remoteDataSource: coupleSettingsRemoteDataSource,
  );
  late final WatchCoupleSettings watchCoupleSettings =
      WatchCoupleSettings(coupleSettingsRepository);
  late final SaveCoupleSettings saveCoupleSettings =
      SaveCoupleSettings(coupleSettingsRepository);
  late final GetGifSearchTerm getGifSearchTerm =
      GetGifSearchTerm(coupleSettingsRepository);

  // --- Color history: couleurs libres récentes, propres au téléphone ---
  late final ColorHistoryRepository colorHistoryRepository =
      const ColorHistoryRepositoryImpl(
    localDataSource: ColorHistoryLocalDataSource(),
  );
  late final GetRecentColors getRecentColors =
      GetRecentColors(colorHistoryRepository);
  late final AddRecentColor addRecentColor =
      AddRecentColor(colorHistoryRepository);
  late final RemoveRecentColor removeRecentColor =
      RemoveRecentColor(colorHistoryRepository);
}

// --- Global accessor ---
final ServiceLocator sl = ServiceLocator.instance;