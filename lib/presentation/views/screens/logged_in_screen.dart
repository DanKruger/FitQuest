import 'package:fitquest/presentation/views/screens/excercise_history_screen.dart';
import 'package:fitquest/presentation/views/screens/friends_screen.dart';
import 'package:fitquest/presentation/views/screens/home_screen.dart';
import 'package:fitquest/presentation/views/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoggedInScreen extends StatefulWidget {
  const LoggedInScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoggedInScreenState();
}

class _LoggedInScreenState extends State<LoggedInScreen> {
  List<Widget> pages = const [
    HomeScreen(),
    ExcerciseHistoryScreen(),
    FriendsScreen(),
    ProfileScreen()
  ];

  int selectedPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: pages,
      ),
      bottomNavigationBar: _navigationBar(context),
    );
  }

  NavigationBar _navigationBar(context) {
    var theme = Theme.of(context).colorScheme;
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: _onNavBarTapped,
      indicatorColor: theme.primary.withOpacity(0.2),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((_) {
        return Colors.transparent;
      }),
      selectedIndex: selectedPage,
      destinations: <Widget>[
        NavigationDestination(
          selectedIcon: Icon(
            Icons.home_rounded,
            color: theme.primary,
          ),
          icon: Icon(
            Icons.home_outlined,
            color: theme.onSurfaceVariant,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          selectedIcon: Icon(
            FontAwesomeIcons.clipboardList,
            color: theme.primary,
            size: 18,
          ),
          icon: Icon(
            FontAwesomeIcons.clipboard,
            color: theme.onSurfaceVariant,
            size: 18,
          ),
          label: 'History',
        ),
        NavigationDestination(
          selectedIcon: Icon(
            Icons.people_rounded,
            color: theme.primary,
          ),
          icon: Icon(
            Icons.people_outline_rounded,
            color: theme.onSurfaceVariant,
          ),
          label: 'Social',
        ),
        NavigationDestination(
          selectedIcon: Icon(
            Icons.account_circle_rounded,
            color: theme.primary,
          ),
          icon: Icon(
            Icons.account_circle_outlined,
            color: theme.onSurfaceVariant,
          ),
          label: 'Account',
        ),
      ],
    );
  }

  bool _isAnimating = false;

  void _onNavBarTapped(int index) {
    if (_isAnimating) return;
    final currentIndex = _pageController.page?.round() ?? 0;
    if (currentIndex == index) return;
    _isAnimating = true;
    Future.microtask(() async {
      _pageController.jumpToPage(index);
      setState(() {
        selectedPage = index;
      });
      _isAnimating = false;
    });
  }

  void _onPageChanged(int index) {
    if (_isAnimating) {
      return;
    }
    setState(() {
      selectedPage = index;
    });
  }
}
