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
        child: Column(
          children: [
            _buildMap(mapVariant, theme, screenSize),
            _buildInfo(screenSize, theme),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: TextButton(
                      onPressed: () {
                        _showConfirmationDialog(viewModel, context);
                      },
                      child: const Text('Remove from history'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Container(
                      clipBehavior: Clip.none,
                      height: 40,
                      decoration: neumorphicBoxDecoration(9999, theme),
                      child: TextButton(
                        onPressed: _replayRun, // Call replay on button press
                        child: const Text('Replay'),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(
                    delay: 200.ms,
                    curve: Curves.easeInOut,
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
    for (int i = 0; i < widget.exerciseModel.route.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _route.add(widget.exerciseModel.route[i]);
        _mapController.move(
          _route[i],
          19.0,
        );
      });
    }
  }

  Widget _buildInfo(Size screenSize, theme) {
    return Container(
      // decoration: neumorphicBoxDecoration(15, theme),
      width: screenSize.width,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
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
      ),
    );
  }

  Widget _buildMap(String mapVariant, theme, screenSize) {
    print(widget.exerciseModel.route);
    var initPosition = widget.exerciseModel.route.isNotEmpty
        ? widget.exerciseModel.route[0]
        : const LatLng(0, 0);
    return Container(
      clipBehavior: Clip.none,
      width: screenSize.width,
      height: screenSize.height * 0.5,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
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
