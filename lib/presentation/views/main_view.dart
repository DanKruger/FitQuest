import 'dart:async';

import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fitquest/presentation/views/screens/logged_in_screen.dart';
import 'package:fitquest/presentation/views/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Consumer<AuthViewmodel>(
      builder: (context, auth, child) {
        WidgetsFlutterBinding.ensureInitialized();
        return FutureBuilder(
          future: auth.getLoginStatus,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.hasError) {
                Timer(const Duration(seconds: 1), () {
                  auth.rebuild();
                });
              }
              return _splash(context);
            }
            // || snapshot.connectionState != ConnectionState.done
            auth.loggedIn = snapshot.data!;

            if (auth.loggedIn) return const LoggedInScreen();
            return const WelcomeScreen();
          },
        );
      },
    );
  }

  Widget _splash(context) {
    var theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Image.asset("assets/fitquest.png"),
            ),
            const Text(
              'FitQuest',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 50,
              ),
            ),
            const SizedBox(height: 25),
            LoadingAnimationWidget.inkDrop(
              color: theme.primary,
              size: 50,
            )
          ],
        ),
      ),
    );
  }
}
