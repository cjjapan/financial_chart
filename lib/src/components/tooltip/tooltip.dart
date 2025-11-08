import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../values/value.dart';
import '../components.dart';

/// Position options for tooltips.
enum GTooltipPosition {
  /// No tooltip displayed.
  none,

  /// Tooltip at the top left corner.
  topLeft,

  /// Tooltip at the bottom left corner.
  bottomLeft,

  /// Tooltip at the top right corner.
  topRight,

  /// Tooltip at the bottom right corner.
  bottomRight,

  /// Tooltip follows the pointer position.
  followPointer,
}

/// Builder function for creating custom tooltip widgets.
typedef GToolTipWidgetBuilder =
    Widget Function(
      BuildContext context,
      Size maxSize,
      GTooltip tooltip,
      int point,
    );

/// Context information for tooltip widget rendering.
class GToolTipWidgetContext extends Equatable {
  /// The panel containing the tooltip.
  final GPanel panel;

  /// The render area for the tooltip.
  final Rect area;

  /// The tooltip component.
  final GTooltip tooltip;

  /// The data point index.
  final int point;

  /// The anchor position for the tooltip.
  final Offset anchorPosition;

  /// Creates a tooltip widget context.
  const GToolTipWidgetContext({
    required this.panel,
    required this.area,
    required this.tooltip,
    required this.point,
    required this.anchorPosition,
  });

  @override
  List<Object?> get props => [
    area,
    point,
    Offset(
      anchorPosition.dx.round().toDouble(),
      anchorPosition.dy.round().toDouble(),
    ),
  ];
}

/// Tooltip component for displaying data point information.
class GTooltip extends GComponent {
  final GValue<GTooltipPosition> _position;

  /// Gets the tooltip position.
  GTooltipPosition get position => _position.value;

  /// Sets the tooltip position.
  set position(GTooltipPosition value) => _position.value = value;

  /// Data keys to display in the tooltip.
  final List<String> dataKeys;

  final GValue<bool> _showPointValue;

  /// Gets whether to show point values in the tooltip.
  bool get showPointValue => _showPointValue.value;

  /// Sets whether to show point values in the tooltip.
  set showPointValue(bool value) => _showPointValue.value = value;

  /// Value key to follow when position is followPointer.
  final GValue<String?> _followValueKey;

  /// Gets the value key to follow for tooltip positioning.
  String? get followValueKey => _followValueKey.value;

  /// Sets the value key to follow for tooltip positioning.
  set followValueKey(String? value) => _followValueKey.value = value;

  final GValue<String?> _followValueViewPortId;

  /// Gets the viewport ID to follow for tooltip positioning.
  String? get followValueViewPortId => _followValueViewPortId.value;

  /// Sets the viewport ID to follow for tooltip positioning.
  set followValueViewPortId(String? value) =>
      _followValueViewPortId.value = value;

  final GValue<bool> _pointLineHighlightVisible;

  /// Gets whether the point line highlight is visible.
  bool get pointLineHighlightVisible => _pointLineHighlightVisible.value;

  /// Sets whether the point line highlight is visible.
  set pointLineHighlightVisible(bool value) =>
      _pointLineHighlightVisible.value = value;

  final GValue<bool> _valueLineHighlightVisible;

  /// Gets whether the value line highlight is visible.
  bool get valueLineHighlightVisible => _valueLineHighlightVisible.value;

  /// Sets whether the value line highlight is visible.
  set valueLineHighlightVisible(bool value) =>
      _valueLineHighlightVisible.value = value;

  ValueNotifier<GToolTipWidgetContext?>? _tooltipNotifier;

  /// Gets the notifier for tooltip widget updates.
  ValueNotifier<GToolTipWidgetContext?>? get tooltipNotifier =>
      _tooltipNotifier;

  final GValue<GToolTipWidgetBuilder?> _tooltipWidgetBuilder;

  /// Gets the custom tooltip widget builder.
  GToolTipWidgetBuilder? get tooltipWidgetBuilder =>
      _tooltipWidgetBuilder.value;

  /// Sets the custom tooltip widget builder.
  set tooltipWidgetBuilder(GToolTipWidgetBuilder? value) {
    _tooltipWidgetBuilder.value = value;
    if (value != null) {
      _tooltipNotifier ??= ValueNotifier<GToolTipWidgetContext?>(null);
    } else {
      _tooltipNotifier?.dispose();
      _tooltipNotifier = null;
    }
  }

  /// Creates a tooltip component.
  GTooltip({
    GTooltipPosition position = GTooltipPosition.followPointer,
    bool showPointValue = true,
    this.dataKeys = const [],
    String? followValueKey,
    String? followValueViewPortId,
    bool pointLineHighlightVisible = true,
    bool valueLineHighlightVisible = true,
    super.render = const GTooltipRender(),
    super.theme,
    GToolTipWidgetBuilder? tooltipWidgetBuilder,
  }) : _position = GValue<GTooltipPosition>(position),
       _showPointValue = GValue<bool>(showPointValue),
       _followValueKey = GValue<String?>(followValueKey),
       _followValueViewPortId = GValue<String?>(followValueViewPortId),
       _pointLineHighlightVisible = GValue<bool>(pointLineHighlightVisible),
       _valueLineHighlightVisible = GValue<bool>(valueLineHighlightVisible),
       _tooltipWidgetBuilder = GValue<GToolTipWidgetBuilder?>(
         tooltipWidgetBuilder,
       ) {
    if (tooltipWidgetBuilder != null) {
      _tooltipNotifier = ValueNotifier<GToolTipWidgetContext?>(null);
    } else {
      _tooltipNotifier = null;
    }
  }

  void dispose() {
    _tooltipNotifier?.dispose();
  }
}
