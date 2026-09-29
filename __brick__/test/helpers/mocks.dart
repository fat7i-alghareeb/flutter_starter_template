import 'package:mocktail/mocktail.dart';
import 'package:{{project_name}}/core/domain/user_entity.dart';
import 'package:{{project_name}}/core/services/session/pending_action.dart';
import 'package:{{project_name}}/core/utils/result.dart';
import 'package:{{project_name}}/core/services/session/auth_manager.dart';
import 'package:{{project_name}}/features/auth/domain/facade/auth_facade.dart';
import 'package:{{project_name}}/features/showcase_feed/data/feed_data.dart';

/// Shared fakes.
///
/// Kept in one file so a facade is faked once. Two tests each writing their own
/// `MockAuthFacade` is how the two quietly drift apart.

class MockAuthFacade extends Mock implements AuthFacade {}

/// The session, for the two blocs that end it — signing out and deleting
/// the account.
class MockAuthManager extends Mock implements AuthManager {}

class MockFeedRepository extends Mock implements FeedRepository {}

class MockPendingActionQueue extends Mock implements PendingActionQueue {}

/// A real queue that records what ran, for asserting on resume behaviour.
class RecordingPendingActionQueue extends PendingActionQueue {
  final List<ProtectedAction> resumed = <ProtectedAction>[];

  @override
  Future<void> runPending() async {
    final action = pending;
    await super.runPending();
    if (action != null) resumed.add(action);
  }
}

/// Convenience builders so a test reads as intent, not as plumbing.
Result<UserEntity> successUser({String id = 'usr_001', String? name}) =>
    Result<UserEntity>.success(UserEntity(id: id, name: name));

Result<T> failure<T>(String message) => Result<T>.failure(message);
