import 'package:fitquest/presentation/views/screens/welcome_screen.dart';
import 'package:fitquest/presentation/widgets/login_form.dart';
import 'package:fitquest/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String message = "Already have an account?";
  String type = "Login";
  int selectedForm = 0;
  var forms = const [RegisterForm(), LoginForm()];

  @override
  Widget build(BuildContext context) {
    formButton({required VoidCallback onPressed}) {
      return TextButton(
        onPressed: onPressed,
        child: Text(type),
      );
    }

    return Scaffold(
      body: Center(
        child: forms[selectedForm],
      ),
      bottomNavigationBar: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          formButton(
            onPressed: () {
              setState(() {
                selectedForm = selectedForm == 0 ? 1 : 0;
                type = getType(type);
                message = getMessage(message);
              });
            },
          ),
        ],
      ),
    );
  }

  String getType(String type) {
    return type == "Login" ? "Register" : "Login";
  }

  String getMessage(String msg) {
    return msg == "Already have an account?"
        ? "Don't have an account yet?"
        : "Already have an account?";
  }
}
