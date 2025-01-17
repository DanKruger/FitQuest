import 'package:fitquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:fitquest/presentation/views/screens/run_screen.dart';
import 'package:fitquest/presentation/widgets/neumorphic_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MiniMap extends StatelessWidget {
  MiniMap({super.key});

  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    bool isDarkTheme = theme.brightness == Brightness.dark;
    String mapVariant = isDarkTheme ? "dark" : "light";
    Size screenSize = MediaQuery.of(context).size;
    return Consumer<MapViewmodel>(
      builder: (_, map, child) {
        return Container(
          decoration: neumorphicBoxDecoration(15,theme),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(15),
          // ),
          foregroundDecoration: BoxDecoration(
            border: Border.all(width: 5, color: theme.surfaceDim),
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          height: screenSize.height * 0.3,
          width: screenSize.width * 0.9,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: map.currentPosition!,
              initialZoom:
                  map.initialZoom, // You can adjust zoom for a better view
              maxZoom: 18.0,
              minZoom: 10.0,
              keepAlive: true, // Keeps the map widget alive for updates
              onTap: (tapPosition, point) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RunScreen(),
                  ),
                );
              },
            ),
            children: [
              buildTileLayer(mapVariant),
              buildPolylineLayer(map, theme),
              buildMarkerLayer(map, theme),
              Positioned(
                top: 10,
                left: 10,
                child: Card(
                  color: theme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      formatTime(map.secondsElapsed),
                      style: TextStyle(color: theme.onSecondaryContainer),
                    ),
                  ),
                ),
              )
            ],
          ),
        ).animate().fadeIn().then().shimmer();
      },
    );
  }
}
