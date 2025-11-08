# Project Context

## Purpose
An interactive chart library for Flutter that supports various types of charts commonly used in financial applications. The library is designed to be high-performance, easily customizable, and extensible with support for OHLC, candlestick, line, area, bar, and stacked bar charts with real-time updates, zoom/pan functionality, and rich marker support.

**Key Goals:**
- Provide a production-ready charting solution for financial data visualization
- Enable easy extension with custom graph types and markers
- Support responsive interactions (zoom, pan, crosshair, tooltips)
- Deliver smooth animations and high performance with large datasets
- Offer comprehensive theming capabilities (dark/light presets)

## Tech Stack
- **Language:** Dart (SDK ^3.9.2)
- **Framework:** Flutter
- **Key Dependencies:**
  - `equatable` ^2.0.7 - Value equality
  - `vector_math` ^2.1.4 - Mathematical operations
  - `flutter_svg` ^2.2.1 - SVG rendering support
- **Development:**
  - `flutter_lints` ^6.0.0 - Linting rules
  - `flutter_test` - Testing framework
- **Documentation Site:** Astro (TypeScript/Node.js in `docs/` folder)
- **Demo Charts:** Flutter web build (in `docs/charts/`)

## Project Conventions

### Code Style
- **Linting:** Follows `package:flutter_lints/flutter.yaml` rules
- **Naming Conventions:**
  - All chart-related classes prefixed with `G` (e.g., `GChart`, `GPanel`, `GGraph`, `GAxis`)
  - Private fields use underscore prefix and expose via getters/setters with `GValue<T>` wrappers for reactive updates
  - Component themes end with `Theme` suffix (e.g., `GGraphBarTheme`)
  - Render classes end with `Render` suffix (e.g., `GGraphBarRender`)
- **Code Organization:**
  - Abstract base classes for extensibility (`GComponent<T>`, `GRender<C, T>`, `GGraph<T>`)
  - Use of mixins (`Diagnosticable`, `ChangeNotifier`) for Flutter integration
  - Enums for mode/strategy patterns (e.g., `GPointerScrollMode`, `GAxisPosition`)
- **Documentation:** Public APIs should have doc comments

### Architecture Patterns
- **Component-Based Architecture:**
  - Base `GComponent<T>` class for all visible components with theme support
  - Separate render classes (`GRender<C, T>`) handle painting logic
  - Components have properties like `id`, `label`, `visible`, `layer`, `highlighted`, `selected`, `locked`
- **Reactive State Management:**
  - `GValue<T>` wrapper class for reactive property updates
  - Extensive use of `ChangeNotifier` for state propagation
  - `DebounceHelper` for throttling rapid updates
- **Data Layer:**
  - `GDataSource<P, D>` manages chart data with series properties
  - `GData<P>` represents individual data points with point value and series values
  - Generic type parameters for flexibility
- **View Management:**
  - `GPointViewPort` - Horizontal viewport for scrolling/zooming data points
  - `GValueViewPort` - Vertical viewport for value ranges (supports linear/log scales)
  - Multiple viewports per panel for different value scales
- **Composition:**
  - `GChart` contains multiple `GPanel`s
  - Each `GPanel` contains graphs, axes, and markers
  - Resizable panels with `GSplitter` components
- **Extension Points:**
  - Custom graph types by extending `GGraph<T>` and implementing `GGraphRender<C, T>`
  - Custom markers by extending marker base classes
  - Custom themes by implementing theme interfaces

### Testing Strategy
- Unit tests for core functionality only (e.g., `axis_test.dart`)

### Git Workflow
- **Repository:** https://github.com/cjjapan/financial_chart
- **Issue Tracking:** GitHub Issues
- **Versioning:** Semantic versioning (currently v0.4.0)
- **Release:** Published to pub.dev (Flutter package registry)
- **Documentation:** Hosted on GitHub Pages at https://cjjapan.github.io/financial_chart/

## Domain Context
**Financial Charting Domain Knowledge:**
- **OHLC (Open-High-Low-Close):** Standard format for stock/financial data
- **Candlestick Charts:** Visual representation of OHLC data with colored bodies
- **Volume Charts:** Bar charts showing trading volume, typically below price charts
- **Time-Series Data:** Point values are typically timestamps (milliseconds since epoch)
- **Value Precision:** Different series require different decimal precision (price: 2, volume: 0)
- **Auto-Scaling:** Value viewports automatically adjust based on visible data range
- **Multi-Panel Layouts:** Common pattern to show price in top panel, volume in bottom panel
- **Real-Time Updates:** Support for live data updates with smooth transitions
- **Zoom/Pan Interactions:** Essential for exploring large time-series datasets
- **Crosshair & Tooltips:** Display precise values when hovering over data points

**Chart Component Hierarchy:**
```
GChart
└── GPanel (multiple)
    ├── GGraph (candlestick, line, area, bar, stacked bar)
    ├── GAxis (value and point axes, multiple per panel)
    ├── GMarker (labels, lines, arrows, callouts, shapes)
    └── Viewports (shared GPointViewPort, multiple GValueViewPorts)
```

## Important Constraints
- **Flutter SDK:** Minimum SDK version ^3.9.2
- **Performance:** Must handle large datasets (thousands of data points) with smooth animations
- **Platform Support:** Cross-platform (iOS, Android, Web, macOS, Linux, Windows)
- **Package Size:** Keep dependencies minimal for library consumers
- **API Stability:** Pre-1.0 version allows breaking changes but aim for consistency
- **License:** MIT License - permissive open source
- **Null Safety:** Dart null safety enabled

## External Dependencies
- **pub.dev:** Flutter package registry for distribution
- **GitHub Pages:** Hosting for documentation site
- **Yahoo Finance API:** Example data source used in demos (AAPL, GOOGL stock data)
- **Flutter SDK:** Core framework dependency
- **Dart SDK:** Language runtime
- **No Backend Services:** Library is client-side only, data loading is user's responsibility
