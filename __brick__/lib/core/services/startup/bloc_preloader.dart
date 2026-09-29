import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio_refresh_bot/dio_refresh_bot.dart' show Status;

import '../../../utils/constants/app_flow_constants.dart';
import '../../../utils/helpers/colored_print.dart';
import '../onboarding/onboarding_service.dart';
import '../session/auth_state_notifier.dart';

/// Starts a screen's first requests behind the splash, so it is filled — or
/// nearly — by the time the reader sees it.
///
/// Without it nothing is asked for until the splash hands over and the screen
/// creates its bloc: the whole custom splash is time the network sits idle.
///
/// How it works (subclass it for your first tab, register it as a
/// `@lazySingleton`, call [start] from `bootstrap.dart` after the first frame,
/// and [claim] from the screen's `BlocProvider(create:)`):
///
/// 1. It waits for the **session read** (`AuthManager.initialize`, a few
///    local reads, well inside the splash). A request sent before it goes out
///    without the reader's token — the refresh interceptor reads the token
///    from memory, and memory is empty until that read is done.
/// 2. It waits for the onboarding flag. **On a first launch it does nothing**:
///    the splash leads to onboarding, not to this screen, and data fetched
///    then is fetched for nobody. The screen loads it itself later.
/// 3. With [AuthMode.loginRequired] it also does nothing for a reader who is
///    not signed in: the splash leads to the sign-in screen.
/// 4. Otherwise it creates the SAME bloc the screen would ([create]) and
///    lets [warmUp] fire its first events.
///
/// The screen [claim]s the bloc and owns it from then on — its provider
/// closes it. Claimed before anything started (a test, a bootstrap that timed
/// out, a first launch), it simply gets a fresh bloc from [create], exactly as
/// without a preloader. A preload only ever makes things faster, never
/// different: failures are logged and the screen shows its own states.
abstract class BlocPreloader<B extends BlocBase<Object?>> {
  BlocPreloader(this._authState, this._onboarding);

  final AuthStateNotifier _authState;
  final OnboardingService _onboarding;

  B? _bloc;
  bool _claimed = false;
  bool _listening = false;
  bool _decided = false;

  /// Log tag.
  String get name;

  /// A new bloc, exactly as the screen would create it — first event
  /// included (`getIt<FeedBloc>()..add(const FeedEvent.started())`).
  B create();

  /// Extra work once the bloc exists: ask for the first above-the-fold
  /// sections once the layout answers, for example. Optional.
  Future<void> warmUp(B bloc) async {}

  /// Called once the first frame is up — the moment the native splash goes.
  void start() {
    if (_claimed || _decided || _listening) return;
    if (_decide()) return;
    _listening = true;
    _authState.addListener(_onSourcesChanged);
    _onboarding.addListener(_onSourcesChanged);
    // Idempotent: bootstrap and the router ask for the same read.
    unawaited(_onboarding.initialize());
  }

  /// Hands the bloc — loading, or already loaded — to the screen.
  B claim() {
    _claimed = true;
    _stopListening();

    final bloc = _bloc;
    _bloc = null;
    if (bloc != null && !bloc.isClosed) {
      printG('[$name] handing over a preloaded bloc ⚡');
      return bloc;
    }
    return create();
  }

  bool get _sessionRead => _authState.authStatus.status != Status.initial;

  bool get _goesToOnboarding =>
      AppFlowConfig.onboardingEnabled && !_onboarding.isOnboardingFinishedSync;

  bool get _goesToLogin =>
      AppFlowConfig.authMode == AuthMode.loginRequired &&
      !_authState.isAuthenticated &&
      !_authState.isGuest;

  /// Loads, or settles on not loading, once both the session and the
  /// onboarding flag are read. False while either is still unknown.
  bool _decide() {
    if (!_sessionRead || !_onboarding.isInitialized) return false;
    _decided = true;
    if (_goesToOnboarding || _goesToLogin) {
      printC('[$name] this launch does not open on the screen → no preload');
      return true;
    }
    printC('[$name] session read → preloading behind the splash');
    final bloc = create();
    _bloc = bloc;
    unawaited(
      warmUp(bloc).catchError((Object e) {
        printY('[$name] warm-up failed: $e');
      }),
    );
    return true;
  }

  void _onSourcesChanged() {
    if (_claimed || _decide()) _stopListening();
  }

  void _stopListening() {
    if (!_listening) return;
    _listening = false;
    _authState.removeListener(_onSourcesChanged);
    _onboarding.removeListener(_onSourcesChanged);
  }
}
