import 'package:fitquest/presentation/views/screens/register_screen.dart';
import 'package:fitquest/presentation/widgets/button_styles.dart';
import 'package:fitquest/presentation/widgets/welcome_page_indicator.dart';
import 'package:fitquest/presentation/widgets/neumorphic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int currentPage = 0;
  List<Widget> pages = [];

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    setState(() {
      pages = [
        firstScreen(context),
        secondScreen(context),
        thirdScreen(context)
      ];
    });
    return Scaffold(
      body: Stack(children: [
        PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: pages,
        ),
        Positioned(
          bottom: 20, // Adjust the position as needed
          left: 0,
          right: 0,
          child: WelcomePageIndicator(pages: pages, currentPage: currentPage),
        ),
      ]),
    );
  }

  void onNext(int index) {
    // Animate to the selected page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
    setState(() {
      currentPage = index;
    });
  }

  Widget firstScreen(context) {
    var theme = Theme.of(context).colorScheme;
    String variant = theme.brightness == Brightness.dark ? "dark" : "light";
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: SvgPicture.asset(
                'assets/welcome_screen_1_$variant.svg',
                semanticsLabel: 'Welcome to FitQuest',
              ),
            ),
            const Text(
              "Welcome to FitQuest!",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const Text("Your fitness journey starts here!"),
            const SizedBox(height: 35),
            Container(
              decoration: neumorphicBoxDecoration(999, theme),
              child: TextButton.icon(
                  iconAlignment: IconAlignment.end,
                  onPressed: () => onNext(1),
                  label: const Text("    Continue"),
                  icon: const Icon(Icons.arrow_right)),
            )
          ],
        ),
      ),
    );
  }

  Widget secondScreen(context) {
    var theme = Theme.of(context).colorScheme;
    String variant = theme.brightness == Brightness.dark ? "dark" : "light";
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: SvgPicture.asset(
                'assets/welcome_screen_2_$variant.svg',
                semanticsLabel: 'Welcome to FitQuest',
              ),
            ),
            const Text(
              "Keep track of your fitness",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const Text("And share your progress with friends!"),
            const SizedBox(height: 35),
            Container(
              decoration: neumorphicBoxDecoration(999, theme),
              child: TextButton.icon(
                  iconAlignment: IconAlignment.end,
                  onPressed: () => onNext(2),
                  label: const Text("   Continue"),
                  icon: const Icon(Icons.arrow_right)),
            )
          ],
        ),
      ),
    );
  }

  Widget thirdScreen(BuildContext ctx) {
    ColorScheme theme = Theme.of(ctx).colorScheme;
    String variant = theme.brightness == Brightness.dark ? "dark" : "light";
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: SvgPicture.asset(
                'assets/welcome_screen_3_$variant.svg',
                semanticsLabel: 'Welcome to FitQuest',
              ),
            ),
            const Text(
              "Sound exciting?",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              softWrap: true,
            ),
            const Text("Let's get started"),
            const SizedBox(height: 35),
            Container(
              width: 200,
              height: 50,
              decoration: neumorphicBoxDecoration(999, theme),
              child: SizedBox.expand(
                child: TextButton(
                  style: buttonColorStyle(
                      foregroundColor: theme.onPrimary,
                      backgroundColor: theme.primary),
                  onPressed: () {
                    Navigator.pushReplacement(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text("Sign me up!"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }
}
