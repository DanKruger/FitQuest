import 'package:fitquest/data/models/friend_model.dart';
import 'package:fitquest/presentation/viewmodels/social_viewmodel.dart';
import 'package:fitquest/presentation/views/screens/friend_request_screen.dart';
import 'package:fitquest/presentation/views/screens/search_screen.dart';
import 'package:fitquest/presentation/widgets/login_form.dart';
import 'package:fitquest/presentation/widgets/neumorphic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Friends',
          style: TextStyle(fontSize: 19),
        ),
        forceMaterialTransparency: true,
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 70,
                  width: screenSize.width * 0.4,
                  decoration: neumorphicBoxDecoration(15, theme),
                  child: SizedBox.expand(
                    child: TextButton(
                      style: squareButtonStyle(15, theme),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SearchScreen()));
                      },
                      child: const Text('Add friends'),
                    ),
                  ),
                ),
                Container(
                  height: 70,
                  width: screenSize.width * 0.4,
                  decoration: neumorphicBoxDecoration(15, theme),
                  child: TextButton(
                    style: squareButtonStyle(15, theme),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FriendRequestScreen(),
                        ),
                      );
                    },
                    child: const Text('Friend Requests'),
                  ),
                )
              ],
            ),
            const SizedBox(height: 25),
            const FriendsList()
          ],
        ),
      ),
    );
  }
}

class FriendsList extends StatelessWidget {
  const FriendsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialViewmodel>(
      builder: (context, SocialViewmodel social, child) {
        var theme = Theme.of(context).colorScheme;
        String variant = theme.brightness == Brightness.dark ? "dark" : "light";
        var size = MediaQuery.of(context).size;
        return FutureBuilder(
          future: social.getFriends(),
          builder: (context, snapshot) {
            if (!social.isConnected) {
              return const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No internet'),
                      SizedBox(width: 15),
                      Icon(Icons.wifi_off)
                    ],
                  ),
                  SizedBox(height: 15),
                  Text("Go online to see your friends")
                ],
              );
            }
            if (!snapshot.hasData &&
                snapshot.connectionState != ConnectionState.done) {
              return LoadingAnimationWidget.stretchedDots(
                color: theme.primary,
                size: 50,
              );
            }

            if (snapshot.hasError) {
              return Text("An error occurred ${snapshot.error}");
            }

            List<FriendModel>? friends = snapshot.data;
            if (friends!.isEmpty) {
              return Column(
                children: [
                  SizedBox(
                    height: size.height * 0.2,
                    child: SvgPicture.asset(
                      'assets/friends_screen_$variant.svg',
                      semanticsLabel: 'You have no friends',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("You have no friends yet"),
                ],
              );
            }
            return Expanded(
              child: ListView.separated(
                itemCount: friends.length,
                itemBuilder: (context, int index) {
                  var friend = friends[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.account_circle_outlined,
                      size: 40,
                    ),
                    title: Row(
                      children: [
                        Text(friend.firstName),
                        const SizedBox(width: 5),
                        Text(friend.lastName),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () =>
                          _showConfirmationDialog(context, friend, social),
                      icon: Icon(Icons.person_remove, color: theme.error),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: theme.surfaceDim,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialog(
      BuildContext context, FriendModel? friend, SocialViewmodel social) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var theme = Theme.of(context).colorScheme;
        return Center(
          child: Card(
            color: theme.surface,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Are you sure you want to remove this friend?',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 15),
                  Text(
                      '${friend?.firstName} will be removed from your friends list'),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 40,
                        decoration: neumorphicBoxDecoration(9999, theme),
                        child: SizedBox.expand(
                          child: TextButton(
                            onPressed: () async {
                              await social.removeFriend(friend!.friendId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${friend.firstName} has been removed'),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Yes'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Nevermind'),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
