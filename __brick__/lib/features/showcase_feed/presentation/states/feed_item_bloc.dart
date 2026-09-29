import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/bloc_status.dart';
import '../../../../core/utils/result.dart';
import '../../data/feed_data.dart';
import '../../domain/feed_entities.dart';

part 'feed_item_bloc.freezed.dart';

@freezed
class FeedItemEvent with _$FeedItemEvent {
  const factory FeedItemEvent.started(String id) = _ItemStarted;
  const factory FeedItemEvent.retried() = _ItemRetried;

  /// Save / unsave. The UI offers «Undo» by sending it again.
  const factory FeedItemEvent.saveToggled() = _SaveToggled;
}

@freezed
abstract class FeedItemState with _$FeedItemState {
  const factory FeedItemState({
    @Default('') String id,
    @Default(BlocStatus<FeedItemEntity>.initial())
    BlocStatus<FeedItemEntity> detailState,

    /// «More like this»: the same category, this item left out.
    @Default(BlocStatus<List<FeedItemEntity>>.initial())
    BlocStatus<List<FeedItemEntity>> relatedState,
    @Default(false) bool isSaved,

    /// Bumped on every save toggle, so the page can react to the SAME value
    /// twice (save, undo, save).
    @Default(0) int saveToggles,
  }) = _FeedItemState;
}

/// One item's page.
@injectable
class FeedItemBloc extends Bloc<FeedItemEvent, FeedItemState> {
  FeedItemBloc(this._repository) : super(const FeedItemState()) {
    on<_ItemStarted>(_onStarted);
    on<_ItemRetried>(_onRetried);
    on<_SaveToggled>(_onSaveToggled);
  }

  final FeedRepository _repository;

  Future<void> _onStarted(_ItemStarted event, Emitter<FeedItemState> emit) {
    emit(state.copyWith(id: event.id));
    return _load(emit);
  }

  Future<void> _onRetried(_ItemRetried event, Emitter<FeedItemState> emit) =>
      _load(emit);

  void _onSaveToggled(_SaveToggled event, Emitter<FeedItemState> emit) {
    // A real app sends the save to the server here and rolls back on
    // failure; the showcase keeps it local.
    emit(
      state.copyWith(
        isSaved: !state.isSaved,
        saveToggles: state.saveToggles + 1,
      ),
    );
  }

  Future<void> _load(Emitter<FeedItemState> emit) async {
    emit(state.copyWith(detailState: const BlocStatus.loading()));
    final result = await _repository.getItem(state.id);
    FeedItemEntity? item;
    result.when(
      success: (data) {
        item = data;
        emit(state.copyWith(detailState: BlocStatus.success(data)));
      },
      failure: (message) =>
          emit(state.copyWith(detailState: BlocStatus.failure(message))),
    );

    final loaded = item;
    if (loaded == null) return;
    emit(state.copyWith(relatedState: const BlocStatus.loading()));
    final related = await _repository.getFeed(
      page: 1,
      limit: 6,
      category: loaded.category,
    );
    related.when(
      success: (page) => emit(
        state.copyWith(
          relatedState: BlocStatus.success(
            page.items.where((i) => i.id != loaded.id).toList(),
          ),
        ),
      ),
      failure: (message) =>
          emit(state.copyWith(relatedState: BlocStatus.failure(message))),
    );
  }
}
