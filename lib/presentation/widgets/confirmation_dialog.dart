import 'package:fitquest/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    double outerBorderRadius = 15;
    double innerPadding = 10;
    double innerBorderRadius = outerBorderRadius - innerPadding;
    return Center(
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(outerBorderRadius)),
            color: theme.surface,
            child: Padding(
              padding: EdgeInsets.all(innerPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            style: squareButtonStyle(
                              innerBorderRadius,
                              theme,
                              orange: true,
                            ),
                            onPressed: onConfirm,
                            child: const Text('Confirm'),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
