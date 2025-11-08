import '../../components/components.dart';
import 'grids_render.dart';

/// Grid lines graph for displaying horizontal and vertical grid lines.
class GGraphGrids<T extends GGraphTheme> extends GGraph<T> {
  /// Type identifier for grid line graphs.
  static const String typeName = "grids";

  /// Ticker strategy for value axis grid lines.
  final GValueTickerStrategy valueTickerStrategy;

  /// Ticker strategy for point axis grid lines.
  final GPointTickerStrategy pointTickerStrategy;

  /// Creates a grid lines graph.
  GGraphGrids({
    super.id,
    super.label,
    super.layer,
    super.visible,
    super.valueViewPortId,
    this.valueTickerStrategy = const GValueTickerStrategyDefault(),
    this.pointTickerStrategy = const GPointTickerStrategyDefault(),
    super.hitTestMode = GHitTestMode.none,
    super.overlayMarkers,
    T? theme,
    super.render,
  }) {
    super.theme = theme;
    super.render = super.render ?? const GGraphGridsRender();
  }

  @override
  String get type => typeName;
}
