import 'package:flutter/painting.dart';

import '../components/components.dart';
import '../style/paint_style.dart';

abstract class GTableItemPainter extends GTableItem {
  final PaintStyle? blockStyle;
  GTableItemPainter({super.alignment, super.padding, this.blockStyle});
  void paint(Canvas canvas, Rect contentRect) {
    if (blockStyle != null) {
      paintBlock(canvas, contentRect);
    }
  }

  void paintBlock(Canvas canvas, Rect contentRect) {
    if (blockStyle != null) {
      final block = contentRect.addPadding(padding);
      GRenderUtil.drawPath(
        canvas: canvas,
        path: Path()..addRect(block),
        style: blockStyle!,
      );
    }
  }
}

class GTableTextItemPainter extends GTableItemPainter {
  final String text;
  final TextStyle style;
  late final TextPainter _textPainter;
  late Size _contentSize;

  GTableTextItemPainter({
    required this.text,
    required this.style,
    super.padding,
    super.alignment,
    super.blockStyle,
  }) {
    _textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(text: text, style: style);
    _textPainter.layout();
    _contentSize = _textPainter.size;
  }

  @override
  Size get contentSize => _contentSize;

  @override
  void paint(Canvas canvas, Rect contentRect) {
    super.paint(canvas, contentRect);
    _textPainter.paint(canvas, contentRect.topLeft);
  }
}

class GTablePlaceHolderItemPainter extends GTableItemPainter {
  late final GTablePlaceholderItem placeholderItem;

  GTablePlaceHolderItemPainter({
    super.padding = const EdgeInsets.all(0),
    super.alignment = Alignment.center,
    super.blockStyle,
    Size contentSize = const Size(0, 0),
  }) {
    placeholderItem = GTablePlaceholderItem(
      contentSize: contentSize,
      padding: padding,
      alignment: alignment,
    );
  }

  @override
  Size get contentSize => placeholderItem.contentSize;

  @override
  void paint(Canvas canvas, Rect contentRect) {
    super.paintBlock(canvas, contentRect);
  }
}

class GTableGroupItemPainter extends GTableItemPainter {
  late final GTableGroupItem group;
  GTableGroupItemPainter({
    required List<GTableItemPainter> items,
    Axis direction = Axis.horizontal,
    double spacing = 0,
    EdgeInsets padding = const EdgeInsets.all(10),
    Alignment alignment = Alignment.centerLeft,
    super.blockStyle,
  }) {
    group = GTableGroupItem(
      items: items,
      direction: direction,
      spacing: spacing,
      padding: padding,
      alignment: alignment,
    );
  }

  @override
  void paint(Canvas canvas, Rect contentRect) {
    super.paint(canvas, contentRect);
    canvas.save();
    canvas.translate(contentRect.left, contentRect.top);
    for (int n = 0; n < group.items.length; n++) {
      final item = group.items[n] as GTableItemPainter;
      item.paint(canvas, group.itemRectangles[n]);
    }
    canvas.restore();
  }

  @override
  Size get contentSize => group.contentSize;
  @override
  Size get blockSize => group.blockSize;
  @override
  EdgeInsets get padding => group.padding;
  @override
  Alignment get alignment => group.alignment;
}

class GTableItemSpanPainter extends GTableSpanItem {
  GTableItemSpanPainter({
    required super.rowStart,
    required super.rowEnd,
    required super.colStart,
    required super.colEnd,
    required GTableItemPainter super.item,
  });
}

class GTableLayoutPainter extends GTableLayout {
  final PaintStyle? blockStyle;
  final double blockCornerRadius;
  final PaintStyle? cellStyle;
  final Offset anchor;
  final Alignment alignment;
  late final Offset paintOffset;

  GTableLayoutPainter({
    required List<List<GTableItemPainter>> super.items,
    List<GTableItemSpanPainter> super.spanItems = const [],
    this.blockCornerRadius = 0,
    super.padding,
    super.margin,
    this.blockStyle,
    this.cellStyle,
    this.anchor = Offset.zero,
    this.alignment = Alignment.center,
  }) {
    paintOffset = GRenderUtil.getBlockPaintPoint(
      anchor,
      size.width,
      size.height,
      alignment,
    );
  }

