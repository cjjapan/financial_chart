import '../chart.dart';
import '../values/range.dart';
import 'panel/panel.dart';
import 'viewport_h.dart';

/// Auto scale strategy for point [GPointViewPort].
abstract class GPointViewPortAutoScaleStrategy {
  GRange getScale({
    required GChart chart,
    required GPanel panel,
    required GPointViewPort pointViewPort,
  });
}

/// Auto scale strategy to let last point at the end (right) of graph area and point width is [GPointViewPort.defaultPointWidth].
class GPointViewPortAutoScaleStrategyLatest
    implements GPointViewPortAutoScaleStrategy {
  final int endSpacingPoints;
  const GPointViewPortAutoScaleStrategyLatest({this.endSpacingPoints = 2});
  @override
  GRange getScale({
    required GChart chart,
    required GPanel panel,
    required GPointViewPort pointViewPort,
  }) {
    final dataSource = chart.dataSource;
    double lastPoint =
        ((dataSource.isEmpty && pointViewPort.isValid)
            ? pointViewPort.endPoint
            : dataSource.lastPoint.toDouble()) +
        endSpacingPoints;
    int viewPointCount =
        (panel.graphArea().width / pointViewPort.defaultPointWidth).ceil();
    return GRange.range(
      (lastPoint - viewPointCount).toDouble(),
      lastPoint.toDouble(),
    );
  }
}

/// Auto scale strategy that keeps [alignToPosition] and updates start & end to make point width be [GPointViewPort.defaultPointWidth].
class GPointViewPortAutoScaleStrategyAlignTo
    implements GPointViewPortAutoScaleStrategy {
  /// The position to align to.
  ///
  /// When it is null, will calculate from current pointer position each time.
  /// The value should be a range from 0 ~ 1 while 0 means start (left) and 1 is end(right) of the viewPort.
  final double? alignToPosition;
  const GPointViewPortAutoScaleStrategyAlignTo({this.alignToPosition})
    : assert(
        (alignToPosition == null) ||
            (alignToPosition >= 0 && alignToPosition <= 1),
      );
  @override
  GRange getScale({
    required GChart chart,
    required GPanel panel,
    required GPointViewPort pointViewPort,
  }) {
    final dataSource = chart.dataSource;
    int viewPointCount =
        (panel.graphArea().width / pointViewPort.defaultPointWidth).ceil();
    if (dataSource.isEmpty) {
      return GRange.range(pointViewPort.startPoint, pointViewPort.endPoint);
    }
    if (!pointViewPort.isValid || chart.crosshair.crossPosition.isEmpty) {
      double lastPoint = dataSource.lastPoint + 1;
      return GRange.range(lastPoint - viewPointCount, lastPoint);
    }
    double position =
        alignToPosition ??
        (chart.crosshair.crossPosition.begin! - panel.graphArea().left) /
            panel.graphArea().width;
    double alignToPoint =
        pointViewPort.startPoint +
        (pointViewPort.endPoint - pointViewPort.startPoint) * position;
    return GRange.range(
      alignToPoint - viewPointCount * position,
      alignToPoint + viewPointCount * (1 - position),
    );
  }
}
