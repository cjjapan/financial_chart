import 'package:flutter/material.dart';

class AppLabelWidget extends StatelessWidget {
  final String label;
  final String? description;
  final Widget child;

  const AppLabelWidget({
    super.key,
    required this.label,
    this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 2,
        children: [
          TextButton.icon(
            onPressed: (description == null || description?.isEmpty == true)
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(description!),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
            icon: (description == null || description?.isEmpty == true)
                ? null
                : const Icon(Icons.help_outline, size: 14),
            iconAlignment: IconAlignment.end,
            label: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 20),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
