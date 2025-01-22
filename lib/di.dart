import 'package:fitquest/data/sources/connectivity_service.dart';
import 'package:fitquest/data/sources/local/caching_service.dart';
import 'package:fitquest/data/sources/local/local_storage_service.dart';
import 'package:fitquest/data/sources/remote/firebase_auth_service.dart';
import 'package:fitquest/data/sources/remote/firebase_social_service.dart';
import 'package:fitquest/data/sources/remote/firebase_store_service.dart';
import 'package:fitquest/domain/repo/abstract_repos/auth_repository.dart';
import 'package:fitquest/domain/repo/abstract_repos/social_repository.dart';
import 'package:fitquest/domain/repo/firebase_auth_repo.dart';
import 'package:fitquest/domain/repo/firebase_social_repo.dart';
import 'package:fitquest/domain/repo/local_store_repository.dart';
import 'package:fitquest/domain/repo/remote_store_repository.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/destroy_exercise_usecase.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/get_all_exercises_usecase.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/register_user_usecase.dart';
import 'package:fitquest/domain/usecases/exercise_usecases/save_excercise_usecase.dart';
import 'package:fitquest/domain/usecases/social_usecases/accept_friend_request_usecase.dart';
import 'package:fitquest/domain/usecases/social_usecases/add_friend_usecase.dart';
import 'package:fitquest/domain/usecases/social_usecases/get_all_friends_usecase.dart';
import 'package:fitquest/domain/usecases/social_usecases/remove_friends_usecase.dart';
import 'package:fitquest/domain/usecases/social_usecases/search_friends_usecase.dart';
import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/excercise_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/social_viewmodel.dart';
import 'package:get_it/get_it.dart';

final locate = GetIt.instance;

void setupDi() {
  _registerServices();
  _registerRepos();
  _registerUseCases();
  _registerViewModels();
}

void _registerRepos() {
  locate.registerLazySingleton<SocialRepository>(
    () => FirebaseSocialRepo(
      firebaseSocialService: locate(),
    ),
  );

  locate.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepo(
      service: locate(),
    ),
  );

  locate.registerLazySingleton<RemoteStoreRepository>(
    () => RemoteStoreRepository(
      remoteStorageService: locate<FirebaseStoreService>(),
    ),
  );

  locate.registerLazySingleton<LocalStoreRepository>(
    () => LocalStoreRepository(
      localStorageService: locate<LocalStorageService>(),
    ),
  );
}

void _registerServices() {
  locate.registerLazySingleton<CachingService>(() => CachingService());

  locate
      .registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  locate
      .registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());

  locate.registerLazySingleton<FirebaseSocialService>(
    () => FirebaseSocialService(),
  );

  locate.registerLazySingleton<FirebaseStoreService>(
    () => FirebaseStoreService(locate<FirebaseAuthService>().getAuth),
  );

  locate.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );
}

void _registerUseCases() {
  locate.registerLazySingleton<RemoveFriendsUsecase>(
    () => RemoveFriendsUsecase(
      socialRepository: locate(),
    ),
  );

  locate.registerLazySingleton<GetAllFriendsUsecase>(
    () => GetAllFriendsUsecase(
      socialRepository: locate(),
    ),
  );

  locate.registerLazySingleton<AcceptFriendRequestUsecase>(
    () => AcceptFriendRequestUsecase(
      socialRepository: locate(),
    ),
  );

  locate.registerLazySingleton<AddFriendUsecase>(
    () => AddFriendUsecase(
      socialRepository: locate(),
    ),
  );

  locate.registerLazySingleton<SearchFriendsUsecase>(
    () => SearchFriendsUsecase(
      socialRepository: locate(),
    ),
  );

  locate.registerLazySingleton<DestroyExerciseUsecase>(
    () => DestroyExerciseUsecase(
      local: locate<LocalStoreRepository>(),
      remote: locate<RemoteStoreRepository>(),
      authRepository: locate(),
      cachingService: locate(),
    ),
  );

  locate.registerLazySingleton<SaveExcerciseUsecase>(
    () => SaveExcerciseUsecase(
      localRepo: locate<LocalStoreRepository>(),
      remoteRepo: locate<RemoteStoreRepository>(),
      authRepository: locate(),
      cachingService: locate(),
    ),
  );

  locate.registerLazySingleton<GetAllExercisesUsecase>(
    () => GetAllExercisesUsecase(
      local: locate<LocalStoreRepository>(),
      remote: locate<RemoteStoreRepository>(),
      authRepository: locate(),
      cachingService: locate(),
    ),
  );
  locate.registerLazySingleton<RegisterUserUsecase>(
    () => RegisterUserUsecase(
      local: locate(),
      remote: locate(),
      authRepository: locate(),
    ),
  );
}

void _registerViewModels() {
  locate.registerFactory<AuthViewmodel>(
    () => AuthViewmodel(
      repository: locate(),
      registerUserUsecase: locate(),
      connectivityService: locate(),
    ),
  );

  locate.registerFactory<MapViewmodel>(
    () => MapViewmodel(),
  );

  locate.registerFactory<ExcerciseViewmodel>(
    () => ExcerciseViewmodel(
      saveExcerciseUsecase: locate(),
      getAllExercisesUsecase: locate(),
      connectivityService: locate(),
      destroyExerciseUsecase: locate(),
    ),
  );

  locate.registerFactory<SocialViewmodel>(
    () => SocialViewmodel(
      searchFriendsUsecase: locate(),
      addFriendUsecase: locate(),
      acceptFriendRequestUsecase: locate(),
      getAllFriendsUsecase: locate(),
      removeFriendsUsecase: locate(),
      connectivityService: locate(),
    ),
  );
}
