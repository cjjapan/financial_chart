import 'dart:ui';

import 'package:financial_chart/financial_chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GAxis test', () {
    Rect container = const Rect.fromLTRB(100, 100, 1000, 2000);
    var (areas, left) = GAxis.placeAxes(container, [
      GValueAxis(viewPortId: '1', position: GAxisPosition.start),
      GPointAxis(position: GAxisPosition.end),
      GValueAxis(viewPortId: '2', position: GAxisPosition.end),
      GPointAxis(position: GAxisPosition.start),
      GValueAxis(viewPortId: '2', position: GAxisPosition.start),
    ]);

    expect(areas[0], const Rect.fromLTRB(100, 130, 160, 1970));
    expect(areas[1], const Rect.fromLTRB(220, 1970, 940, 2000));
    expect(areas[2], const Rect.fromLTRB(940, 130, 1000, 1970));
    expect(areas[3], const Rect.fromLTRB(220, 100, 940, 130));
    expect(areas[4], const Rect.fromLTRB(160, 130, 220, 1970));

    expect(left, const Rect.fromLTRB(220, 130, 940, 1970));
  });
}
