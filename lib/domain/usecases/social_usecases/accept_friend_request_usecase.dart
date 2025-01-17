import 'package:fitquest/domain/repo/abstract_repos/social_repository.dart';

class AcceptFriendRequestUsecase {
  final SocialRepository _socialRepository;

  AcceptFriendRequestUsecase({required SocialRepository socialRepository})
      : _socialRepository = socialRepository;

  Future<void> execute(String friendId) async {
    await _socialRepository.acceptFriendRequest(friendId);
  }
}
