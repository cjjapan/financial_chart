import '../../components/components.dart';
import 'grids_render.dart';

/// Grid lines
class GGraphGrids<T extends GGraphTheme> extends GGraph<T> {
  static const String typeName = "grids";

  /// The value ticker strategy to decide the grid lines along value axis.
  final GValueTickerStrategy valueTickerStrategy;

  /// The horizontal ticker strategy to decide the grid lines along point axis.
  final GPointTickerStrategy pointTickerStrategy;

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
