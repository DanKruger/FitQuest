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
  // Determine the timestamp status
  HistoryTimestamp timestampData =
  await cacheService.compareTimestampWithCurrentTime(userId);

  bool isUpToDate = timestampData == HistoryTimestamp.newer;
  bool isOutdated = timestampData == HistoryTimestamp.old;
  bool hasNoTimestamp = timestampData == HistoryTimestamp.none;

  // Retrieve local data and cache it
  var localData = await localRepo.getAllExercises(userId);
  await cacheService.cacheHistory(userId, localData!, addNewTimestamp: false);
  // Filter helper function
  void filterList(List<dynamic> source, List<dynamic> target) {
    target.removeWhere(source.contains);
  }

  // Handle the case where there is no timestamp
  if (hasNoTimestamp) {
    // If there is no cache yet then it probably means this is a new device
    // So user probably has saved exercises in the cloud, so try to sync any
    // remote data locally
    // This is only supposed to run once
    List<ExerciseModel?>? remoteData = await remoteRepo.getAllExercises(userId);
    if (remoteData != null) {
      var combinedData = {...localData, ...remoteData}.toList();
      filterList(localData, combinedData);
      for (var exercise in combinedData) {
        await localRepo.saveExercise(exercise!);
      }
    }
  }

  if (isOutdated) {
    // Handle removing stale remote data
    var cachedData = await cacheService.getCachedHistory(userId);
    var remoteData = await remoteRepo.getAllExercises(userId) ?? [];

    // Remove remote exercises not present in the cache
    filterList(cachedData, remoteData);
    for (var exercise in remoteData) {
      await remoteRepo.deleteExerciseById(exercise?.id ?? 0);
    }

    // Handle adding missing local data to remote
    filterList(remoteData, cachedData);
    for (var exercise in cachedData) {
      await remoteRepo.saveExercise(exercise);
    }
  }
}
