// ============================================================================
// DEPENDENCY INJECTION CONTAINER
// ============================================================================
// Manual composition root: wires data sources, repositories and use cases
// for every feature. Exposed as a single top-level instance `sl`
// (service locator), read by screens/widgets when creating their ViewModels.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

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

// --- Onboarding feature ---
import 'features/onboarding/data/datasources/preferences_local_datasource.dart';
import 'features/onboarding/data/datasources/motion_datasource.dart';
import 'features/onboarding/data/repositories/preferences_repository_impl.dart';
import 'features/onboarding/data/repositories/motion_repository_impl.dart';
import 'features/onboarding/domain/repositories/preferences_repository.dart';
import 'features/onboarding/domain/repositories/motion_repository.dart';
import 'features/onboarding/domain/usecases/check_first_run.dart';
import 'features/onboarding/domain/usecases/complete_onboarding.dart';
import 'features/onboarding/domain/usecases/watch_shake_events.dart';

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

// --- Service locator singleton ---
class ServiceLocator {
  ServiceLocator._internal();
  static final ServiceLocator instance = ServiceLocator._internal();

  // --- External packages ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final http.Client _httpClient = http.Client();

  // --- Timeline: data sources ---
  late final TimelineRemoteDataSource timelineRemoteDataSource =
      TimelineRemoteDataSource(firestore: _firestore);
  late final ImageLocalDataSource imageLocalDataSource =
      ImageLocalDataSource();
  late final ImageRemoteDataSource imageRemoteDataSource =
      ImageRemoteDataSource(storage: _storage);

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

  // --- Onboarding: data sources ---
  late final PreferencesLocalDataSource preferencesLocalDataSource =
      PreferencesLocalDataSource();
  late final MotionDataSource motionDataSource = MotionDataSource();

  // --- Onboarding: repositories ---
  late final PreferencesRepository preferencesRepository =
      PreferencesRepositoryImpl(localDataSource: preferencesLocalDataSource);
  late final MotionRepository motionRepository = MotionRepositoryImpl(
    dataSource: motionDataSource,
  );

  // --- Onboarding: use cases ---
  late final CheckFirstRun checkFirstRunUseCase =
      CheckFirstRun(preferencesRepository);
  late final CompleteOnboarding completeOnboarding =
      CompleteOnboarding(preferencesRepository);
  late final WatchShakeEvents watchShakeEvents =
      WatchShakeEvents(motionRepository);

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
);

late final InitializeNotifications initializeNotifications =
    InitializeNotifications(notificationRepository);

late final GetDeviceId getDeviceId = GetDeviceId(notificationRepository);

  // --- Convenience passthrough used by the router's redirect logic ---
  Future<bool> checkFirstRun() => checkFirstRunUseCase();
}

// --- Global accessor ---
final ServiceLocator sl = ServiceLocator.instance;