import 'package:fitquest/data/models/friend_request.dart';
import 'package:fitquest/presentation/viewmodels/social_viewmodel.dart';
import 'package:fitquest/presentation/widgets/exercise_list_item.dart';
import 'package:fitquest/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class FriendRequestScreen extends StatelessWidget {
  const FriendRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
      ),
      body: Consumer<SocialViewmodel>(
        builder: (context, socialViewmodel, _) {
          var theme = Theme.of(context).colorScheme;
          if (!socialViewmodel.isConnected) {
            return const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No internet'),
                  SizedBox(
                    width: 15,
                  ),
                  Icon(Icons.wifi_off)
                ],
              ),
            );
          }
          return StreamBuilder<List<FriendRequest>>(
            stream: socialViewmodel.friendRequestsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: LoadingAnimationWidget.discreteCircle(
                  color: theme.primary,
                  size: 40,
                ));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final friendRequests = snapshot.data ?? [];

              if (friendRequests.isEmpty) {
                return const Center(child: Text('No friend requests.'));
              }

              return ListView.builder(
                itemCount: friendRequests.length,
                itemBuilder: (context, index) {
                  final request = friendRequests[index];
                  return ListTile(
                    tileColor: theme.surface,
                    title: Text(request.fromUser),
                    subtitle: Text(
                      formatDateTime(request.timestamp.toLocal()),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          style: squareButtonStyle(9, theme,
                              orange: true, elevation: 0),
                          icon: const Icon(Icons.check),
                          color: Colors.green,
                          onPressed: () {
                            socialViewmodel.acceptFriendRequest(request.fromId);
                          },
                        ),
                        IconButton(
                          style: squareButtonStyle(9, theme,
                              orange: true, elevation: 0),
                          icon: const Icon(Icons.close),
                          color: Colors.red,
                          onPressed: () {
                            // Decline friend request logic here
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