  GTableLayoutPainter.twoColumnText({
    required List<List<String>> texts,
    Alignment leftColumnAlignment = Alignment.centerLeft,
    Alignment rightColumnAlignment = Alignment.centerRight,
    Alignment singleTextAlignment = Alignment.center,
    EdgeInsets cellPadding = const EdgeInsets.symmetric(
      vertical: 2,
      horizontal: 4,
    ),
    EdgeInsets? rightCellPadding,
    EdgeInsets? singleCellPadding,
    required TextStyle textStyle,
    TextStyle? rightTextStyle,
    TextStyle? singleTextStyle,
    this.blockCornerRadius = 0,
    super.padding,
    this.blockStyle,
    this.cellStyle,
    this.anchor = Offset.zero,
    this.alignment = Alignment.center,
  }) : super(items: [], spanItems: []) {
    for (int i = 0; i < texts.length; i++) {
      if (texts[i].isEmpty) {
        continue; // skip empty rows
      }
      if (texts[i].length == 2) {
        items.add([
          GTableTextItemPainter(
            text: texts[i][0],
            style: textStyle,
            alignment: leftColumnAlignment,
            padding: cellPadding,
          ),
          GTableTextItemPainter(
            text: texts[i][1],
            style: rightTextStyle ?? textStyle,
            alignment: rightColumnAlignment,
            padding: rightCellPadding ?? cellPadding,
          ),
        ]);
      } else {
        items.add([
          GTablePlaceHolderItemPainter(),
          GTablePlaceHolderItemPainter(),
        ]);
        spanItems.add(
          GTableSpanItem(
            rowStart: i,
            rowEnd: i,
            colStart: 0,
            colEnd: 1,
            item: GTableTextItemPainter(
              text: texts[i][0],
              style: singleTextStyle ?? textStyle,
              alignment: singleTextAlignment,
              padding: singleCellPadding ?? cellPadding,
            ),
          ),
        );
      }
    }
    super.layout();
    paintOffset = GRenderUtil.getBlockPaintPoint(
      anchor,
      size.width,
      size.height,
      alignment,
    );
  }

  void paint(Canvas canvas, {Offset? forceOffset}) {
    final offset = forceOffset ?? paintOffset;
    canvas.save();
    canvas.translate(offset.dx + margin.left, offset.dy + margin.top);

    // draw background block
    if (blockStyle != null) {
      Path blockPath = Path();
      if (blockCornerRadius > 0) {
        blockPath.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              0,
              0,
              size.width - margin.horizontal,
              size.height - margin.vertical,
            ),
            Radius.circular(blockCornerRadius),
          ),
        );
      } else {
        blockPath.addRect(
          Rect.fromLTWH(
            0,
            0,
            size.width - margin.horizontal,
            size.height - margin.vertical,
          ),
        );
      }
      GRenderUtil.drawPath(canvas: canvas, path: blockPath, style: blockStyle!);
    }

    // draw items
    canvas.translate(padding.left, padding.top);
    final colTranslateTotal = colWidths
        .sublist(0, colWidths.length - 1)
        .fold(0.0, (a, b) => a + b);
    for (int row = 0; row < items.length; row++) {
      if (row > 0) {
        // move to next row
        canvas.translate(0.0, rowHeights[row - 1]);
        // reset to first column
        canvas.translate(-colTranslateTotal, 0);
      }
      for (int col = 0; col < items[row].length; col++) {
        if (col > 0) {
          // move to next column
          canvas.translate(colWidths[col - 1], 0.0);
        }
        final item = items[row][col];
        final cellRect = Rect.fromLTWH(
          item.padding.left,
          item.padding.top,
          colWidths[col] - item.padding.horizontal,
          rowHeights[row] - item.padding.vertical,
        );
        _drawItem(
          item as GTableItemPainter,
          canvas,
          cellRect,
          cellStyle: cellStyle,
        );
      }
    }
    canvas.restore();

    // Draw span items
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    for (int n = 0; n < spanItems.length; n++) {
      final spanItem = spanItems[n];
      _drawItem(
        spanItem.item as GTableItemPainter,
        canvas,
        spanItemRectangles[n],
        cellStyle: null,
      );
    }
    canvas.restore();
  }

  void _drawItem(
    GTableItemPainter item,
    Canvas canvas,
    Rect cellRect, {
    PaintStyle? cellStyle,
  }) {
    if (cellStyle != null) {
      GRenderUtil.drawPath(
        canvas: canvas,
        path:
            Path()..addRect(
              Rect.fromLTRB(
                cellRect.left - item.padding.left,
                cellRect.top - item.padding.top,
                cellRect.right + item.padding.right,
                cellRect.bottom + item.padding.bottom,
              ),
            ),
        style: cellStyle,
      );
    }
    final itemRect = GRenderUtil.rectFromAnchorAndAlignment(
      anchor:
          cellRect.center +
          Offset(
            item.alignment.x * cellRect.width / 2,
            item.alignment.y * cellRect.height / 2,
          ),
      width: item.contentSize.width,
      height: item.contentSize.height,
      alignment: Alignment(-item.alignment.x, -item.alignment.y),
    );
    item.paint(canvas, itemRect);
  }
}
