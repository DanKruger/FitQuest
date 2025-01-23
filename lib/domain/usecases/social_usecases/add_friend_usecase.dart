import 'package:fitquest/data/models/friend_request.dart';
import 'package:fitquest/domain/repo/abstract_repos/social_repository.dart';

class AddFriendUsecase {
  final SocialRepository _socialRepository;

  AddFriendUsecase({required SocialRepository socialRepository})
      : _socialRepository = socialRepository;

  Future<void> execute(String userId) async {
    await _socialRepository.sendFriendRequest(userId);
  }

  Stream<List<FriendRequest>> listenToFriendRequests() {
    return _socialRepository.getFriendRequestsStream();
  }
}
