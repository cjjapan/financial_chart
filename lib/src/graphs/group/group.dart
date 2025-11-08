import 'package:flutter/foundation.dart';

import '../../components/component.dart';
import '../../components/graph/graph.dart';
import '../../components/graph/graph_theme.dart';
import 'group_render.dart';

/// Graph group for rendering multiple graphs as a single unit.
class GGraphGroup extends GGraph<GGraphTheme> {
  /// Type identifier for graph groups.
  static const String typeName = "group";

  /// The list of graphs in this group.
  final List<GGraph> graphs;

  /// Sets the highlighted state for this group and all contained graphs.
  @override
  set highlighted(bool value) {
    super.highlighted = value;
    for (final graph in graphs) {
      graph.highlighted = value;
    }
  }

  /// Sets the selected state for this group and all contained graphs.
  @override
  set selected(bool value) {
    super.selected = value;
    for (final graph in graphs) {
      graph.selected = value;
    }
  }

  /// Creates a graph group.
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

  /// Finds a graph in this group by its ID.
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
