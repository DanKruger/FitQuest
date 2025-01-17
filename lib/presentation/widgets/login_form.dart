import 'package:fitquest/data/models/user_model.dart';
import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fitquest/presentation/views/main_view.dart';
import 'package:fitquest/presentation/widgets/button_styles.dart';
import 'package:fitquest/presentation/widgets/exceptions/no_internet_exception.dart';
import 'package:fitquest/presentation/widgets/neumorphic_widgets.dart';
import 'package:fitquest/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';
import "package:flutter_animate/flutter_animate.dart";
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ColorScheme theme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Column(
          children: [
            Text('Hey there,',
                style: TextStyle(fontWeight: FontWeight.w200, fontSize: 20)),
            Text('Welcome Back',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25)),
          ],
        ),
        _buildForm(screenSize, emailController, passwordController, theme),
        Column(
          children: [
            _buildLoginButton(screenSize, emailController, passwordController),
            buildSeparator(screenSize, theme),
            buildAuthButtons(),
          ],
        )
      ],
    ).animate().fade(duration: 500.ms);
  }

  Widget _buildLoginButton(Size screenSize, TextEditingController email,
      TextEditingController password) {
    return Consumer<AuthViewmodel>(builder: (_, auth, child) {
      var theme = Theme.of(context).colorScheme;
      if (auth.loading) {
        return LoadingAnimationWidget.fallingDot(
          color: theme.primary,
          size: 50,
        );
      }
      return Container(
        decoration: neumorphicBoxDecoration(9999, theme),
        height: screenSize.height * 0.07,
        width: screenSize.width * 0.8,
        child: TextButton(
          style: buttonColorStyle(
              foregroundColor: theme.onPrimary, backgroundColor: theme.primary),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _submit(email, password, auth);
            }
          },
          child: const Text('Login'),
        ),
      );
    });
  }

  Future<void> _submit(TextEditingController email,
      TextEditingController password, AuthViewmodel auth) async {
    try {
      UserModel userModel = UserModel(
          firstName: "User",
          lastName: "User",
          email: email.text,
          password: password.text);
      await auth.signIn(userModel);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainView(),
        ),
      );
    } on NoInternetException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect Email or Password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildForm(Size screenSize, TextEditingController emailController,
      TextEditingController passwordController, theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            decoration: flatBoxDecoration(15, theme),
            width: screenSize.width * 0.8,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  label: Text('Email'),
                  // border: OutlineInputBorder(),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'You need to enter a valid email';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: flatBoxDecoration(15, theme),
            width: screenSize.width * 0.8,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  label: Text('Password'),
                  border: InputBorder.none,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'You need to enter a password';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildAuthButtons() {
  return Consumer<AuthViewmodel>(
    builder: (BuildContext context, AuthViewmodel auth, Widget? child) {
      var theme = Theme.of(context).colorScheme;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              decoration: neumorphicBoxDecoration(999, theme),
              height: 50,
              // width: 200,
              child: TextButton(
                  // style: squareButtonStyle(),
                  onPressed: () {
                    _signInWithGoogle(auth, context);
                  },
                  child: auth.isConnected
                      ? Image.network(
                          'http://pngimg.com/uploads/google/google_PNG19635.png',
                          fit: BoxFit.cover,
                        )
                      : const Text("Google"))),
          // const SizedBox(
          //   width: 15,
          // ),
          // Container(
          //   decoration: neumorphicBoxDecoration(999, theme),
          //   height: 50,
          //   child: TextButton(
          //     // style: squareButtonStyle(),
          //     onPressed: () {},
          //     child: const Icon(Icons.question_mark),
          //   ),
          // ),
        ],
      );
    },
  );
}

void _signInWithGoogle(AuthViewmodel auth, BuildContext context) async {
  try {
    await auth.signInWithGoogle();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainView(),
      ),
    );
  } on NoInternetException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message),
        backgroundColor: Colors.red,
      ),
    );
  } on Exception {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Something went wrong'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

ButtonStyle squareButtonStyle(double radius, theme) {
  return ElevatedButton.styleFrom(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ));
}
