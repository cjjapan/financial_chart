# Development Guide

This guide provides instructions for developers working on the Financial Chart project.

## Project Structure

```
financial_chart/                     # Main Flutter library
├── lib/                             # Library source code
├── example/                         # Example Flutter app
├── demo/                            # Chart demos Flutter app (for documentation)
├── docs/                            # Documentation site (Astro)
│   ├── src/                         # Documentation source
│   ├── public/                      # Static assets
│   │   ├── demo/                    # Built demo app (generated)
│   │   └── examples/                # Built example app (generated)
│   └── dist/                        # Built documentation site (generated)
├── test/                            # Library tests
└── build-github-pages.sh            # Build script for GitHub Pages
```

## Prerequisites

- **Flutter SDK**: Version 3.24.0 or higher
- **Dart SDK**: Comes with Flutter
- **Node.js**: Version 20 or higher (for documentation site)
- **npm**: Comes with Node.js

## Setup

### 1. Install Flutter

Follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install) for your operating system.

Verify installation:
```bash
flutter --version
flutter doctor
```

### 2. Install Node.js

Download and install from [nodejs.org](https://nodejs.org/) or use a version manager like nvm:
```bash
# Using nvm (recommended)
nvm install 20
nvm use 20
```

### 3. Clone and Setup the Project

```bash
# Clone the repository
git clone https://github.com/cjjapan/financial_chart.git
cd financial_chart

# Install library dependencies
flutter pub get

# Install example app dependencies
cd example
flutter pub get
cd ..

# Install demo app dependencies
cd demo
flutter pub get
cd ..

# Install documentation dependencies
cd docs
npm install
cd ..
```

## Development Workflows

### Working on the Library

The main library code is in `lib/src/`. 

#### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/axis_test.dart

# Run tests with coverage
flutter test --coverage
```

#### Code Analysis
```bash
# Run static analysis
flutter analyze

# Fix common issues
dart fix --apply

# Format code
dart format .
```

### Working on the Example App

The example app demonstrates the library's features and is located in `example/`.

#### Running the Example App

```bash
cd example

# Run on Chrome (web)
flutter run -d chrome

# Run on macOS desktop
flutter run -d macos

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

#### Building the Example App

```bash
cd example

# Build for web
flutter build web --base-href "/financial_chart/examples/"

# Build for macOS
flutter build macos

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

### Working on the Demo App

The demo app contains interactive chart demos for the documentation site.

#### Running the Demo App

```bash
cd demo

# Run on Chrome
flutter run -d chrome

# Run on other platforms
flutter run -d macos
```

#### Building the Demo App

```bash
cd demo

# Build for documentation site
./build-web.sh

# Or manually
flutter build web --output ../docs/public/demo/ --base-href "/financial_chart/demo/" --release
```

### Working on Documentation

The documentation site is built with [Astro](https://astro.build/) and [Starlight](https://starlight.astro.build/).

#### Running Documentation Locally

```bash
cd docs

# Install dependencies (first time only)
npm install

# Start development server
npm run dev
```

The documentation site will be available at http://localhost:4321/financial_chart/

#### Building Documentation

```bash
cd docs

# Build the site
npm run build

# Preview the built site
npm run preview
```

#### Documentation Structure

```
docs/
├── src/
│   ├── content/
│   │   └── docs/           # Markdown documentation files
│   ├── components/         # Astro components
│   └── styles/             # Custom styles
├── public/
│   ├── demo/               # Built demo app (generated)
│   └── examples/           # Built example app (generated)
└── astro.config.mjs        # Astro configuration
```

## Building for GitHub Pages

### Build All Sites

Use the unified build script to build all sites at once:

```bash
# From project root
./build-github-pages.sh
```

This script will:
1. Build the demo app → `docs/public/demo/`
2. Build the example app → `docs/public/examples/`
3. Build the documentation site → `docs/dist/`

The final output in `docs/dist/` is ready for deployment to GitHub Pages.

### Build Individual Sites

```bash
# Build only demo
cd demo && ./build-web.sh && cd ..

# Build only example
cd example && ./build-web.sh && cd ..

# Build only docs
cd docs && npm run build && cd ..
```

### Preview the Complete Site

After building all sites:

```bash
cd docs
npm run preview
```

Visit http://localhost:4321/financial_chart/ to preview:
- Documentation: `/financial_chart/`
- Demo: `/financial_chart/demo/`
- Examples: `/financial_chart/examples/`

## Deployment

### Automated Deployment

The project uses GitHub Actions for automated deployment. On every push to `main`:

1. GitHub Actions runs `build-github-pages.sh`
2. Builds are uploaded to GitHub Pages
3. Site is deployed to https://cjjapan.github.io/financial_chart/

Configuration: `.github/workflows/deploy-pages.yml`

### Manual Deployment

You can also manually trigger the deployment:

1. Go to GitHub repository → Actions
2. Select "Deploy GitHub Pages" workflow
3. Click "Run workflow"


## Publishing to pub.dev

1. Update version in `pubspec.yaml` and update CHANGELOG.md
2. Run tests and ensure everything passes
3. Publish the package:
   ```bash
   dart pub publish
   ```

## Resources

- **Library Documentation**: https://cjjapan.github.io/financial_chart/
- **Flutter Documentation**: https://docs.flutter.dev/
- **Astro Documentation**: https://docs.astro.build/
- **Starlight Documentation**: https://starlight.astro.build/
