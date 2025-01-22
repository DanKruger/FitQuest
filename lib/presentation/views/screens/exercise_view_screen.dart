import 'dart:ui';

import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/presentation/viewmodels/excercise_viewmodel.dart';
import 'package:fitquest/presentation/views/screens/run_screen.dart';
import 'package:fitquest/presentation/widgets/exercise_list_item.dart';
import 'package:fitquest/presentation/widgets/neumorphic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ExerciseViewScreen extends StatefulWidget {
  final ExerciseModel exerciseModel;

  const ExerciseViewScreen({
    super.key,
    required this.exerciseModel,
  });

  @override
  State<ExerciseViewScreen> createState() => _ExerciseViewScreenState();
}

class _ExerciseViewScreenState extends State<ExerciseViewScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _route = [];

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    Size screenSize = MediaQuery.of(context).size;
    String mapVariant = theme.brightness == Brightness.dark ? "dark" : "light";
    var viewModel = Provider.of<ExcerciseViewmodel>(context);
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: Stack(
          children: [
            _buildMap(mapVariant, theme, screenSize),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  // width: screenSize.width * 0.9,
                  height: screenSize.height * 0.25,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.onSurface.withOpacity(0.1),
                              width: 1,
                            )),
                        // color: theme.surface.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfo(screenSize, theme),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: TextButton(
                                      onPressed: () {
                                        _showConfirmationDialog(
                                            viewModel, context);
                                      },
                                      child: const Text('Remove from history'),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Container(
                                      clipBehavior: Clip.none,
                                      height: 40,
                                      decoration:
                                          neumorphicBoxDecoration(9999, theme),
                                      child: TextButton(
                                        onPressed:
                                            _replayRun, // Call replay on button press
                                        child: const Text('Replay'),
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(
                                    delay: 200.ms,
                                    curve: Curves.easeInOut,
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
      ExcerciseViewmodel viewModel, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: SizedBox(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'Are you sure you want to remove this from your history?'),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              viewModel.destroyExercise(
                                widget.exerciseModel.id!,
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Confirm'),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _route = widget.exerciseModel.route;
  }

  void _animateMovement() async {
    setState(() {
      _route.add(widget.exerciseModel.route[0]);
    });
    const Distance distanceCalculator = Distance();
    for (int i = 0; i < widget.exerciseModel.route.length - 1; i++) {
      LatLng start = widget.exerciseModel.route[i];
      LatLng end = widget.exerciseModel.route[i + 1];

      const int steps = 30; // Number of intermediate points
      for (int step = 1; step <= steps; step++) {
        double t = step / steps; // Interpolation factor (0 to 1)

        // Linearly interpolate latitude and longitude
        double interpolatedLat =
            start.latitude + (end.latitude - start.latitude) * t;
        double interpolatedLng =
            start.longitude + (end.longitude - start.longitude) * t;

        LatLng intermediatePoint = LatLng(interpolatedLat, interpolatedLng);
        // Calculate distance between the previous and current point
        double segmentDistance =
            distanceCalculator.as(LengthUnit.Meter, start, end);
        double intermediateHeight = _calculateCorrectHeight(segmentDistance);
        // Update the route and move the camera smoothly
        setState(() {
          _route.add(intermediatePoint); // Gradually extend the polyline
          _mapController.move(
              intermediatePoint, intermediateHeight); // Smooth camera movement
        });

        // Add a delay for smooth animation
        await Future.delayed(const Duration(milliseconds: 6));
      }
    }

    // Ensure the final point is included in the route
    setState(() {
      _route.add(widget.exerciseModel.route.last);
    });
  }

  double _calculateCorrectHeight(double distance) {
    if (distance > 40) {
      return 16.0; // Minimum zoom for very large distances
    } else if (distance > 35) {
      return 16.2 +
          (distance - 35) *
              (16.0 - 16.2) /
              (40.0 - 35.0); // Interpolate between 16.2 and 16.0
    } else if (distance > 30) {
      return 16.5 +
          (distance - 30) *
              (16.2 - 16.5) /
              (35.0 - 30.0); // Interpolate between 16.5 and 16.2
    } else if (distance > 25) {
      return 16.8 +
          (distance - 25) *
              (16.5 - 16.8) /
              (30.0 - 25.0); // Interpolate between 16.8 and 16.5
    } else if (distance > 20) {
      return 17.2 +
          (distance - 20) *
              (16.8 - 17.2) /
              (25.0 - 20.0); // Interpolate between 17.2 and 16.8
    } else if (distance > 15) {
      return 17.6 +
          (distance - 15) *
              (17.2 - 17.6) /
              (20.0 - 15.0); // Interpolate between 17.6 and 17.2
    } else if (distance > 10) {
      return 18.0 +
          (distance - 10) *
              (17.6 - 18.0) /
              (15.0 - 10.0); // Interpolate between 18.0 and 17.6
    } else if (distance > 5) {
      return 18.5 +
          (distance - 5) *
              (18.0 - 18.5) /
              (10.0 - 5.0); // Interpolate between 18.5 and 18.0
    } else {
      return 19.0; // Maximum zoom for very short distances
    }
  }

  Widget _buildInfo(Size screenSize, theme) {
    return SizedBox(
      width: screenSize.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDateTime(widget.exerciseModel.date),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                widget.exerciseModel.type,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          Wrap(
            children: [
              Row(
                children: [
                  const Text("Distance:"),
                  const SizedBox(width: 15),
                  Text("${widget.exerciseModel.distance.floor()} m")
                ],
              ),
              Row(
                children: [
                  const Text("Duration:"),
                  const SizedBox(width: 15),
                  Text(formatTime(widget.exerciseModel.duration))
                ],
              ),
            ],
          ),
          // Map display for the run
        ],
      ),
    );
  }

  Widget _buildMap(String mapVariant, theme, screenSize) {
    var initPosition = widget.exerciseModel.route.isNotEmpty
        ? widget.exerciseModel.route[0]
        : const LatLng(0, 0);
    return Container(
      clipBehavior: Clip.none,
      width: screenSize.width,
      height: screenSize.height,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          backgroundColor: theme.surface,
          initialCenter: initPosition,
          initialZoom: 19.0,
          maxZoom: 24.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
            additionalOptions: {
              'accessToken': const String.fromEnvironment('mapbox_apiKey'),
              'id': 'mapbox/$mapVariant-v11',
            },
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _route,
                color: theme.primaryContainer,
                strokeWidth: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _replayRun() {
    if (widget.exerciseModel.route.isEmpty) return;

    _route = [];
    setState(() {
      _animateMovement();
    });
  }
}
