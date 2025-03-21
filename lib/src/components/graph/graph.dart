import '../../values/value.dart';
import '../render.dart';
import 'graph_render.dart';
import 'graph_theme.dart';
import '../component.dart';
import '../panel/panel.dart';
import '../marker/marker.dart';
import '../viewport_v.dart';

/// Base class for graph components.
///
/// This is not abstract so we can create a empty [GGraph] with only markers.
class GGraph<T extends GGraphTheme> extends GComponent {
  static const String typeName = 'graph';

  static const int kDefaultLayer = 1000;

  /// The layer of the graph. highest layer will be on the top.
  final GValue<int> _layer;
  int get layer => _layer.value;
  set layer(int value) => _layer.value = value;

  /// Whether the graph is highlighted (or selected).
  final GValue<bool> highlight = GValue<bool>(false);

  /// The value viewport id of the graph.
  ///
  /// see [GValueViewPort] for more details.
  /// point viewport is shared for the whole panel. see [GPanel.pointViewPortId]
  final String valueViewPortId;

  /// The hit test mode of the graph.
  ///
  /// see [HitTestMode] for more details.
  final GValue<HitTestMode> hitTestMode = GValue<HitTestMode>(
    HitTestMode.border,
  );

  final List<String> crosshairHighlightValueKeys = [];

  final List<GAxisMarker> _axisMarkers = [];
  final List<GGraphMarker> _graphMarkers = [];

  /// The axis markers of the graph.
  List<GAxisMarker> get axisMarkers => List.unmodifiable(_axisMarkers);

  /// The graph markers of the graph.
  List<GGraphMarker> get graphMarkers => List.unmodifiable(_graphMarkers);

  GGraph({
    String? id,
    required this.valueViewPortId,
    int layer = kDefaultLayer,
    super.visible,
    HitTestMode hitTestMode = HitTestMode.border,
    T? theme,
    GGraphRender? render,
    List<String>? crosshairHighlightValueKeys,
    List<GAxisMarker> axisMarkers = const [],
    List<GGraphMarker> graphMarkers = const [],
  }) : _layer = GValue<int>(layer),
       super(id: id, render: render, theme: theme) {
    this.hitTestMode(newValue: hitTestMode);
    if (axisMarkers.isNotEmpty) {
      _axisMarkers.addAll(axisMarkers);
    }
    if (graphMarkers.isNotEmpty) {
      _graphMarkers.addAll(graphMarkers);
    }
    if (crosshairHighlightValueKeys != null) {
      this.crosshairHighlightValueKeys.addAll(crosshairHighlightValueKeys);
    }
  }

  GAxisMarker? findAxisMarker(String id) {
    return _axisMarkers.where((marker) => marker.id == id).firstOrNull;
  }

  GGraphMarker? findGraphMarker(String id) {
    return _graphMarkers.where((marker) => marker.id == id).firstOrNull;
  }

  GMarker? findMarkerById(String id) {
    final axisMarker = findAxisMarker(id);
    if (axisMarker != null) {
      return axisMarker;
    }
    final graphMarker = findGraphMarker(id);
    if (graphMarker != null) {
      return graphMarker;
    }
    return null;
  }

  GAxisMarker? removeAxisMarkerById(String id) {
    final marker = findAxisMarker(id);
    if (marker != null) {
      _axisMarkers.remove(marker);
      return marker;
    }
    return null;
  }

  bool removeAxisMarker(GAxisMarker marker) {
    return _axisMarkers.remove(marker);
  }

  void addAxisMarker(GAxisMarker marker) {
    _axisMarkers.add(marker);
  }

  GGraphMarker? removeGraphMarkerById(String id) {
    final marker = findGraphMarker(id);
    if (marker != null) {
      _graphMarkers.remove(marker);
      return marker;
    }
    return null;
  }

  bool removeGraphMarker(GGraphMarker marker) {
    return _graphMarkers.remove(marker);
  }

  void addGraphMarker(GGraphMarker marker) {
    _graphMarkers.add(marker);
  }

  @override
  GRender getRender() {
    return render ?? const GGraphRender();
  }

  String get type => typeName;
}
