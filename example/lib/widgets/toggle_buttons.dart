import 'package:flutter/material.dart';

class AppToggleButtons<T> extends StatelessWidget {
  final List<T> items;
  final T? selected;
  final String Function(T)? labelResolver;
  final Function(T) onSelected;
  final double? minWidth;
  final double? maxWidth;
  final Axis direction;

  const AppToggleButtons({
    super.key,
    required this.items,
    this.selected,
    required this.onSelected,
    this.labelResolver,
    this.minWidth = 80,
    this.maxWidth = 160,
    this.direction = Axis.horizontal,
  });

  String _defaultLabelResolver(T item) => item.toString();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: direction,
      child: ToggleButtons(
        direction: direction,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        constraints: BoxConstraints(
          minHeight: 30.0,
          minWidth: minWidth ?? 80,
          maxHeight: 36,
          maxWidth: maxWidth ?? 160,
        ),
        onPressed: (index) {
          onSelected(items[index]);
        },
        isSelected: items.map((e) => selected == e).toList(),
        children: items
            .map((e) => Text((labelResolver ?? _defaultLabelResolver).call(e)))
            .toList(),
      ),
    );
  }
}

class AppToggleButtonsBoolean extends AppToggleButtons<bool> {
  const AppToggleButtonsBoolean({
    super.key,
    super.selected,
    required super.onSelected,
    String Function(bool)? labelResolver,
  }) : super(
         items: const [true, false],
         labelResolver: labelResolver ?? booleanLabelResolver,
       );

  static String booleanLabelResolver(bool item) {
    return item ? "true" : "false";
  }
}

class AppToggleButtonSingle extends AppToggleButtons<String> {
  AppToggleButtonSingle({
    required String label,
    required VoidCallback onSelected,
    bool selected = false,
    super.key,
  }) : super(
         selected: selected ? label : null,
         minWidth: 160,
         items: [label],
         onSelected: (_) {
           onSelected();
         },
       );
}
