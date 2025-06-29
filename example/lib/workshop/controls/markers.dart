import 'package:flutter/material.dart';

import 'marker_coordinate.dart';
import 'marker_items.dart';

class MarkersControlView extends StatefulWidget {
  const MarkersControlView({super.key});

  @override
  State<MarkersControlView> createState() => _MarkersControlViewState();
}

class _MarkersControlViewState extends State<MarkersControlView> {
  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList.radio(
      expandedHeaderPadding: const EdgeInsets.all(0),
      children: [
        ExpansionPanelRadio(
          value: 0,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Markers"),
              ),
            );
          },
          body: const MarkerItemsControlView(),
        ),
        ExpansionPanelRadio(
          value: 1,
          canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Coordinate & Size"),
              ),
            );
          },
          body: const MarkerCoordinateControlView(),
        ),
      ],
      expansionCallback: (panelIndex, isExpanded) {},
    );
  }
}
