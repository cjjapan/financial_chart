import 'package:flutter/material.dart';
import 'button.dart';

class AppPopupMenu<T> extends StatelessWidget {
  final List<T> items;
  final T? selected;
  final String Function(T)? labelResolver;
  final Function(T) onSelected;

  const AppPopupMenu({
    super.key,
    required this.items,
    this.selected,
    required this.onSelected,
    this.labelResolver,
  });

  String _defaultLabelResolver(T item) => item.toString();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      //childFocusNode: _buttonFocusNode,
      menuChildren: items
          .map(
            (item) => MenuItemButton(
              onPressed: () => onSelected(item),
              child: Row(
                children: [
                  if (selected != null && selected == item)
                    const SizedBox(width: 24, child: Icon(Icons.check)),
                  if (selected != null && selected != item)
                    const SizedBox(width: 24),
                  const SizedBox(width: 8),
                  Text((labelResolver ?? _defaultLabelResolver).call(item)),
                ],
              ),
            ),
          )
          .toList(),
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return AppButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              text: (selected != null)
                  ? (labelResolver ?? _defaultLabelResolver).call(selected as T)
                  : '-',
            );
          },
    );
  }
}
