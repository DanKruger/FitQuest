import 'package:fitquest/domain/repo/abstract_repos/social_repository.dart';

class GetAllFriendsUsecase {
  final SocialRepository _socialRepository;

  GetAllFriendsUsecase({required SocialRepository socialRepository})
      : _socialRepository = socialRepository;

  Future<List<Map<String, dynamic>>> execute() async {
    return await _socialRepository.getAllFriends();
  }
}
