import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../common/widgets/custom_scaffold/app_scaffold.dart';
import '../../../../../common/widgets/ds/ds.dart';
import '../../../../../common/widgets/form/app_reactive_text_field.dart';
import '../../../../../core/config/mock_config.dart';
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/network/api_config.dart';
import '../../../../../core/services/session/auth_state_notifier.dart';
import '../../../../../core/utils/bloc_status.dart';
import '../../../../../utils/constants/app_flow_constants.dart';
import '../../../../../utils/constants/design_constants.dart';
import '../../../../../utils/extensions/theme_extensions.dart';
import '../../../../../utils/helpers/app_strings.dart';
import '../../../constants/auth_constants.dart';
import '../../states/auth_bloc.dart';

/// The sign-in screen.
///
/// It plays two parts, by [AppFlowConfig.authMode]:
/// - [AuthMode.loginRequired]: the wall at [wallPath]. The router sends a
///   reader here after onboarding and moves them on by itself once they are
///   signed in — nothing on this screen navigates.
/// - [AuthMode.guestFirst]: a page PUSHED over the app (from the
///   session-expired banner, a settings row…). It closes itself: the close
///   button, «Continue as guest» and a successful sign-in all return to the
///   screen underneath.
///
/// An email and a password, validated on the device before anything is
/// sent (`AuthRepository.signIn`). With no backend yet — `USE_MOCK=true`, or
/// no base URL in `ApiConfig` — both are filled in with the demo identity, so
/// «Sign in» works out of the box. Swap the form for OTP or a provider
/// button in `_LoginForm`.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  /// The segment under the page that opens it (`AppPage.login`).
  static const String pagePath = 'login';

  /// The top-level route of the login wall.
  static const String wallPath = '/login';

  static const String pageName = 'LoginScreen';

  /// Back to whatever was under this page. On the wall there is nothing
  /// under it, and the router moves on by itself.
  static void close(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      Navigator.of(context).maybePop();
    } else if (router.canPop()) {
      router.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // `create`, not `.value(getIt())`: `AuthBloc` is a DI factory, and one
    // asked for inside `build` is a NEW bloc on every rebuild — a sign-in
    // started in one lands on another nobody listens to. One bloc for the
    // life of the page, closed with it.
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>(),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatefulWidget {
  const _LoginBody();

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody> {
  /// No backend to check the credentials against: the demo session answers
  /// whatever is typed, so the fields start filled in.
  static bool get _isDemo => MockConfig.enabled || ApiConfig.baseUrl.isEmpty;

  late final FormGroup _form = FormGroup(<String, AbstractControl<Object?>>{
    _LoginForm.email: FormControl<String>(
      value: _isDemo ? MockConfig.userEmail : null,
      validators: <Validator<dynamic>>[Validators.required, Validators.email],
    ),
    _LoginForm.password: FormControl<String>(
      value: _isDemo ? 'demo1234' : null,
      validators: <Validator<dynamic>>[
        Validators.required,
        Validators.minLength(_LoginForm.minPasswordLength),
      ],
    ),
  });

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthEvent.signInRequested(
        email: (_form.control(_LoginForm.email).value as String).trim(),
        password: _form.control(_LoginForm.password).value as String,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < AuthConstants.compactWidth;
    final margin = isCompact ? AppSpacing.md : AppSpacing.screenMargin;
    final canClose = GoRouter.maybeOf(context)?.canPop() ?? false;
    final guestFirst = AppFlowConfig.authMode == AuthMode.guestFirst;
    final expired =
        getIt.isRegistered<AuthStateNotifier>() &&
        getIt<AuthStateNotifier>().sessionExpired;

    return AppScaffold.body(
      scaffoldConfig: AppScaffoldConfig(
        backgroundColor: context.semantic.background,
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.signInStatus != current.signInStatus,
        // Success: back to what the reader was doing, not a welcome screen.
        listener: (context, state) {
          if (state.signInStatus.isSuccess) LoginScreen.close(context);
        },
        builder: (context, state) {
          return Column(
            children: <Widget>[
              // The close button on the START side — not a back arrow: this
              // page closes.
              SizedBox(
                height: AppIconSizes.minTouchTarget + AppSpacing.sm,
                child: canClose
                    ? Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(
                            AppSpacing.xs,
                          ),
                          child: AppBarAction(
                            icon: AppIcons.close,
                            label: AppStrings.actionClose,
                            onTap: () => LoginScreen.close(context),
                          ),
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: margin,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AuthConstants.maxContentWidth,
                      ),
                      child: Column(
                        children: <Widget>[
                          AppStateDisc(
                            child: AppIcon(
                              AppIcons.user,
                              size: 34,
                              color: AppStateDisc.iconColor(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            AppStrings.authTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            expired
                                ? AppStrings.authSessionExpired
                                : AppStrings.authSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: expired
                                  ? colors.error
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _LoginForm(
                            form: _form,
                            enabled: !state.signInStatus.isLoading,
                            onSubmit: () => _submit(context),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: state.signInStatus.isLoading
                                ? null
                                : () => _submit(context),
                            child: state.signInStatus.isLoading
                                ? SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.onPrimary,
                                    ),
                                  )
                                : Text(AppStrings.authSignIn),
                          ),
                          if (state.signInStatus.isFailed) ...<Widget>[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              AppStrings.authFailed,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.error,
                              ),
                            ),
                          ] else if (state.wasCancelled) ...<Widget>[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              // Backing out is a choice, not a fault — so this
                              // line is the muted colour, never `error`.
                              AppStrings.authCancelled,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          // The terms sit UNDER the button.
                          Text(
                            AppStrings.authTerms,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // «Continue as guest» at the bottom, muted: in guest-first mode
              // the app is worth opening either way.
              if (guestFirst)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    if (canClose) {
                      LoginScreen.close(context);
                    } else {
                      context.read<AuthBloc>().add(
                        const AuthEvent.continueAsGuestRequested(),
                      );
                    }
                  },
                  child: Text(AppStrings.authBrowseAsGuest),
                ),
              SizedBox(
                height:
                    AppSpacing.lg + MediaQuery.viewPaddingOf(context).bottom,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The two fields. Validation runs on the device: an empty field or a
/// malformed address never reaches the server.
class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.form,
    required this.enabled,
    required this.onSubmit,
  });

  static const String email = 'email';
  static const String password = 'password';
  static const int minPasswordLength = 6;

  final FormGroup form;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: form,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppReactiveTextField.email(
              formControlName: email,
              title: AppStrings.authEmail,
              isRequired: true,
              enabled: enabled,
              hintText: 'name@example.com',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppReactiveTextField.password(
              formControlName: password,
              title: AppStrings.authPassword,
              isRequired: true,
              enabled: enabled,
              textInputAction: TextInputAction.done,
              onSubmitted: (_, _) => onSubmit(),
            ),
          ],
        ),
      ),
    );
  }
}
