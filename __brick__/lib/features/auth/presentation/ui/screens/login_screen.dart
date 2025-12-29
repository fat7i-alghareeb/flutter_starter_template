import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../common/widgets/button/app_button.dart';
import '../../../../../common/widgets/button/app_button_child.dart';
import '../../../../../common/widgets/app_icon_source.dart';
import '../../../../../common/widgets/custom_scaffold/app_scaffold.dart';
import '../../../../../core/injection/injectable.dart';
import '../../../../../core/utils/bloc_status.dart';
import '../../../../../utils/extensions/widget_extensions.dart';
import '../../states/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  static const String pagePath = '/login_screen';
  static const String pageName = 'LoginScreen';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(const AuthEvent.started()),
      child: const _LoginScreenBody(),
    );
  }
}

class _LoginScreenBody extends StatelessWidget {
  const _LoginScreenBody();

  @override
  Widget build(BuildContext context) {
    return AppScaffold.appBar(
      appBarConfig: const AppScaffoldAppBarConfig(
        title: 'Login',
        showLeading: false,
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) =>
            previous.loginStatus != current.loginStatus,
        builder: (context, state) {
          return Center(
            child: AppButton.primary(
              child: AppButtonChild.labelIcon(
                label: 'Login',
                icon: IconSource.icon(Icons.login),
              ),
              isLoading: state.loginStatus.isLoading,
              onTap: () {
                context.read<AuthBloc>().add(const AuthEvent.loginRequested());
              },
            ).symmetricPadding(h: 16, v: 16),
          );
        },
      ),
    );
  }
}
