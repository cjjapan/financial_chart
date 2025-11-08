import 'package:flutter/foundation.dart';

import '../../values/value.dart';
import '../component.dart';
import 'splitter_render.dart';
import 'splitter_theme.dart';

/// Splitter component for resizing panels.
class GSplitter extends GComponent {
  final GValue<int?> _resizingPanelIndex = GValue(null);

  /// Gets the index of the panel currently being resized.
  int? get resizingPanelIndex => _resizingPanelIndex.value;

  /// Sets the index of the panel currently being resized.
  set resizingPanelIndex(int? value) => _resizingPanelIndex.value = value;

  /// Creates a splitter component.
  GSplitter({GSplitterTheme? theme, GSplitterRender? render})
    : super(render: render ?? const GSplitterRender(), theme: theme);

  @override
  debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<int?>('resizingPanelIndex', resizingPanelIndex),
    );
  }
}
