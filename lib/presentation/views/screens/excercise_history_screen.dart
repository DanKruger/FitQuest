import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fitquest/presentation/viewmodels/excercise_viewmodel.dart';
import 'package:fitquest/presentation/views/screens/exercise_view_screen.dart';
import 'package:fitquest/presentation/widgets/exercise_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class ExcerciseHistoryScreen extends StatelessWidget {
  const ExcerciseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthViewmodel authViewmodel = Provider.of<AuthViewmodel>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Exercise History',
          style: TextStyle(fontSize: 19),
        ),
        forceMaterialTransparency: true,
        bottomOpacity: 0.5,
        leading: !authViewmodel.isConnected
            ? const Icon(Icons.wifi_off).animate().fadeIn(duration: 2000.ms)
            : const SizedBox(),
      ),
      body: Consumer<ExcerciseViewmodel>(
        builder: (context, model, child) {
          var theme = Theme.of(context).colorScheme;
          String variant =
              theme.brightness == Brightness.dark ? "dark" : "light";
          return FutureBuilder(
            future: model.getAllExercises(),
            builder: (context, AsyncSnapshot<List<ExerciseModel?>?> snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData) {
                return Center(
                    child: LoadingAnimationWidget.fallingDot(
                  color: theme.primary,
                  size: 50,
                ));
              }

              var data = snapshot.data!;
              if (data.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: SvgPicture.asset(
                          'assets/history_screen_$variant.svg',
                          semanticsLabel: 'Welcome to FitQuest',
                        ),
                      ),
                      const Text("You have no history, go run around a bit"),
                      TextButton(
                          onPressed: () {
                            model.sync();
                          },
                          child: const Text("Refresh"))
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  model.sync();
                },
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    var theme = Theme.of(context).colorScheme;
                    return Divider(color: theme.surfaceDim);
                  },
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: ExerciseListItem(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseViewScreen(
                                exerciseModel: data[index]!,
                              ),
                            ),
                          );
                        },
                        exerciseModel: data[index]!,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
