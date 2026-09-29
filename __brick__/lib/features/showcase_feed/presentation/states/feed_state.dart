part of 'feed_bloc.dart';

/// A `BlocStatus` per section: one shared status would mean one slow section
/// holds the whole page, one failed section empties it, and an empty section
/// cannot disappear on its own.
@freezed
abstract class FeedState with _$FeedState {
  const factory FeedState({
    @Default(BlocStatus<List<FeedItemEntity>>.initial())
    BlocStatus<List<FeedItemEntity>> highlightsState,
    @Default(BlocStatus<List<FeedItemEntity>>.initial())
    BlocStatus<List<FeedItemEntity>> picksState,

    /// The paged list, every page loaded so far.
    @Default(BlocStatus<List<FeedItemEntity>>.initial())
    BlocStatus<List<FeedItemEntity>> listState,

    /// The next page — kept apart so a failed next page never empties the
    /// list on screen.
    @Default(BlocStatus<void>.initial()) BlocStatus<void> loadMoreState,
    @Default(1) int page,
    @Default(false) bool hasMore,
    @Default(0) int total,
    @Default('') String query,
    @Default(<String>[]) List<String> recentSearches,
    @Default(true) bool isSearchVisible,
  }) = _FeedState;
}
