import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/bloc_status.dart';
import '../../../../core/utils/result.dart';
import '../../data/feed_data.dart';
import '../../domain/feed_entities.dart';

part 'feed_event.dart';
part 'feed_state.dart';
part 'feed_bloc.freezed.dart';

/// The feed page: two lazy sections and a paged list that do not wait for
/// each other.
///
/// `started` loads the list's first page. Each section asks for its own data
/// when it comes near the viewport (`AppLazySection`), and a failure or an
/// empty answer stays inside that section. Pulling down reloads everything the
/// reader has already seen — never a section still waiting below the fold.
@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc(this._repository) : super(const FeedState()) {
    on<_Started>(_onStarted);
    on<_SectionRequested>(_onSectionRequested);
    on<_SectionRetried>(_onSectionRetried);
    on<_ListRetried>(_onListRetried);
    on<_Refreshed>(_onRefreshed);
    on<_LoadMore>(_onLoadMore);
    on<_QuerySubmitted>(_onQuerySubmitted);
    on<_Scrolled>(_onScrolled);
  }

  final FeedRepository _repository;

  /// Items per page.
  static const int pageSize = 10;

  /// Scrolling down further than this in one go hides the header's search
  /// field; any upward movement brings it back.
  static const double searchHideThreshold = 24;

  double _lastOffset = 0;

  Future<void> _onStarted(_Started event, Emitter<FeedState> emit) async {
    final recent = await _repository.recentSearches();
    emit(state.copyWith(recentSearches: recent));
    await _loadFirstPage(emit);
  }

  Future<void> _onSectionRequested(
    _SectionRequested event,
    Emitter<FeedState> emit,
  ) async {
    // A section is built again on every scroll past it; only the first build
    // may turn into a request.
    if (!_statusOf(event.section).isInit) return;
    await _loadSection(event.section, emit);
  }

  Future<void> _onSectionRetried(
    _SectionRetried event,
    Emitter<FeedState> emit,
  ) async {
    if (_statusOf(event.section).isLoading) return;
    await _loadSection(event.section, emit);
  }

  Future<void> _onListRetried(_ListRetried event, Emitter<FeedState> emit) =>
      _loadFirstPage(emit);

  /// Everything the reader has already seen, reloaded together. A section
  /// still at `initial` is below the fold and has not been asked for yet;
  /// loading it here would defeat the lazy loading.
  Future<void> _onRefreshed(_Refreshed event, Emitter<FeedState> emit) async {
    await Future.wait<void>(<Future<void>>[
      _loadFirstPage(emit),
      for (final section in FeedSection.values)
        if (!_statusOf(section).isInit) _loadSection(section, emit),
    ]);
  }

  Future<void> _onLoadMore(_LoadMore event, Emitter<FeedState> emit) async {
    if (!state.hasMore ||
        state.loadMoreState.isLoading ||
        !state.listState.isSuccess) {
      return;
    }
    emit(state.copyWith(loadMoreState: const BlocStatus.loading()));
    final nextPage = state.page + 1;
    final result = await _repository.getFeed(
      page: nextPage,
      limit: pageSize,
      query: state.query,
    );
    result.when(
      success: (page) => emit(
        state.copyWith(
          listState: BlocStatus.success(<FeedItemEntity>[
            ...state.listState.getDataWhenSuccess ?? const <FeedItemEntity>[],
            ...page.items,
          ]),
          loadMoreState: const BlocStatus.initial(),
          page: nextPage,
          hasMore: page.hasMore,
        ),
      ),
      // A failed next page keeps what is on screen; the footer offers retry.
      failure: (message) =>
          emit(state.copyWith(loadMoreState: BlocStatus.failure(message))),
    );
  }

  Future<void> _onQuerySubmitted(
    _QuerySubmitted event,
    Emitter<FeedState> emit,
  ) async {
    final query = event.query.trim();
    if (query == state.query) return;
    final recent = query.isEmpty
        ? state.recentSearches
        : await _repository.saveSearch(query);
    emit(state.copyWith(query: query, recentSearches: recent));
    await _loadFirstPage(emit);
  }

  /// The search field slides away on the way down and comes straight back on
  /// ANY upward scroll; it is always showing at the top. A threshold on the
  /// way down only, so a small jitter never makes the header twitch.
  void _onScrolled(_Scrolled event, Emitter<FeedState> emit) {
    final offset = event.offset;
    final delta = offset - _lastOffset;
    _lastOffset = offset;

    if (offset <= searchHideThreshold) {
      if (!state.isSearchVisible) emit(state.copyWith(isSearchVisible: true));
      return;
    }
    if (delta > searchHideThreshold && state.isSearchVisible) {
      emit(state.copyWith(isSearchVisible: false));
    } else if (delta < 0 && !state.isSearchVisible) {
      emit(state.copyWith(isSearchVisible: true));
    }
  }

  Future<void> _loadFirstPage(Emitter<FeedState> emit) async {
    emit(
      state.copyWith(
        listState: const BlocStatus.loading(),
        loadMoreState: const BlocStatus.initial(),
      ),
    );
    final result = await _repository.getFeed(
      page: 1,
      limit: pageSize,
      query: state.query,
    );
    result.when(
      success: (page) => emit(
        state.copyWith(
          listState: BlocStatus.success(page.items),
          page: 1,
          hasMore: page.hasMore,
          total: page.total,
        ),
      ),
      failure: (message) =>
          emit(state.copyWith(listState: BlocStatus.failure(message))),
    );
  }

  BlocStatus<List<FeedItemEntity>> _statusOf(FeedSection section) =>
      switch (section) {
        FeedSection.highlights => state.highlightsState,
        FeedSection.picks => state.picksState,
      };

  /// Loads one section into its own status. The `switch` is exhaustive on
  /// purpose: a new section without a loader stops compiling here.
  Future<void> _loadSection(FeedSection section, Emitter<FeedState> emit) {
    return switch (section) {
      FeedSection.highlights => _load(
        emit,
        _repository.getHighlights,
        (status) => state.copyWith(highlightsState: status),
      ),
      FeedSection.picks => _load(
        emit,
        _repository.getPicks,
        (status) => state.copyWith(picksState: status),
      ),
    };
  }

  /// loading → success | failure, into whichever field [apply] writes to.
  Future<void> _load<T>(
    Emitter<FeedState> emit,
    Future<Result<T>> Function() request,
    FeedState Function(BlocStatus<T> status) apply,
  ) async {
    emit(apply(const BlocStatus.loading()));
    final result = await request();
    result.when(
      success: (data) => emit(apply(BlocStatus<T>.success(data))),
      failure: (message) => emit(apply(BlocStatus<T>.failure(message))),
    );
  }
}
