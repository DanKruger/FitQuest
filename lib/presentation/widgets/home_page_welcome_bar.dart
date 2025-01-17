import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/social_viewmodel.dart';
import 'package:fitquest/presentation/views/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class HomePageWelcomeBar extends StatelessWidget {
  const HomePageWelcomeBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewmodel, SocialViewmodel>(
        builder: (context, authViewmodel, social, child) {
      return FutureBuilder(
          future: authViewmodel.currentUser,
          builder: (context, auth) {
            if (!auth.hasData) return const CircularProgressIndicator();
            if (auth.hasError) return const Text('error occurred');
            User? user = auth.data;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Welcome Back,',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        user?.displayName ?? "",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      !authViewmodel.isConnected
                          ? const Icon(Icons.wifi_off)
                              .animate()
                              .fadeIn(duration: 2000.ms)
                          : const SizedBox(),
                      const SizedBox(
                        width: 15,
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(
                          stream: social.friendRequestsStream(),
                          builder: (context, streamSnapshot) {
                            final hasFriendRequests = streamSnapshot.hasData &&
                                (streamSnapshot.data?.isNotEmpty ?? false);
                            return FloatingActionButton(
                              onPressed: () =>
                                  _navigateToNotificationsScreen(context),
                              child: hasFriendRequests
                                  ? const Icon(Icons.notifications_rounded)
                                      .animate()
                                      .shake(delay: 1000.ms, duration: 1000.ms)
                                      .then()
                                      .shake(delay: 1000.ms, duration: 1000.ms)
                                  : const Icon(
                                      Icons.notifications_none_rounded),
                            );
                          })
                    ],
                  )
                ],
              ),
            );
          });
    });
  }

  void _navigateToNotificationsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }
}
