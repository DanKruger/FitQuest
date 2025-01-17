import 'package:fitquest/domain/repo/abstract_repos/social_repository.dart';

class AddFriendUsecase {
  final SocialRepository _socialRepository;

  AddFriendUsecase({required SocialRepository socialRepository})
      : _socialRepository = socialRepository;

  Future<void> execute(String userId) async {
    await _socialRepository.sendFriendRequest(userId);
  }

  Stream<List<Map<String, dynamic>>> listenToFriendRequests() {
    return _socialRepository.getFriendRequestsStream();
  }
}
