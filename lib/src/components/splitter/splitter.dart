import '../component.dart';
import 'splitter_render.dart';
import 'splitter_theme.dart';

/// Splitter (resize handle) component.
class GSplitter extends GComponent {
  GSplitter({GSplitterTheme? theme, GSplitterRender? render})
    : super(render: render ?? const GSplitterRender(), theme: theme);
}
