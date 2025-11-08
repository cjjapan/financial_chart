import 'package:flutter/foundation.dart';

import '../values/value.dart';
import 'component_theme.dart';
import 'render.dart';

/// Base class for all visible chart components.
abstract class GComponent<T extends GComponentTheme> with Diagnosticable {
  /// Default layer value for components.
  static const int kDefaultLayer = 1000;

  /// Unique identifier for the component.
  final String? id;

  final GValue<String?> _label;

  /// Gets the label of the component.
  String? get label => _label.value;

  /// Sets the label of the component.
  set label(String? value) => _label.value = value;

  /// Gets the label value notifier.
  GValue<String?> get labelNotifier => _label;

  final GValue<bool> _visible;

  /// Gets whether the component is visible.
  bool get visible => _visible.value;

  /// Sets whether the component is visible.
  set visible(bool value) => _visible.value = value;

  /// Gets the visibility value notifier.
  GValue<bool> get visibleNotifier => _visible;

  final GValue<int> _layer;

  /// Gets the layer of the component (higher layers appear on top).
  int get layer => _layer.value;

  /// Sets the layer of the component.
  set layer(int value) => _layer.value = value;

  /// Gets the layer value notifier.
  GValue<int> get layerNotifier => _layer;

  final GValue<bool> _highlighted;

  /// Gets whether the component is highlighted.
  bool get highlighted => _highlighted.value;

  /// Sets whether the component is highlighted.
  set highlighted(bool value) => _highlighted.value = value;

  /// Gets the highlighted value notifier.
  GValue<bool> get highlightedNotifier => _highlighted;

  final GValue<bool> _selected;

  /// Gets whether the component is selected.
  bool get selected => _selected.value;

  /// Sets whether the component is selected.
  set selected(bool value) => _selected.value = value;

  /// Gets the selected value notifier.
  GValue<bool> get selectedNotifier => _selected;

  final GValue<bool> _locked;

  /// Gets whether the component is locked.
  bool get locked => _locked.value;

  /// Sets whether the component is locked.
  set locked(bool value) => _locked.value = value;

  /// Gets the locked value notifier.
  GValue<bool> get lockedNotifier => _locked;

  final GValue<GHitTestMode> _hitTestMode = GValue<GHitTestMode>(
    GHitTestMode.border,
  );

  /// Gets the hit test mode of the component.
  GHitTestMode get hitTestMode => _hitTestMode.value;

  /// Sets the hit test mode of the component.
  set hitTestMode(GHitTestMode value) => _hitTestMode.value = value;

  /// Gets the hit test mode value notifier.
  GValue<GHitTestMode> get hitTestModeNotifier => _hitTestMode;

  /// Gets whether hit testing is enabled.
  bool get hitTestEnable => hitTestMode != GHitTestMode.none;

  final GValue<T?> _theme;

  /// Gets the theme of the component.
  T? get theme => _theme.value;

  /// Sets the theme of the component.
  set theme(T? value) => _theme.value = value;

  /// The renderer for the component.
  @protected
  GRender? render;

  /// Gets the renderer for the component.
  GRender getRender() {
    return render!;
  }

  /// Creates a component.
  GComponent({
    this.id,
    String? label,
    bool visible = true,
    bool highlighted = false,
    bool selected = false,
    bool locked = false,
    int layer = kDefaultLayer,
    GHitTestMode hitTestMode = GHitTestMode.auto,
    T? theme,
    this.render,
  }) : _label = GValue<String?>(label),
       _theme = GValue<T?>(theme),
       _visible = GValue<bool>(visible),
       _highlighted = GValue<bool>(highlighted),
       _selected = GValue<bool>(selected),
       _locked = GValue<bool>(locked),
       _layer = GValue<int>(layer);

  @override
  @mustCallSuper
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<String>('id', id));
    properties.add(IntProperty('layer', layer));
    properties.add(DiagnosticsProperty<bool>('visible', visible));
    properties.add(DiagnosticsProperty<bool>('selected', selected));
    properties.add(DiagnosticsProperty<bool>('locked', locked));
    properties.add(DiagnosticsProperty<bool>('highlighted', highlighted));
    properties.add(EnumProperty<GHitTestMode>('hitTestMode', hitTestMode));
  }
}

/// Hit test mode for components.
enum GHitTestMode {
  /// No hit testing.
  none,

  /// Hit test border lines only.
  border,

  /// Hit test the entire area.
  area,

  /// Automatic selection based on rendering.
  auto,
}
