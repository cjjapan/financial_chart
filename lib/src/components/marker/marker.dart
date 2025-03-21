import '../../values/coord.dart';
import '../../values/range.dart';
import '../../values/value.dart';
import '../component.dart';
import 'marker_render.dart';
import 'marker_theme.dart';

/// Base class for markers.
class GMarker extends GComponent {
  static const int kDefaultLayer = 1000;

  /// The layer of the marker. highest layer will be on the top.
  final GValue<int> layer = GValue<int>(kDefaultLayer);

  GMarker({
    super.id,
    super.visible = true,
    super.theme,
    super.render,
    int layer = kDefaultLayer,
  }) {
    this.layer(newValue: layer);
  }

  @override
  GMarkerRender<GMarker, GMarkerTheme> getRender() {
    return super.getRender() as GMarkerRender<GMarker, GMarkerTheme>;
  }
}

/// Markers on the axis.
class GAxisMarker extends GMarker {
  /// render a label for each of the [values] on value axis.
  final List<double> values;

  /// render a label for each of the [points] on point axis.
  final List<int> points;

  /// render a range for each of the [valueRanges] on value axis.
  final List<GRange> valueRanges;

  /// render a range for each of the [pointRanges] on point axis.
  final List<GRange> pointRanges;

  GAxisMarker({
    super.id,
    super.visible,
    super.theme,
    super.render = const GAxisMarkerRender(),
    this.values = const [],
    this.points = const [],
    this.valueRanges = const [],
    this.pointRanges = const [],
    super.layer,
  });
}

/// Base class for Marker on the graph.
abstract class GGraphMarker extends GMarker {
  /// Key points decides the shape of the marker.
  final List<GCoordinate> keyCoordinates;

  /// Control points allow to adjust the shape of the marker interactively.
  List<GCoordinate> controlCoordinates = [];

  GGraphMarker({
    super.id,
    super.theme,
    super.render,
    this.keyCoordinates = const [],
    super.layer,
  });

  @override
  GGraphMarkerRender<GGraphMarker, GGraphMarkerTheme> getRender() {
    return super.getRender()
        as GGraphMarkerRender<GGraphMarker, GGraphMarkerTheme>;
  }
}
