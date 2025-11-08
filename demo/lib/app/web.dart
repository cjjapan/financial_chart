import 'dart:js_interop';
import 'dart:ui_web';

import 'package:flutter/material.dart';

import '../chart_view.dart';
import '../multi_view_app.dart';

extension type ChartConfig._(JSObject _) implements JSObject {
  external ChartConfig(String name, String ticker, String theme);

  external String name;
  external String? ticker;
  external String? theme;
  external String? jsonConfig;
}
extension type ChartViewParam._(JSObject _) implements JSObject {
  external ChartViewParam(String name, String ticker, String theme);
  external factory ChartViewParam.onlyName(String name);

  external String name;
  external String? ticker;
  external String? theme;
  external JSObject? config;
}

void runTheApp() {
  runWidget(
    MultiViewApp(
      viewBuilder: (BuildContext context) {
        final int viewId = View.of(context).viewId;
        final data = views.getInitialData(viewId) as ChartViewParam?;
        if (data != null) {
          // Use the initial data to set up the view.
          print(
            "Chart view $viewId: ticker: ${data.ticker}, name: ${data.name}, theme: ${data.theme}, config: ${data.config}",
          );
        }
        return MaterialApp(
          title: null,
          home: ChartView(
            name: data?.name ?? "10_start",
            ticker: data?.ticker ?? "AAPL",
            theme: data?.theme ?? "light",
          ),
        );
      },
    ),
  );
}
