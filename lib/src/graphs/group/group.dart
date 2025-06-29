import 'package:flutter/foundation.dart';

import '../../components/component.dart';
import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import 'group_render.dart';

/// A Group of graphs.
class GGraphGroup extends GGraph<GGraphTheme> {
  static const String typeName = "group";

  final List<GGraph> graphs;

  @override
  set highlighted(bool value) {
    super.highlighted = value;
    for (final graph in graphs) {
      graph.highlighted = value;
    }
  }

  @override
  set selected(bool value) {
    super.selected = value;
    for (final graph in graphs) {
      graph.selected = value;
    }
  }

  GGraphGroup({
    super.id,
    super.label,
    required this.graphs,
    super.valueViewPortId,
    super.layer,
    super.visible,
    bool highlighted = false,
    bool selected = false,
    super.overlayMarkers,
    super.render,
  }) : super(
         hitTestMode: GHitTestMode.none, // unused
         theme: const GGraphTheme(), // unused
       ) {
    assert(
      graphs.any((graph) => graph.valueViewPortId != valueViewPortId) == false,
    );
    super.render = render ?? GGraphGroupRender();
    graphs.sort((a, b) => a.layer.compareTo(b.layer));
    this.highlighted = highlighted;
    this.selected = selected;
  }

  GGraph? findGraphById(String id) {
    for (final graph in graphs) {
      if (graph.id == id) {
        return graph;
      }
    }
    return null;
  }

  @override
  String get type => typeName;

  @override
  debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<GGraph>('graphs', graphs));
  }
}
