import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/data/models/run_excercise_model.dart';
import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/excercise_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:fitquest/presentation/widgets/button_styles.dart';
import 'package:fitquest/presentation/widgets/neumorphic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_animate/flutter_animate.dart';

MarkerLayer buildMarkerLayer(MapViewmodel map, ColorScheme theme) {
  return MarkerLayer(
    markers: [
      Marker(
        point: map.currentPosition!,
        child: Icon(
          Icons.circle_rounded,
          color: theme.primary,
          size: 20.0,
          shadows: [
            Shadow(color: theme.primary.withOpacity(0.7), blurRadius: 30),
          ],
        ),
      ),
    ],
  );
}

PolylineLayer<Object> buildPolylineLayer(MapViewmodel map, ColorScheme theme) {
  return PolylineLayer(polylines: [
    Polyline(
      points: map.route,
      color: theme.primaryContainer,
      strokeWidth: 5,
    ),
  ]);
}

TileLayer buildTileLayer(String mapVariant) {
  return TileLayer(
    urlTemplate:
        'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
    additionalOptions: {
      'accessToken': const String.fromEnvironment('mapbox_apiKey'),
      'id': 'mapbox/$mapVariant-v11',
    },
  );
}

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    var authModel = Provider.of<AuthViewmodel>(context);
    return Consumer<MapViewmodel>(
      builder: (_, map, child) {
        var theme = Theme.of(context).colorScheme;
        if (map.currentPosition == null) {
          map.getCurrentLocation();
          // TODO center map when position changes
        }
        return Scaffold(
          appBar: AppBar(
            forceMaterialTransparency: true,
          ),
          extendBodyBehindAppBar: true,
          body: map.currentPosition == null
              ? _buildLoading(theme)
              : _buildMap(map, authModel),
        );
      },
    );
  }

  TextButton _buildBackButton(ColorScheme theme) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Icon(
        Icons.arrow_back,
        color: theme.onSurface,
      ),
    );
  }

  Scaffold _buildLoading(theme) {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.stretchedDots(
          color: theme.primary,
          size: 100,
        ),
      ),
    );
  }

  Scaffold _buildMap(MapViewmodel map, AuthViewmodel authModel) {
    ColorScheme theme = Theme.of(context).colorScheme;
    String mapVariant = theme.brightness == Brightness.dark ? "dark" : "light";
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: map.currentPosition!,
          initialZoom: map.initialZoom,
          initialRotation: 0.0,
          keepAlive: true,
          backgroundColor: theme.surface,
        ),
        children: [
          buildTileLayer(mapVariant),
          buildPolylineLayer(map, theme),
          buildMarkerLayer(map, theme),
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildStartButton(map, authModel, theme),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildResetMapButton(map),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  FloatingActionButton _buildResetMapButton(MapViewmodel map) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () async {
        await map.getCurrentLocation();
        _mapController.moveAndRotate(
          map.currentPosition!,
          map.initialZoom,
          0.0,
        );
      },
      child: const Icon(
        Icons.my_location_rounded,
      ),
    );
  }

  SizedBox _buildStartButton(MapViewmodel map, AuthViewmodel authModel, theme) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: theme.surface, elevation: 10),
          onPressed: () {
            _showTimerDrawer(context, map, authModel);
            if (!map.isTracking) {
              map.startTimer();
              map.startRunTracking();
            }
          },
          child: _startButtonDisplay(map)),
    );
  }

  IconData _getIconState(bool running, bool paused) {
    if (running) {
      return FontAwesomeIcons.stopwatch;
    } else if (paused) {
      return FontAwesomeIcons.play;
    } else {
      return FontAwesomeIcons.personRunning;
    }
  }

  void _showTimerDrawer(
      BuildContext context, MapViewmodel viewModel, AuthViewmodel authModel) {
    var theme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      backgroundColor: theme.surface,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Consumer2<MapViewmodel, ExcerciseViewmodel>(
          builder: (context, mapViewmodel, exerciseViewmodel, child) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    formatTime(mapViewmodel.secondsElapsed),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FontAwesomeIcons.personRunning),
                      Text("${mapViewmodel.totalDistance.floor().toString()}m"),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: neumorphicBoxDecoration(90000, theme),
                        width: 100,
                        height: 100,
                        child: TextButton(
                          // style: buttonColorStyle(
                          //   foregroundColor: theme.onSecondaryContainer,
                          //   backgroundColor: theme.secondaryContainer,
                          // ),
                          onPressed: () {
                            if (mapViewmodel.isRunning) {
                              mapViewmodel.pauseTimer();
                              mapViewmodel.toggleTracking(false);
                            } else {
                              mapViewmodel.startTimer();
                              mapViewmodel.toggleTracking(true);
                            }
                          },
                          child: Icon(
                            mapViewmodel.isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 50,
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        decoration: neumorphicBoxDecoration(
                          9000,
                          theme,
                        ),
                        child: TextButton(
                          style: buttonColorStyle(
                            foregroundColor: theme.onPrimaryContainer,
                            backgroundColor: theme.primaryContainer,
                          ),
                          onPressed: () {
                            _saveExercise(
                                authModel, mapViewmodel, exerciseViewmodel);
                            Navigator.pop(context); // Close the drawer
                          },
                          child: const Text("Stop"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveExercise(
      authModel, MapViewmodel mapModel, ExcerciseViewmodel exModel) async {
    try {
      var user = await authModel.currentUser;
      ExerciseModel exercise = RunExerciseModel(
        userId: user!.uid,
        type: "Run", // TODO get userId
        date: DateTime.now(), // TODO decide to store end time or start time
        duration: mapModel.secondsElapsed,
        distance: mapModel.totalDistance,
        route: List.from(mapModel.route),
      );
      await exModel.saveExcercise(exercise);
      mapModel.stopTimer();
      mapModel.stopTracking();
    } on Exception catch (e) {
      print("Error occurred");
      print(e);
    }
  }

  Widget _startButtonDisplay(MapViewmodel map) {
    bool running = map.isRunning;
    bool paused = map.secondsElapsed > 0;
    IconData icon = _getIconState(running, paused);

    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 5),
        Text(!running && !paused ? 'Start' : formatTime(map.secondsElapsed))
      ],
    );
  }
}

String formatTime(int seconds) {
  final int minutes = seconds ~/ 59;
  final int remainingSeconds = seconds % 59;
  return "${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
}
