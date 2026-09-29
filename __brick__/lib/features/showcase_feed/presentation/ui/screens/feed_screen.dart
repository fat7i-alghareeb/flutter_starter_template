import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/injection/injectable.dart';
import '../../states/feed_bloc.dart';
import '../../states/feed_preloader.dart';
import '../widgets/feed_body.dart';

/// The first tab of the showcase — a sectioned page driven by the mock layer
/// (`--dart-define=USE_MOCK=true`).
///
/// It lives inside `RootScreen`'s tab stack, which owns the scaffold and the
/// floating navigation bar, so there is no `AppScaffold` here.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  static const String pageName = 'FeedScreen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeedBloc>(
      // The feed's first requests usually started behind the splash
      // (`FeedPreloader`); this takes that bloc over — or makes a fresh one
      // where nothing preloaded (a test, a first launch).
      create: (_) => getIt.isRegistered<FeedPreloader>()
          ? getIt<FeedPreloader>().claim()
          : (getIt<FeedBloc>()..add(const FeedEvent.started())),
      child: const FeedBody(),
    );
  }
}
