import 'package:fitquest/data/models/friend_model.dart';
import 'package:fitquest/domain/repo/abstract_repos/social_repository.dart';

class GetAllFriendsUsecase {
  final SocialRepository _socialRepository;

  GetAllFriendsUsecase({required SocialRepository socialRepository})
      : _socialRepository = socialRepository;

  Future<List<FriendModel>> execute() async {
    var data = await _socialRepository.getAllFriends();
    return data.map((json) => FriendModel.fromJson(json)).toList();
  }
}
