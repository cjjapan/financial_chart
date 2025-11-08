## 0.4.0
2025-11-08
- Add `GGraphBar`.`basePosition` property to allow customize base position of bar graph.
- Add new graph type `GGraphStackedBar` for stacked bar graph.
- Update workshop demo.
- Minor bug fix.

## 0.3.8
2025-10-25
- Add `**Notifier` getters to properties of `GComponent` to allow listen updates.

## 0.3.7
2025-10-15
- fix scaling issue of `GValueViewPort` with logarithmic scale when panning.

## 0.3.6
2025-10-11
- add more markers.
  + `GArrowLineMarker` - arrow line with customizable arrow heads at start and end.
  + `GStatsLineMarker` - statistical line marker that extends `GArrowLineMarker` with value statistics.
  + `GCrosslineMarker` - crossline marker for marking horizontal and vertical lines.
  + `GCalloutMarker` - callout/annotation marker with pointer.
  + `GFibRetracementMarker` - Fibonacci retracement marker.
  + `GFibCircleMarker` - Fibonacci circle marker.
  + `GFibArcMarker` - Fibonacci arc marker.
  + `GFibResistanceFanMarker` - Fibonacci resistance fan marker.
  + `GFibTimeZoneMarker` - Fibonacci timezone marker.
- **[breaking change]** deprecate `GArrowMarker` in favor of `GArrowLineMarker`.
- update workshop demo to include new markers.

## 0.3.5
2025-09-18
- sdk version up.
- add `GValueViewPort`.`scaleType` to support logarithmic price scale.
- add `GSvgMarker` overlay marker.
- add screenshot.
- minor fix.

## 0.3.4
2025-07-26
- add documentation link.

## 0.3.3 
2025-06-30 
- add `GPanel`.`onSecondaryTapGraphArea` callback.
- add `selected`, `locked`, `label` properties to `GComponent` and rename `highlight` to `highlighted`.
- add `GGraph`.`clearMarkers`, `hitTestOverlayMarkers` methods.
- rename `GGraph`.`drawHighlightMarks` method to `drawGraphHighlightMarks`.
- add `GPanel`.`hitTestGraphs` method.
- add `GHitTestMode`.`auto` enum value.
- add `GCoordinate`.`copyByPosition` method.
- add `GSize`.`copyFromViewSize` method.
- add `GPositionCoordinate`.`xIsInverted`, `yIsInverted` property.
- add `GChart`.`printDebugPaintCount` property.
- change return value of `GChart`.`hitTestPanelGraphs`method.
- refactor overlay markers. 
  + add hitTest logic for overlay markers.
  + draw control handles for `GOverlayMarker`.
  + **[breaking change]** rename class `GLineMarker` to `GPolyLineMarker`.
  + **[breaking change]** change `GArcMarker`.`close` property to `closeType`.
  + add `scaleHandler` property to `GOverlayMarker`.
  + add `controlHandleThemes` property to `GOverlayMarkerTheme` and remove `controlPointsStyle`.
- update workshop demo to add `Markers` tab.

## 0.3.2
2025-05-27
- skip rendering of `double.nan` and `double.infinite` values for area and line graphs.
- skip rendering of resizing splitters when scaling the viewport.
- fix candlestick graph rendering issue when open and close values are very close.

## 0.3.1
2025-05-25
- fix wrong rendering for some edge cases of area graph.
- fix graph highlight markers being drawn outside of the graph area issue.
- fix animation error after disposed.
- add `GDataSource`.`dataLoadMargin` to allow load more data than necessary to reduce data requests.
- rename `GValueViewPort`.`minValueRange`, `maxValueRange` to `minRangeSize`, `maxRangeSize`.
- remove `yahoo_finance_data_reader` dependency from example.

