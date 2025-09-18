import 'package:flutter/material.dart';

class ControlLabel extends StatelessWidget {
  final String label;
  final String? title;
  final String description;

  const ControlLabel({
    super.key,
    required this.label,
    this.title,
    this.description = '',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: description.isEmpty
          ? null
          : () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    title: Text(
                      title ?? label,
                      style: const TextStyle(fontSize: 16),
                    ),
                    content: Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                    ),
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
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        margin: const EdgeInsets.all(0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text(label),
              const Expanded(child: SizedBox.shrink()),
              if (description.isNotEmpty)
                const Icon(Icons.info_outline, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
