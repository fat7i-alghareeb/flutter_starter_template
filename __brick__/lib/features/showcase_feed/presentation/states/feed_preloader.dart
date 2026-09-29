import 'package:injectable/injectable.dart';

import '../../../../core/injection/injectable.dart';
import '../../../../core/services/startup/bloc_preloader.dart';
import '../../domain/feed_entities.dart';
import 'feed_bloc.dart';

/// Starts the feed's first requests behind the splash (see [BlocPreloader]).
///
/// `bootstrap.dart` calls [start] after the first frame; `FeedScreen` calls
/// [claim] in its `BlocProvider(create:)`. Copy this class for your own first
/// tab.
@lazySingleton
class FeedPreloader extends BlocPreloader<FeedBloc> {
  FeedPreloader(super.authState, super.onboarding);

  @override
  String get name => 'FeedPreloader';

  @override
  FeedBloc create() => getIt<FeedBloc>()..add(const FeedEvent.started());

  /// The sections above the fold — the carousel at the top — are asked for
  /// now too; everything below still loads as it scrolls near.
  @override
  Future<void> warmUp(FeedBloc bloc) async {
    bloc.add(const FeedEvent.sectionRequested(FeedSection.highlights));
  }
}
