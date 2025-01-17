// ignore_for_file: unused_local_variable

import 'package:fitquest/data/sources/local/caching_service.dart';
import 'package:fitquest/domain/repo/local_store_repository.dart';
import 'package:fitquest/domain/repo/remote_store_repository.dart';

Future<void> updateCache(
    CachingService cacheService,
    LocalStoreRepository localRepo,
    RemoteStoreRepository remoteRepo,
    String userId,
    {bool newTimeStamp = true}) async {
  HistoryTimestamp timestampData =
      await cacheService.compareTimestampWithCurrentTime(userId);

  var upToDateTimestamp = timestampData == HistoryTimestamp.newer;
  var outdatedTimestamp = timestampData == HistoryTimestamp.old;
  var noTimestamp = timestampData == HistoryTimestamp.none;

  var localData =
      await localRepo.getAllExercises(userId); // Get saved local exercises
  await cacheService.cacheHistory(userId, localData ?? [],
      addNewTimestamp: false); // Cache local exercises

  void filterList(List<dynamic> list1, List<dynamic> list2) {
    list2.removeWhere((item) => list1.contains(item));
  }

  if (outdatedTimestamp) {
    // Remove any leftovers from remote (deleted locally, still in remote)
    var cached = await cacheService.getCachedHistory(
        userId); // Get what is cached (locally saved included)
    var remoteData =
        await remoteRepo.getAllExercises(userId); // Get what is in remote
    filterList(cached, remoteData!); // Filter out what is not in cached

    for (var item in remoteData) {
      await remoteRepo.deleteExerciseById(item?.id ?? 0); // Delete from remote
    }
  }
  if (outdatedTimestamp) {
    // Add local exercises missing from remote (added locally, not in remote yet)
    var cached =
        await cacheService.getCachedHistory(userId); // Get what is cached
    var remoteData =
        await remoteRepo.getAllExercises(userId); // Get what is in remote
    filterList(remoteData!, cached); // Filter out what is not in remote data
    for (var thing in cached) {
      // Loop through cache
      await remoteRepo
          .saveExercise(thing); // Add what is in the cache to remote
    }
  }
}
