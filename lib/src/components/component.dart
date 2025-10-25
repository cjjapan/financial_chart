import 'package:flutter/foundation.dart';

import '../values/value.dart';
import 'component_theme.dart';
import 'render.dart';

/// Base class for all visible components.
abstract class GComponent<T extends GComponentTheme> with Diagnosticable {
  static const int kDefaultLayer = 1000;

  /// Identifier of the component.
  ///
  /// Set it with a unique value if you want to access the component instance later by this id.
  final String? id;

  /// Label of the component.
  /// set this to allow the component to be identified by a label.
  final GValue<String?> _label;
  String? get label => _label.value;
  set label(String? value) => _label.value = value;
  GValue<String?> get labelNotifier => _label;

  /// Whether the component is visible.
  final GValue<bool> _visible;
  bool get visible => _visible.value;
  set visible(bool value) => _visible.value = value;
  GValue<bool> get visibleNotifier => _visible;

  /// The layer of the component. highest layer will be on the top.
  final GValue<int> _layer;
  int get layer => _layer.value;
  set layer(int value) => _layer.value = value;
  GValue<int> get layerNotifier => _layer;

  /// Whether the component is highlighted.
  final GValue<bool> _highlighted;
  bool get highlighted => _highlighted.value;
  set highlighted(bool value) => _highlighted.value = value;
  GValue<bool> get highlightedNotifier => _highlighted;

  /// Whether the component is selected.
  final GValue<bool> _selected;
  bool get selected => _selected.value;
  set selected(bool value) => _selected.value = value;
  GValue<bool> get selectedNotifier => _selected;

  /// Whether the component is locked.
  final GValue<bool> _locked;
  bool get locked => _locked.value;
  set locked(bool value) => _locked.value = value;
  GValue<bool> get lockedNotifier => _locked;

  /// The hit test mode of the component.
  ///
  /// see [GHitTestMode] for more details.
  final GValue<GHitTestMode> _hitTestMode = GValue<GHitTestMode>(
    GHitTestMode.border,
  );
  GHitTestMode get hitTestMode => _hitTestMode.value;
  set hitTestMode(GHitTestMode value) => _hitTestMode.value = value;
  GValue<GHitTestMode> get hitTestModeNotifier => _hitTestMode;

  bool get hitTestEnable => hitTestMode != GHitTestMode.none;

  /// Theme of the component to override the global default theme.
  final GValue<T?> _theme;
  T? get theme => _theme.value;
  set theme(T? value) => _theme.value = value;

  /// Render of the component.
  @protected
  GRender? render;

  GRender getRender() {
    return render!;
  }

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

/// Hit test mode of the component.
enum GHitTestMode {
  /// No hit test.
  none,

  /// Hit test the border lines of the component.
  border,

  /// Hit test the area of the component.
  area,

  /// border or area depending on the render result.
  auto,
}
