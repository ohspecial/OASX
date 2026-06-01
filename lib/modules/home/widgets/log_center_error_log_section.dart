part of 'log_center_panel.dart';

extension _LogCenterErrorDetailLogSectionX on LogCenterErrorDetailView {
  /// Builds the log slivers with progressive state feedback.
  List<Widget> _buildLogSlivers(BuildContext context) {
    final lines = controller.selectedErrorLogLines;
    final preparing = controller.errorLogPreparing.value;
    if (lines.isEmpty) {
      if (controller.errorMessage.value.isNotEmpty) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(controller.errorMessage.value)),
          ),
        ];
      }
      if (preparing) {
        return const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
        ];
      }
      return const [SliverToBoxAdapter(child: SizedBox.shrink())];
    }
    final widgets = <Widget>[
      if (preparing || controller.errorLogAppending.value)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        ),
    ];
    if (controller.wrapLines.value) {
      widgets.add(_buildWrappedLogSliver(lines));
      return widgets;
    }
    widgets.add(_buildHorizontalLogSliver(context, lines));
    return widgets;
  }

  /// Builds the wrapped vertical log sliver.
  Widget _buildWrappedLogSliver(List<String> lines) {
    return SliverList.builder(
      itemCount: lines.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: LogCenterLogText(
            line: lines[index],
            maxLines: null,
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        );
      },
    );
  }

  /// Builds the non-wrapped horizontal log area inside the vertical scroll flow.
  Widget _buildHorizontalLogSliver(BuildContext context, List<String> lines) {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = _resolveContentWidth(
            context,
            constraints.maxWidth,
            controller.selectedErrorLogMaxWidthScore.value,
          );
          return Scrollbar(
            controller: detailHorizontalScrollController,
            interactive: true,
            thumbVisibility: width > constraints.maxWidth,
            notificationPredicate: (notification) {
              return notification.metrics.axis == Axis.horizontal;
            },
            child: SingleChildScrollView(
              controller: detailHorizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: lines
                      .map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: LogCenterLogText(
                            line: line,
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                            softWrap: false,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Resolves one best-effort monospace width for horizontal scrolling.
  double _resolveContentWidth(
    BuildContext context,
    double viewportWidth,
    int widthScore,
  ) {
    final fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14;
    final estimatedWidth = widthScore * fontSize * 0.64 + 48;
    return estimatedWidth < viewportWidth ? viewportWidth : estimatedWidth;
  }
}
