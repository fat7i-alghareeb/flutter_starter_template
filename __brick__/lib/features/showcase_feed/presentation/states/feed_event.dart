part of 'feed_bloc.dart';

@freezed
class FeedEvent with _$FeedEvent {
  /// Opens the page: the list's first page and the recent searches. Each
  /// section asks for itself when it comes near the viewport.
  const factory FeedEvent.started() = _Started;

  /// A section has come within reach of the viewport and wants its data.
  /// Ignored when that section is already loading or loaded.
  const factory FeedEvent.sectionRequested(FeedSection section) =
      _SectionRequested;

  /// «Retry» inside a failed section — that section only.
  const factory FeedEvent.sectionRetried(FeedSection section) =
      _SectionRetried;

  const factory FeedEvent.listRetried() = _ListRetried;

  /// Pull to refresh.
  const factory FeedEvent.refreshed() = _Refreshed;

  const factory FeedEvent.loadMore() = _LoadMore;

  const factory FeedEvent.querySubmitted(String query) = _QuerySubmitted;

  const factory FeedEvent.scrolled(double offset) = _Scrolled;
}