## 0.3.0
2025-05-22
- fix interaction fail to work when resize. (issue [#49](https://github.com/cjjapan/financial_chart/issues/49)).
- add `GCrosshair`.`updateStrategy` property to allow customize when to show/hide crosshair. (issue [#51](https://github.com/cjjapan/financial_chart/issues/51)).
- add `GDataSeriesProperty`.`valueFormater` property.
- add `GPanel`.`onLongPressStartGraphArea`, `onLongPressMoveGraphArea`, `onLongPressEndGraphArea` callbacks.
- add `Diagnosticable` implementation to components.
- add `GDataSource`.`dataLoaded` callback to allow do something else on updated data before rendering.
- update examples with new async data loading logic. (issue [#50](https://github.com/cjjapan/financial_chart/issues/50)).

## 0.2.8
2025-05-14
- fix tap issue.
- add `GDataSource`.`addSeries`, `GDataSource`.`removeSeries` methods.
- add `GChart`.`addPanel` and `GChart`.`removePanel` methods.
- fix tooltip area top position issue.

## 0.2.7
2025-05-13
- fix interaction issues.
- pinch to zoom improvement on graph area.
- fix dataLoader not being called in some cases.

## 0.2.6
2025-05-11
- fix viewport's `resizeMode` not working correctly when resizing by splitter.
- fix resizing issue when there are more than two panels or any invisible panels.
- update examples 'workshop' to add 'add / remove' a panel.

## 0.2.5
2025-05-10
- refactor interactions.
  + **[breaking change]** remove `GChartWidget`.`onTapXX` callbacks. use `onPointerDown`, `onPointerUp` instead.
  + gesture handling improvement and fix gesture conflicts with other scrollable widget (issue [#41](https://github.com/cjjapan/financial_chart/issues/41)).
  + hide interaction methods for internal use only.
- refactor examples to add workshop example.
- draw selection area on `GGridGraph` when selecting on axes.
- draw selected range labels on axes when selecting on axes.
- fix ohlc graph render issue when open has same value as close (issue [#42](https://github.com/cjjapan/financial_chart/issues/42)).
- [0.2.5+1] add `GPanel`.`onTapGraphArea` and `GPanel`.`onDoubleTapGraphArea` callbacks.

## 0.2.4
2025-04-27
- add `GGraphLine`.`smoothing`.
- update example for `GToolTip`.`tooltipWidgetBuilder`.
- minor fix.

## 0.2.3
2025-04-25
- use batch drawing when possible to improve performance.
- add `GToolTip`.`tooltipWidgetBuilder` property to allow use custom widget as tooltip.
- add `GChart`.`hitTestEnable` property to allow disable hit testing globally.
- fix issue of highlight markers drawn outside the graph area.
- code refactoring.

## 0.2.2
2025-04-22
- **[breaking change]** code refactoring.
  + remove `GGraphAreaTheme`.`styleValueAboveLine` and `styleValueBelowLine`.
  + rename `GGraphAreaTheme`.`styleAboveArea`, `styleAboveArea` to `styleAboveBase`, `styleBelowBase`.
  + move `GGraph`.`layer`, `hitTestMode`, `highlight` to parent `GComponent` class.
  + remove `GGraphOhlcTheme`.`lineStyleMinus` and `lineStylePlus`.
  + remove `PaintStyle`.`elevation` and `shadowColor`.
- draw point value label (time string) to tooltip.
- fix notifyListeners error after disposed.
- add `autoScaleFlg` to `GPointViewPort` (fix issue [#34](https://github.com/cjjapan/financial_chart/issues/34)).
- update examples.  

## 0.2.1
2025-04-16
- **[breaking change]** code refactoring.
  + rename `HitTestMode` to `GHitTestMode`.
  + rename `GChartController` to `GChartInteractionHandler`.
  + rename `ViewSizeConvertor` to `GViewSizeConvertor`.
  + rename `GPointAxisMarker`.`point` to `labelPoint`.
  + remove `GValue`.`call()`.
- add `resizeMode` to `GPointViewPort` and `GValueViewPort` to allow config the behavior when resizing.
- allow update graph properties (added setters).
- fix notifyListeners error after disposed.
- update examples.
- [0.2.1+1] code format & update examples.
- [0.2.1+2] property name `viewPortResizeMode` -> `resizeMode` and add to constructor.

## 0.2.0
2025-04-12
- **[breaking change]** refactor markers  
  + rename `GGraphMarker` to `GOverlayMarker` so it can be also added to axes.
  + remove `GGraph.axisMarkers` property and rename `GGraph.graphMarkers` property to `GGraph.overlayMarkers`. 
  + add `GAxis.axisMarkers` and `GAxis.overlayMarkers` properties.
  + update `GTheme` marker properties.
- fix rendering label with rotation.
- update Markers and Live examples.

## 0.1.8
2025-04-10
- fix issue `GChartWidget` not working correctly after `chart` object being recreated.
- add `GPanel.graphPanMode` property to allow disable panning graph.
- add `GPointViewPort.startPointMin`, `GPointViewPort.endPointMax` properties to allow range restriction.
- remove dependency `intl` and `path_drawing` to reduce dependency conflict.
- update Panels example.

## 0.1.7
2025-04-07
- fix mouse cursor for splitter
- fix for an issue in example dependency
- add `GPanel.positionToViewPortCoord()`
- update examples

## 0.1.6
2025-04-01  
- add mouse cursor support
- fix basic example
- refactoring

## 0.1.5
2025-03-28  
- expose GChartWidget.onTapXX callbacks
- add `GChart.hitTestGraph()`, `GChart.saveAsImage()`
- change `GChart.preRender()`, `GChart.postRender()` callbacks
- allow default valueViewPortId
- update examples
- [0.1.5+1] expose `GChartWidget`.`onPointerDown`, `onPointerUp`

## 0.1.4
2025-03-23
- bug fix
- update examples

## 0.1.3
2025-03-22
- bug fix
- Add live update demo 

## 0.1.2
2025-03-20
- Add feature for issue #2: add momentum scrolling
- Add feature for issue #3: allow zooming in/out with mouse wheel
- [0.1.2+1] Update for issue #3: fix zoom center point
- [0.1.2+2] Change src files layout 

2025-03-21
- [0.1.2+3] Fix for issue #3: fix zoom center point
- [0.1.2+4] Fix for issue #2: Add GPanel.momentumScrollSpeed option

## 0.1.1
2025-03-15
- Minor changes
- [0.1.1+1] Fix for linting
- [0.1.1+2] Fix for linting

## 0.1.0
2025-03-15
- First release
