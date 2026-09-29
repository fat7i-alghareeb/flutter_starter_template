import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name}}/core/services/session/pending_action.dart';

void main() {
  late PendingActionQueue queue;

  setUp(() => queue = PendingActionQueue());

  group('PendingActionQueue', () {
    test('starts empty', () {
      expect(queue.hasPending, isFalse);
      expect(queue.pending, isNull);
    });

    test('runs what was remembered, then forgets it', () async {
      // The point of the whole gate design: a guest taps save, signs in, and
      // the item is saved FOR them — they never hunt for it again.
      var ran = 0;
      queue.remember(ProtectedAction.save, () async => ran++);

      expect(queue.pending, ProtectedAction.save);
      await queue.runPending();

      expect(ran, 1);
      expect(queue.hasPending, isFalse);
    });

    test('never replays the same action twice', () async {
      var ran = 0;
      queue.remember(ProtectedAction.like, () async => ran++);

      await queue.runPending();
      await queue.runPending();

      expect(ran, 1);
    });

    test('a newer intent replaces an older one', () async {
      // The user is acting on the newest thing they touched. Replaying a
      // forgotten earlier tap would change data behind their back.
      final ran = <String>[];
      queue.remember(ProtectedAction.save, () async => ran.add('save'));
      queue.remember(ProtectedAction.comment, () async => ran.add('comment'));

      await queue.runPending();

      expect(ran, <String>['comment']);
    });

    test('clear disarms it', () async {
      var ran = 0;
      queue.remember(ProtectedAction.save, () async => ran++);
      queue.clear();
      await queue.runPending();

      expect(ran, 0);
    });

    test('runPending on an empty queue is safe', () async {
      await expectLater(queue.runPending(), completes);
    });

    test('a failing action does NOT take the sign-in down with it', () async {
      // The user IS signed in at this point; that part succeeded. Throwing here
      // would present a successful sign-in as a failure.
      queue.remember(
        ProtectedAction.save,
        () async => throw StateError('server said no'),
      );

      await expectLater(queue.runPending(), completes);
      expect(queue.hasPending, isFalse);
    });
  });

  group('ProtectedAction', () {
    test('every action has its own sign-in line', () {
      // The sheet names the ACTION. Two actions sharing a sentence would
      // tell one of them the wrong thing.
      final prompts = ProtectedAction.values.map((a) => a.prompt).toList();

      expect(prompts.toSet().length, prompts.length);
      for (final prompt in prompts) {
        expect(prompt.trim(), isNotEmpty);
      }
    });

    test('every action has its own glyph and benefit line', () {
      for (final action in ProtectedAction.values) {
        expect(action.icon, isNotEmpty, reason: action.name);
        expect(action.benefit.trim(), isNotEmpty, reason: action.name);
      }
    });
  });
}
