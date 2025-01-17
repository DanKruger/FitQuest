import 'package:fitquest/domain/repo/abstract_repos/social_repository.dart';

class RemoveFriendsUsecase {
  final SocialRepository _socialRepository;

  RemoveFriendsUsecase({required SocialRepository socialRepository})
      : _socialRepository = socialRepository;

  Future<void> execute(String id) async {
    await _socialRepository.removeFriend(id);
  }
}
