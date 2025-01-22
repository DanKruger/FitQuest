import 'package:fitquest/presentation/views/screens/excercise_history_screen.dart';
import 'package:fitquest/presentation/views/screens/friends_screen.dart';
import 'package:fitquest/presentation/views/screens/home_screen.dart';
import 'package:fitquest/presentation/views/screens/profile_screen.dart';
import 'package:flutter/material.dart';

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
      overlayColor: WidgetStateProperty.resolveWith<Color?>((_) {
        return Colors.transparent;
      }),
      selectedIndex: selectedPage,
      destinations: <Widget>[
        NavigationDestination(
          selectedIcon: Icon(
            Icons.home_rounded,
            color: theme.onPrimary,
          ),
          icon: Icon(
            Icons.home_outlined,
            color: theme.onSurfaceVariant,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          selectedIcon: Icon(
            Icons.directions_run_rounded,
            color: theme.onPrimary,
          ),
          icon: Icon(
            Icons.directions_run_outlined,
            color: theme.onSurfaceVariant,
          ),
          label: 'History',
        ),
        NavigationDestination(
          selectedIcon: Icon(
            Icons.people_rounded,
            color: theme.onPrimary,
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
            color: theme.onPrimary,
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
