part of 'log_center_panel.dart';

/// Shared highlighted log text renderer.
class LogCenterLogText extends StatelessWidget {
  /// Creates one log text row.
  const LogCenterLogText({
    super.key,
    required this.line,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = false,
  });

  /// Raw log text.
  final String line;

  /// Maximum visible lines.
  final int? maxLines;

  /// Overflow behavior for the rendered line.
  final TextOverflow overflow;

  /// Whether the text can wrap.
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: EasyRichText(
        _normalize(line),
        patternList: _patterns,
        selectable: true,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        defaultStyle: _selectStyle(context),
      ),
    );
  }

  TextStyle _selectStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      height: 1.4,
    );
  }

  String _normalize(String value) {
    return value.replaceAll(RegExp(r'[\r\n]+$'), '');
  }

  static const _patterns = [
    EasyRichTextPattern(
      targetString: r'^(?:\d{4}-\d{2}-\d{2}|\d{1,2}) \d{2}:\d{2}:\d{2}\.\d{3}',
      matchWordBoundaries: false,
      style: TextStyle(
        color: Colors.cyan,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    ),
    EasyRichTextPattern(
      targetString: r'\d{2}:\d{2}:\d{2}\.\d{3}',
      matchWordBoundaries: false,
      style: TextStyle(
        color: Colors.cyan,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    ),
    EasyRichTextPattern(
      targetString: r'\bINFO\b',
      matchWordBoundaries: false,
      style: TextStyle(
        color: Color.fromARGB(255, 55, 109, 136),
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      suffixInlineSpan: TextSpan(
        style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
        text: '      ',
      ),
    ),
    EasyRichTextPattern(
      targetString: r'\bWARNING\b',
      matchWordBoundaries: false,
      style: TextStyle(
        color: Colors.yellow,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    ),
    EasyRichTextPattern(
      targetString: r'\bERROR\b',
      matchWordBoundaries: false,
      style: TextStyle(
        color: Colors.red,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      suffixInlineSpan: TextSpan(
        style: TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
        text: '    ',
      ),
    ),
    EasyRichTextPattern(
      targetString: r'\bCRITICAL\b',
      matchWordBoundaries: false,
      style: TextStyle(
        color: Colors.red,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      suffixInlineSpan: TextSpan(text: '   '),
    ),
    EasyRichTextPattern(
      targetString: r'^[─═=\-]{6,}.*[─═=\-]{6,}$',
      matchWordBoundaries: false,
      style: TextStyle(color: Colors.lightGreen),
    ),
    EasyRichTextPattern(
      targetString: r'[\{\[\(\)\]\}]',
      matchWordBoundaries: false,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    EasyRichTextPattern(
      targetString: 'True',
      style: TextStyle(color: Colors.lightGreen),
    ),
    EasyRichTextPattern(
      targetString: 'False',
      style: TextStyle(color: Colors.red),
    ),
    EasyRichTextPattern(
      targetString: 'None',
      style: TextStyle(color: Colors.purple),
    ),
    EasyRichTextPattern(
      targetString: r'(某喵*某喵)|(~~*~~)',
      matchWordBoundaries: false,
      style: TextStyle(color: Colors.lightGreen),
    ),
  ];
}
