import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fitquest/presentation/views/screens/edit_profile_screen.dart';
import 'package:fitquest/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  late User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 19),
        ),
      ),
      body: Consumer<AuthViewmodel>(
        builder: (context, auth, child) {
          var theme = Theme.of(context).colorScheme;
          return FutureBuilder(
            future: auth.currentUser,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              if (snapshot.hasError) return const Text('error occurred');
              user = snapshot.data!;
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildUserInfoDisplay(user, theme),
                    TextButton(
                      child: const Text('Logout'),
                      onPressed: () {
                        auth.signOut();
                      },
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserInfoDisplay(User user, theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 25, // Adjust size as needed
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!) // Use photoURL from Firebase
              : null,
          child: user.photoURL == null
              ? const Icon(Icons.person, size: 25) // Fallback if no photo
              : null,
        ),
        const SizedBox(width: 25),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.displayName ?? user.email!),
            const Text('FitQuest')
          ],
        ),
        const SizedBox(width: 25),
        ElevatedButton(
          style: squareButtonStyle(5, theme),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()));
          },
          child: const Text('Edit'),
        )
      ],
    );
  }
}
