import 'dart:ui';

import '../components.dart';

enum GControlHandleType { view, move, resize, align, reshape }

class GControlHandle {
  final GControlHandleType type;
  final Offset position;
  final int? keyCoordinateIndex;
  final Object? extraData;

  GControlHandle({
    this.type = GControlHandleType.view,
    required this.position,
    this.keyCoordinateIndex,
    this.extraData,
  });
}

/// Base class for rendering a [GOverlayMarker].
abstract class GOverlayMarkerRender<
  M extends GOverlayMarker,
  T extends GOverlayMarkerTheme
>
    extends GMarkerRender<M, T> {
  GOverlayMarkerRender();

  Map<String, GControlHandle> controlHandles = {};

  void drawControlHandles({
    required Canvas canvas,
    required M marker,
    required T theme,
    required Rect area,
    required GValueViewPort valueViewPort,
    required GPointViewPort pointViewPort,
  }) {
    if (controlHandles.isEmpty) {
      return;
    }
    if (!(marker.highlighted || marker.selected)) {
      return;
    }
    final entries = controlHandles.entries.toList();
    for (int i = entries.length - 1; i >= 0; i--) {
      final handleEntry = entries[i];
      final handle = handleEntry.value;
      final handleTheme = theme.getControlHandleTheme(
        marker.scaleHandler == null ? GControlHandleType.view : handle.type,
      );
      final rect = Rect.fromCenter(
        center: handle.position,
        width: handleTheme.size,
        height: handleTheme.size,
      );
      switch (handleTheme.shape) {
        case GControlHandleShape.circle:
          drawPath(
            canvas: canvas,
            path: Path()..addOval(rect),
            style: handleTheme.style,
          );
          break;
        case GControlHandleShape.square:
          drawPath(
            canvas: canvas,
            path: Path()..addRect(rect),
            style: handleTheme.style,
          );
        case GControlHandleShape.diamond:
          final path =
              Path()
                ..moveTo(handle.position.dx, rect.top)
                ..lineTo(rect.right, handle.position.dy)
                ..lineTo(handle.position.dx, rect.bottom)
                ..lineTo(rect.left, handle.position.dy)
                ..close();
          drawPath(canvas: canvas, path: path, style: handleTheme.style);
          break;
        case GControlHandleShape.crossCircle:
          drawPath(
            canvas: canvas,
            path: Path()..addOval(rect),
            style: handleTheme.style,
          );
          final crossPath =
              Path()
                ..moveTo(rect.left, handle.position.dy)
                ..lineTo(rect.right, handle.position.dy)
                ..moveTo(handle.position.dx, rect.top)
                ..lineTo(handle.position.dx, rect.bottom)
                ..close();
          drawPath(canvas: canvas, path: crossPath, style: handleTheme.style);
          break;
        case GControlHandleShape.crossSquare:
          drawPath(
            canvas: canvas,
            path: Path()..addRect(rect),
            style: handleTheme.style,
          );
          final crossPath =
              Path()
                ..moveTo(rect.left, handle.position.dy)
                ..lineTo(rect.right, handle.position.dy)
                ..moveTo(handle.position.dx, rect.top)
                ..lineTo(handle.position.dx, rect.bottom)
                ..close();
          drawPath(canvas: canvas, path: crossPath, style: handleTheme.style);
          break;
      }
    }
  }

  bool hitTestControlHandles({required Offset position, double? epsilon}) {
    if (controlHandles.isEmpty) {
      return false;
    }
    for (final control in controlHandles.entries) {
      final point = control.value.position;
      if ((point - position).distance <=
          (epsilon ?? (kDefaultHitTestEpsilon))) {
        return true;
      }
    }
    return false;
  }
}
