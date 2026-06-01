part of 'log_center_panel.dart';

/// Error detail page with image preview and log text.
class LogCenterErrorDetailView extends StatelessWidget {
  /// Creates one error detail view.
  const LogCenterErrorDetailView({
    super.key,
    required this.controller,
    required this.detailScrollController,
    required this.detailHorizontalScrollController,
  });

  /// Log browser controller.
  final ScriptLogBrowserController controller;

  /// Vertical scroll controller for the detail page.
  final ScrollController detailScrollController;

  /// Horizontal scroll controller for non-wrapped detail log text.
  final ScrollController detailHorizontalScrollController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = controller.selectedErrorDetail.value;
      if (detail == null) {
        return _buildLoading(context);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(
            context,
            _formatDetailTime(detail),
            trailing: _buildScrollToBottomButton(),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(context, detail)),
        ],
      );
    });
  }

  /// Builds the detail scroll area with optional line wrapping.
  Widget _buildBody(BuildContext context, ScriptErrorLogDetail detail) {
    return Obx(() {
      final wrapLines = controller.wrapLines.value;
      return Scrollbar(
        controller: detailScrollController,
        thumbVisibility: true,
        child: ListView(
          controller: detailScrollController,
          padding: const EdgeInsets.only(right: 12),
          children: [
            _buildImages(context, detail),
            const SizedBox(height: 12),
            _buildLogText(detail, wrapLines),
          ],
        ),
      );
    });
  }

  /// Builds wrapped or horizontally-scrollable error log text.
  Widget _buildLogText(ScriptErrorLogDetail detail, bool wrapLines) {
    if (wrapLines) {
      return LogCenterLogText(
        line: detail.log.content,
        maxLines: null,
        overflow: TextOverflow.clip,
        softWrap: true,
      );
    }
    return Scrollbar(
      controller: detailHorizontalScrollController,
      thumbVisibility: true,
      notificationPredicate: (notification) {
        return notification.metrics.axis == Axis.horizontal;
      },
      child: SingleChildScrollView(
        controller: detailHorizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: LogCenterLogText(
          line: detail.log.content,
          maxLines: null,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  /// Builds detail header while data is still loading.
  Widget _buildLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, _selectedErrorTitle()),
        Expanded(
          child: Center(
            child: controller.errorDetailLoading.value
                ? const CircularProgressIndicator()
                : Text(I18n.homeLogSelectError.tr),
          ),
        ),
      ],
    );
  }

  /// Builds a detail header with a back action.
  Widget _buildHeader(BuildContext context, String title, {Widget? trailing}) {
    return Row(
      children: [
        IconButton(
          tooltip: I18n.back.tr,
          onPressed: controller.backToErrorList,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }

  /// Builds the action that scrolls the error detail view to the latest line.
  Widget _buildScrollToBottomButton() {
    return IconButton(
      tooltip: I18n.homeLogScrollToBottom.tr,
      onPressed: _scrollDetailToBottom,
      icon: const Icon(Icons.vertical_align_bottom_rounded),
    );
  }

  /// Builds image previews for the selected error.
  Widget _buildImages(BuildContext context, ScriptErrorLogDetail detail) {
    final images = detail.images.take(3).toList();
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: images
          .map(
            (image) => LogCenterErrorImageCard(
              controller: controller,
              detail: detail,
              image: image,
            ),
          )
          .toList(),
    );
  }

  /// Formats the selected detail timestamp.
  String _formatDetailTime(ScriptErrorLogDetail detail) {
    return controller.formatErrorTimestamp(detail.timestampMs, detail.time);
  }

  /// Resolves a title for the currently selected error.
  String _selectedErrorTitle() {
    final selectedId = controller.selectedErrorId.value;
    final index = controller.errorItems.indexWhere((item) {
      return item.id == selectedId;
    });
    if (index < 0) {
      return controller.selectedErrorTitle.value.isEmpty
          ? I18n.homeLogSelectError.tr
          : controller.selectedErrorTitle.value;
    }
    final item = controller.errorItems[index];
    return controller.formatErrorTimestamp(item.timestampMs, item.time);
  }

  /// Scrolls the vertical detail viewport to the current bottom edge.
  void _scrollDetailToBottom() {
    if (!detailScrollController.hasClients) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!detailScrollController.hasClients) {
        return;
      }
      final target = detailScrollController.position.maxScrollExtent;
      final distance = (detailScrollController.offset - target).abs();
      if (distance > 400) {
        detailScrollController.jumpTo(target);
        return;
      }
      detailScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }
}
