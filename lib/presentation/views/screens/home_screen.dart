import 'package:fitquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:fitquest/presentation/views/screens/run_screen.dart';
import 'package:fitquest/presentation/widgets/home_page_welcome_bar.dart';
import 'package:fitquest/presentation/widgets/mini_map.dart';
import 'package:fitquest/presentation/widgets/neumorphic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const HomePageWelcomeBar(),
              _buildRunSection(screenSize, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRunSection(Size screenSize, BuildContext context) {
    return Consumer<MapViewmodel>(
      builder: (context, map, child) {
        if (map.isRunning) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 5),
                MiniMap(),
              ],
            ),
          );
        }
        return _startNewRunButton(screenSize, context);
      },
    );
  }

  Padding _startNewRunButton(Size screenSize, BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        decoration: neumorphicBoxDecoration(1000, theme),
        width: screenSize.width,
        height: 100,
        child: TextButton.icon(
          icon: const Icon(
            FontAwesomeIcons.personRunning,
            size: 30,
          ),
          label: const Text('Start Outdoor Run'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RunScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
