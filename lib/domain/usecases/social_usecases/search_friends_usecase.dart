import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/domain/repo/abstract_repos/social_repository.dart';

class SearchFriendsUsecase {
  final SocialRepository _socialRepository;

  SearchFriendsUsecase({required SocialRepository socialRepository})
      : _socialRepository = socialRepository;

  Future<List<Map<String, dynamic>>> execute(String query) async {
    List<Map<String, dynamic>> result = [];
    User? user = await _socialRepository.currentUser;
    String? currentUserId = user?.uid;
    String? currentUserEmail = user?.email;

    List<Map<String, dynamic>> data =
        await _socialRepository.searchFriend(query);

    for (Map<String, dynamic> item in data) {
      Iterable resultValues = item.values;
      String itemEmailAddress = (item['email_address'] as String).toLowerCase();
      String itemFirstName = (item['first_name'] as String).toLowerCase();

      bool isNotCurrentUser = !resultValues.contains(currentUserEmail) ||
          !resultValues.contains(currentUserId);
      bool itemContainsQuery = itemEmailAddress.contains(query.toLowerCase()) ||
          itemFirstName.contains(query.toLowerCase());

      if (isNotCurrentUser && itemContainsQuery) {
        result.add(item);
      }
    }

    return result;
  }
}
