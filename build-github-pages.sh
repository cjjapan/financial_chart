#!/bin/bash
set -e

echo "========================================"
echo "Building Financial Chart GitHub Pages"
echo "========================================"
echo ""

# Build demo (interactive chart demos)
echo "1/3 Building demo (chart demos)..."
cd demo
./build-web.sh
cd ..
echo "✓ Demo built successfully"
echo ""

# Build example (example app)
echo "2/3 Building example app..."
cd example
./build-web.sh
cd ..
echo "✓ Example app built successfully"
echo ""

# Build docs (Astro documentation site)
echo "3/3 Building documentation site..."
cd docs
npm install
npm run build
cd ..
echo "✓ Documentation site built successfully"
echo ""

echo "========================================"
echo "All builds complete!"
echo "========================================"
echo ""
echo "Output locations:"
echo "  - Demo:     docs/public/demo/"
echo "  - Examples: docs/public/examples/"
echo "  - Docs:     docs/dist/"
echo ""
echo "The complete site is ready in docs/dist/"
