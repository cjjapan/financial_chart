<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

## Summary

An interactive chart library for Flutter.

--- 

## Features

- Supports OHLC, candlestick, line, area, bar, and stacked bar charts.
- Provides markers for graphs and axes, including labels, lines, arrows, callouts, shapes, and more.
- Easily extensible for custom graph types and markers.
- Resizable panels with support for multiple graphs and axes per panel.
- Supports both linear and logarithmic value axes.
- Displays tooltips and crosshair lines for data points.
- Zoom and pan functionality for axes and graphs and momentum scrolling supported.
- Animated transitions when zooming.
- Dynamic data loading with loading indicators.
- Real-time data and graph updates.
- Customizable themes with dark and light presets.

---

## Project Structure

```
financial_chart/                      # Project root
├── lib/                              # Main library folder
│   ├── financial_chart.dart          # Library entry point
│   ├── src/                          # Source code folder
├── example/                          # Example app project
│   ├── lib/                          # Example app source folder
├── docs/                             # Documentation site (built with Astro)
│   ├── src/                          # Documentation source folder
│   ├── charts/                       # Demo charts project for docs site (built with Flutter)
├── pubspec.yaml                      # Pub package config for main library
├── README.md                         # Project readme for library users
└── AGENTS.md                         # Guide for AI agents
```

