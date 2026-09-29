import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/utils/bloc_status.dart';
import 'package:{{project_name}}/core/utils/result.dart';
import 'package:{{project_name}}/features/showcase_feed/domain/feed_entities.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_bloc.dart';
import 'package:{{project_name}}/features/showcase_feed/presentation/states/feed_item_bloc.dart';
import 'package:{{project_name}}/utils/helpers/app_strings.dart';

import '../../helpers/mocks.dart';
import 'feed_samples.dart';

/// The showcase feed's two blocs — the reference for a feature's bloc tests
/// (`test/README.md` → «What gets tested in every feature»).
void main() {
  late MockFeedRepository repository;

  void answerFeed({required bool hasMore, int count = 10}) {
    when(
      () => repository.getFeed(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        query: any(named: 'query'),
        category: any(named: 'category'),
      ),
    ).thenAnswer(
      (_) async => Result<FeedPage>.success(
        FeedPage(
          items: FeedSamples.items(count),
          hasMore: hasMore,
          total: 30,
        ),
      ),
    );
  }

  setUp(() {
    repository = MockFeedRepository();
    when(repository.recentSearches).thenAnswer((_) async => <String>[]);
    when(
      () => repository.saveSearch(any()),
    ).thenAnswer((invocation) async => <String>[
          invocation.positionalArguments.first as String,
        ]);
    when(repository.getHighlights).thenAnswer(
      (_) async => Result<List<FeedItemEntity>>.success(FeedSamples.items(3)),
    );
    when(repository.getPicks).thenAnswer(
      (_) async => Result<List<FeedItemEntity>>.success(FeedSamples.items(4)),
    );
    answerFeed(hasMore: true);
  });

  group('FeedBloc', () {
    blocTest<FeedBloc, FeedState>(
      'started: the list goes loading then success — and the sections are '
      'NOT asked for (they load as they scroll near)',
      build: () => FeedBloc(repository),
      act: (bloc) => bloc.add(const FeedEvent.started()),
      verify: (bloc) {
        expect(bloc.state.listState.isSuccess, isTrue);
        expect(bloc.state.listState.getDataWhenSuccess, hasLength(10));
        expect(bloc.state.hasMore, isTrue);
        expect(bloc.state.highlightsState.isInit, isTrue);
        verifyNever(repository.getHighlights);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'a section asks once, however often it is built',
      build: () => FeedBloc(repository),
      act: (bloc) => bloc
        ..add(const FeedEvent.sectionRequested(FeedSection.highlights))
        ..add(const FeedEvent.sectionRequested(FeedSection.highlights)),
      verify: (bloc) {
        expect(bloc.state.highlightsState.isSuccess, isTrue);
        verify(repository.getHighlights).called(1);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'a failed section fails alone — the list and the other section stand',
      setUp: () => when(repository.getPicks).thenAnswer(
        (_) async => const Result<List<FeedItemEntity>>.failure('offline'),
      ),
      build: () => FeedBloc(repository),
      act: (bloc) => bloc
        ..add(const FeedEvent.started())
        ..add(const FeedEvent.sectionRequested(FeedSection.highlights))
        ..add(const FeedEvent.sectionRequested(FeedSection.picks)),
      verify: (bloc) {
        expect(bloc.state.picksState.isFailed, isTrue);
        expect(bloc.state.highlightsState.isSuccess, isTrue);
        expect(bloc.state.listState.isSuccess, isTrue);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'the next page is APPENDED, and a second request while loading is '
      'ignored',
      build: () => FeedBloc(repository),
      act: (bloc) async {
        bloc.add(const FeedEvent.started());
        await Future<void>.delayed(Duration.zero);
        answerFeed(hasMore: false);
        bloc
          ..add(const FeedEvent.loadMore())
          ..add(const FeedEvent.loadMore());
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.listState.getDataWhenSuccess, hasLength(20));
        expect(bloc.state.page, 2);
        expect(bloc.state.hasMore, isFalse);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'a failed next page keeps what is on screen',
      build: () => FeedBloc(repository),
      act: (bloc) async {
        bloc.add(const FeedEvent.started());
        await Future<void>.delayed(Duration.zero);
        when(
          () => repository.getFeed(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
            category: any(named: 'category'),
          ),
        ).thenAnswer((_) async => const Result<FeedPage>.failure('offline'));
        bloc.add(const FeedEvent.loadMore());
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.loadMoreState.isFailed, isTrue);
        expect(bloc.state.listState.getDataWhenSuccess, hasLength(10));
      },
    );

    blocTest<FeedBloc, FeedState>(
      'a search is remembered and reloads the list from page one',
      build: () => FeedBloc(repository),
      act: (bloc) => bloc.add(const FeedEvent.querySubmitted('  garden ')),
      verify: (bloc) {
        expect(bloc.state.query, 'garden');
        expect(bloc.state.recentSearches, <String>['garden']);
        verify(
          () => repository.getFeed(
            page: 1,
            limit: FeedBloc.pageSize,
            query: 'garden',
          ),
        ).called(1);
      },
    );

    blocTest<FeedBloc, FeedState>(
      'the search field hides on a scroll down and returns on any scroll up',
      build: () => FeedBloc(repository),
      act: (bloc) => bloc
        ..add(const FeedEvent.scrolled(200))
        ..add(const FeedEvent.scrolled(190)),
      expect: () => <Matcher>[
        isA<FeedState>().having((s) => s.isSearchVisible, 'hidden', isFalse),
        isA<FeedState>().having((s) => s.isSearchVisible, 'back', isTrue),
      ],
    );
  });

  group('FeedItemBloc', () {
    blocTest<FeedItemBloc, FeedItemState>(
      'loads the item, then «More like this» without the item itself',
      setUp: () {
        when(
          () => repository.getItem('item_001'),
        ).thenAnswer((_) async => Result.success(FeedSamples.item()));
        answerFeed(hasMore: false, count: 3);
      },
      build: () => FeedItemBloc(repository),
      act: (bloc) => bloc.add(const FeedItemEvent.started('item_001')),
      verify: (bloc) {
        expect(bloc.state.detailState.isSuccess, isTrue);
        final related = bloc.state.relatedState.getDataWhenSuccess!;
        expect(related.map((i) => i.id), isNot(contains('item_001')));
      },
    );

    blocTest<FeedItemBloc, FeedItemState>(
      'a gone item fails with the not-found message the page tells apart',
      setUp: () => when(() => repository.getItem('nope')).thenAnswer(
        (_) async => Result<FeedItemEntity>.failure(AppStrings.clientNotFound),
      ),
      build: () => FeedItemBloc(repository),
      act: (bloc) => bloc.add(const FeedItemEvent.started('nope')),
      verify: (bloc) {
        expect(bloc.state.detailState.errorMessage, AppStrings.clientNotFound);
        expect(bloc.state.relatedState.isInit, isTrue);
      },
    );

    blocTest<FeedItemBloc, FeedItemState>(
      'save, then undo: back where it started, and each toggle is counted',
      build: () => FeedItemBloc(repository),
      act: (bloc) => bloc
        ..add(const FeedItemEvent.saveToggled())
        ..add(const FeedItemEvent.saveToggled()),
      verify: (bloc) {
        expect(bloc.state.isSaved, isFalse);
        expect(bloc.state.saveToggles, 2);
      },
    );
  });
}
