import 'package:flutter/foundation.dart';

import '../values/value.dart';
import 'component_theme.dart';
import 'render.dart';

/// Base class for all view components.
abstract class GComponent {
  /// Identifier of the component.
  ///
  /// Set it with a unique value if you want to access the component instance later by this id.
  final String? id;

  /// Theme of the component to override the global default theme.
  final GValue<GComponentTheme?> _theme;
  GComponentTheme? get theme => _theme();
  set theme(GComponentTheme? value) => _theme(newValue: value);

  /// Whether the graph is visible.
  final GValue<bool> _visible;
  bool get visible => _visible();
  set visible(bool value) => _visible(newValue: value);

  /// Render of the component.
  @protected
  GRender? render;

  GComponent({
    this.id,
    bool visible = true,
    this.render,
    GComponentTheme? theme,
  }) : _theme = GValue<GComponentTheme?>(theme),
       _visible = GValue<bool>(visible);

  GRender getRender() {
    return render!;
  }
}

/// Hit test mode of the component.
enum HitTestMode {
  /// No hit test.
  none,

  /// Hit test the border lines of the component.
  border,

  /// Hit test the area of the component.
  area,
}
