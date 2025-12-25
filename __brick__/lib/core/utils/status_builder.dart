// 🐦 Flutter imports:
import '../../common/imports/imports.dart' show FailedStateWidget;
import '../../common/widgets/main_loading_progress.dart'
    show MainLoadingProgress;
import '../../core/utils/bloc_status.dart' show BlocStatus, BlocStatusPatterns;
import 'package:flutter/material.dart';

class StatusBuilder<T> extends StatelessWidget {
  const StatusBuilder({
    super.key,
    required this.success,
    this.loading,
    this.init,
    this.onError,
    required this.state,
    this.errorMessage,
    this.showLoadingProgress = true,
    this.showInitWidget = true,
  });

  final BlocStatus<T> state;
  final Widget Function()? loading;
  final Widget Function()? init;
  final Widget Function(T data) success;
  final Function()? onError;
  final String? errorMessage;
  final bool showLoadingProgress;
  final bool showInitWidget;

  @override
  Widget build(BuildContext context) {
    late final Widget next;

    defaultLoading() => showLoadingProgress
        ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Center(child: MainLoadingProgress())],
          )
        : const SizedBox.shrink();

    defaultInit() => const SizedBox.shrink();

    state.when(
      initial: () => next = init?.call() ?? defaultInit(),
      loading: () => next = loading?.call() ?? defaultLoading(),
      success: (data) => next = success(data),
      failure: (message) {
        return next = FailedStateWidget(
          message: errorMessage ?? message,
          onRetrying: onError,
        );
      },
    );

    return next;
  }
}
