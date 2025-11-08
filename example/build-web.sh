#!/bin/bash
set -e

echo "Building example app for GitHub Pages..."
flutter build web --output ../docs/public/examples/ --base-href "/financial_chart/examples/" --release
echo "Example app built successfully to ../docs/public/examples/"
