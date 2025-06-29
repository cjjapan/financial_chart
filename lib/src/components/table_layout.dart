import 'dart:math';

import 'package:flutter/painting.dart';

abstract class GTableItem {
  final EdgeInsets padding;
  final Alignment alignment;
  GTableItem({
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(0),
  });
  Size get contentSize;
  Size get blockSize => Size(
    contentSize.width + padding.horizontal,
    contentSize.height + padding.vertical,
  );
}

class GTableSpanItem {
  final int rowStart;
  final int rowEnd;
  final int colStart;
  final int colEnd;
  final GTableItem item;

  GTableSpanItem({
    required this.rowStart,
    required this.rowEnd,
    required this.colStart,
    required this.colEnd,
    required this.item,
  });

  Size get contentSize => item.contentSize;
  Size get blockSize => item.blockSize;
  EdgeInsets get padding => item.padding;
  Alignment get alignment => item.alignment;
}

class GTablePlaceholderItem extends GTableItem {
  @override
  final Size contentSize;

  GTablePlaceholderItem({
    this.contentSize = const Size(0, 0),
    super.padding = const EdgeInsets.all(0),
    super.alignment,
  });
}

class GTableGroupItem extends GTableItem {
  final List<GTableItem> items;
  late final List<Rect> _itemRectangles; // local rect in content space
  final Axis direction;
  final double spacing;
  late final Size _contentSize;

  GTableGroupItem({
    required this.items,
    this.direction = Axis.horizontal,
    this.spacing = 0,
    super.padding = const EdgeInsets.all(10),
    super.alignment = Alignment.centerLeft,
  }) {
    if (direction == Axis.horizontal) {
      // width is sum, height is max
      double width = items.fold(
        0.0,
        (a, b) => a + b.contentSize.width + b.padding.horizontal,
      );
      double height = items.fold(
        0.0,
        (a, b) => max(a, b.contentSize.height + b.padding.vertical),
      );
      _contentSize = Size(width + spacing * (max(items.length - 1, 0)), height);
    } else {
      // height is sum, width is max
      double height = items.fold(
        0.0,
        (a, b) => a + b.contentSize.height + b.padding.vertical,
      );
      double width = items.fold(
        0.0,
        (a, b) => max(a, b.contentSize.width + b.padding.horizontal),
      );
      _contentSize = Size(width, height + spacing * (max(items.length - 1, 0)));
    }

    _itemRectangles = [];
    double offset = 0;
    for (final item in items) {
      if (direction == Axis.horizontal) {
        final itemRect = Rect.fromLTWH(
          offset + item.padding.left,
          item.padding.top +
              (_contentSize.height - item.blockSize.height) * 0.5,
          item.contentSize.width,
          item.contentSize.height,
        );
        _itemRectangles.add(itemRect);
        offset += item.contentSize.width + item.padding.horizontal + spacing;
      } else {
        final itemRect = Rect.fromLTWH(
          item.padding.left + (_contentSize.width - item.blockSize.width) * 0.5,
          offset + item.padding.top,
          item.contentSize.width,
          item.contentSize.height,
        );
        _itemRectangles.add(itemRect);
        offset += item.contentSize.height + item.padding.vertical + spacing;
      }
    }
  }

  @override
  Size get contentSize => _contentSize;

  List<Rect> get itemRectangles => _itemRectangles;
}

class GTableLayout {
  /// List of rows, each containing a list of column items in that row
  final List<List<GTableItem>> items;
  final List<double> rowHeights = [];
  final List<double> colWidths = [];

  /// span items that can span multiple rows and columns
  final List<GTableSpanItem> spanItems;
  final List<Rect> spanItemRectangles = [];

  final EdgeInsets padding;
  final EdgeInsets margin;

  Size size = Size.zero;

  GTableLayout({
    required this.items,
    this.spanItems = const [],
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  }) {
    layout();
  }

  void layout() {
    if (items.any((row) => row.length != items[0].length)) {
      throw ArgumentError('All rows must have the same number of columns.');
    }

    rowHeights.clear();
    colWidths.clear();
    spanItemRectangles.clear();
    size = Size.zero;

    if (items.isEmpty || items[0].isEmpty) {
      return;
    }

    for (int row = 0; row < items.length; row++) {
      double maxHeight = 0;
      for (int col = 0; col < items[row].length; col++) {
        final item = items[row][col];
        maxHeight = max(
          maxHeight,
          item.contentSize.height + item.padding.vertical,
        );
      }
      rowHeights.add(maxHeight);
    }
    for (int col = 0; col < items[0].length; col++) {
      double maxWidth = 0;
      for (int row = 0; row < items.length; row++) {
        final item = items[row][col];
        maxWidth = max(
          maxWidth,
          item.contentSize.width + item.padding.horizontal,
        );
      }
      colWidths.add(maxWidth);
    }
    for (final spanItem in spanItems) {
      final spanSize = Size(
        colWidths
            .sublist(spanItem.colStart, spanItem.colEnd + 1)
            .fold(0.0, (a, b) => a + b),
        rowHeights
            .sublist(spanItem.rowStart, spanItem.rowEnd + 1)
            .fold(0.0, (a, b) => a + b),
      );
      final spanItemSize = spanItem.blockSize;
      if (spanItemSize.width > spanSize.width) {
        // expand the column widths evenly to fit the span item
        final extraWidth = spanItemSize.width - spanSize.width;
        final extraPerCol =
            extraWidth / (spanItem.colEnd - spanItem.colStart + 1);
        for (int col = spanItem.colStart; col <= spanItem.colEnd; col++) {
          colWidths[col] += extraPerCol;
        }
      }
      if (spanItemSize.height > spanSize.height) {
        // expand the row heights evenly to fit the span item
        final extraHeight = spanItemSize.height - spanSize.height;
        final extraPerRow =
            extraHeight / (spanItem.rowEnd - spanItem.rowStart + 1);
        for (int row = spanItem.rowStart; row <= spanItem.rowEnd; row++) {
          rowHeights[row] += extraPerRow;
        }
      }
    }
    size = Size(
      colWidths.fold(0.0, (a, b) => a + b) +
          padding.horizontal +
          margin.horizontal,
      rowHeights.fold(0.0, (a, b) => a + b) +
          padding.vertical +
          margin.vertical,
    );

    for (final spanItem in spanItems) {
      final rowStart = spanItem.rowStart;
      final rowEnd = spanItem.rowEnd;
      final colStart = spanItem.colStart;
      final colEnd = spanItem.colEnd;
      double left =
          padding.left +
          margin.left +
          colWidths.sublist(0, colStart).fold(0.0, (a, b) => a + b) +
          spanItem.padding.left;
      double top =
          padding.top +
          margin.top +
          rowHeights.sublist(0, rowStart).fold(0.0, (a, b) => a + b) +
          spanItem.padding.top;
      double width =
          colWidths.sublist(colStart, colEnd + 1).fold(0.0, (a, b) => a + b) -
          spanItem.padding.horizontal;
      double height =
          rowHeights.sublist(rowStart, rowEnd + 1).fold(0.0, (a, b) => a + b) -
          spanItem.padding.vertical;
      Rect cellRect = Rect.fromLTWH(left, top, width, height);
      spanItemRectangles.add(cellRect);
    }
  }
}

extension GRectAddPadding on Rect {
  Rect addPadding(EdgeInsets padding) {
    return Rect.fromLTRB(
      left - padding.left,
      top - padding.top,
      right + padding.right,
      bottom + padding.bottom,
    );
  }
}
