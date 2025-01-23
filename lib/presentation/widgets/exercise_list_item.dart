import 'package:fitquest/data/models/excercise_model.dart';
import 'package:fitquest/presentation/views/screens/run_screen.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExerciseListItem extends StatelessWidget {
  final void Function()? onTap;
  final ExerciseModel exerciseModel;
  const ExerciseListItem({
    super.key,
    required this.onTap,
    required this.exerciseModel,
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var theme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.none,
        width: screenSize.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.personRunning,
                    color: theme.primary,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relativeTimeString(exerciseModel.date),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        exerciseModel.type,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Duration",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(formatTime(exerciseModel.duration)),
                ],
              ),
              Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.start,
                children: [
                  const Text(
                    "Distance",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text("${exerciseModel.distance.floor().toString()} m"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDateTime(DateTime date) {
  return sprintf(
    "%02d %s %02d:%02d",
    [
      date.day,
      getMonth(date.month),
      date.hour,
      date.minute,
    ],
  );
}

String getMonth(int monthNum) {
  return {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December",
  }[monthNum]!;
}

String relativeTimeString(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 14) {
    return 'Last week';
  } else if (difference.inDays < 30) {
    return 'A few weeks ago';
  } else if (difference.inDays < 60) {
    return 'Last month';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 730) {
    return 'Last year';
  } else {
    return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
  }
}
