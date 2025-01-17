import 'package:fitquest/data/models/user_model.dart';
import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fitquest/presentation/views/main_view.dart';
import 'package:fitquest/presentation/widgets/button_styles.dart';
import 'package:fitquest/presentation/widgets/exceptions/no_internet_exception.dart';
import 'package:fitquest/presentation/widgets/login_form.dart';
import 'package:fitquest/presentation/widgets/neumorphic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import "package:flutter_animate/flutter_animate.dart";

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    ColorScheme theme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: screenSize.width,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenSize.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Column(
                  children: [
                    Text('Hey there,',
                        style: TextStyle(
                            fontWeight: FontWeight.w200, fontSize: 20)),
                    Text('Create an Account',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 25)),
                  ],
                ),
                _buildForm(screenSize, theme),
                Column(
                  children: [
                    _buildRegisterButton(
                        screenSize,
                        firstNameController,
                        lastNameController,
                        emailController,
                        passwordController),
                    buildSeparator(screenSize, theme),
                    buildAuthButtons(),
                  ],
                ),
              ],
            ).animate().fade(duration: 500.ms),
          ),
        ),
      ),
    );
  }

  Form _buildForm(Size screenSize, theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            decoration: flatBoxDecoration(15, theme),
            width: screenSize.width * 0.8,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  label: Text("First Name"),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'You need to fill out this field';
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
                controller: lastNameController,
                decoration: const InputDecoration(
                  label: Text("Last Name"),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'You need to fill out this field';
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
                controller: emailController,
                decoration: const InputDecoration(
                  label: Text("Email"),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'You need to fill out this field';
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
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text("Password"),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'You need to fill out this field';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(
      Size screenSize,
      TextEditingController fName,
      TextEditingController lName,
      TextEditingController email,
      TextEditingController password) {
    return Consumer<AuthViewmodel>(builder: (context, auth, child) {
      var theme = Theme.of(context).colorScheme;
      if (auth.loading) {
        return LoadingAnimationWidget.fallingDot(
          color: theme.primary,
          size: 50,
        );
      }

      return Container(
        decoration: neumorphicBoxDecoration(999, theme),
        height: screenSize.height * 0.07,
        width: screenSize.width * 0.8,
        child: TextButton(
          style: buttonColorStyle(
              foregroundColor: theme.onPrimary, backgroundColor: theme.primary),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                UserModel userModel = UserModel(
                    firstName: fName.text,
                    lastName: lName.text,
                    email: email.text,
                    password: password.text);
                await auth.registerUser(userModel);
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
              } on Exception catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect Email or Password'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Register'),
        ),
      );
    });
  }

  ButtonStyle _squareButtonStyle() {
    return ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(9.0),
    ));
  }
}

Widget buildSeparator(Size screenSize, ColorScheme theme) {
  return Column(
    children: [
      const SizedBox(height: 15),
      SizedBox(
        width: screenSize.width * 0.8,
        child: Row(
          children: [
            Expanded(
                child: Divider(
              color: theme.secondary,
            )),
            const SizedBox(width: 10),
            const Text('or'),
            const SizedBox(width: 10),
            Expanded(
                child: Divider(
              color: theme.secondary,
            )),
          ],
        ),
      ),
      const SizedBox(height: 15),
    ],
  );
}
