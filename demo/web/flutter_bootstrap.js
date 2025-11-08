{{flutter_js}}
{{flutter_build_config}}

let _flutterActiveViews = [];

class ChartViewParam {
  constructor(name, ticker, theme, config) {
    this.name = name;
    this.ticker = ticker;
    this.theme = theme || "light";
    this.config = config || `{
      "chartType": "line",
      "showLegend": true,
      "showGrid": true,
      "showTooltip": true,
      "showTitle": true,
      "title": name,
      "xAxisLabel": "Time",
      "yAxisLabel": "Price",
    }`;
  }
}

function _recreateFlutterViews(app, theme) {
  for(const viewId of _flutterActiveViews) {
    app.removeView(viewId);
  }
  _flutterActiveViews = [];
  const chartViews = document.querySelectorAll("div.f-chart");
  for (const chartView of chartViews) {
    const name = chartView.getAttribute("data-chart-name");
    const ticker = chartView.getAttribute("data-chart-ticker");
    if (name) {
      const viewId = app.addView({
        hostElement: chartView,
        initialData: new ChartViewParam(name, ticker, theme),
      });
      _flutterActiveViews.push(viewId);
    }
  }
}

function _listenToThemeChange(app) {
  const target = document.querySelector("html");
  if (target) {
    _recreateFlutterViews(app, target.getAttribute("data-theme") || "light");
    var observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        if (mutation.type === "attributes" && mutation.attributeName === "data-theme") {
          _recreateFlutterViews(app, target.getAttribute("data-theme"));
        }
      });
    });
    observer.observe(target, { attributes: true });
  }
}

_flutter.loader.load({
  config: {
    entryPointBaseUrl: '/financial_chart/demo',
    /*entrypointUrl: "/main.dart.js",
    serviceWorker: {
      serviceWorkerVersion: 1,
      serviceWorkerUrl: "/flutter_service_worker.js?v=",
    },*/
  },
  onEntrypointLoaded: async function onEntrypointLoaded(engineInitializer) {
  let engine = await engineInitializer.initializeEngine({
    multiViewEnabled: true,
    assetBase: '/financial_chart/demo/',
  });
  let app = await engine.runApp();
  _listenToThemeChange(app);
  }
});