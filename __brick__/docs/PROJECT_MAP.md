# Project map

Where things live, so you can open the right file without reading the whole tree.
Rules for *how* to write code are in `.ai/project-rules.md`; this file is only the map.

## Top level

| Path | What it is |
| --- | --- |
| `lib/main.dart`, `lib/bootstrap.dart` | Entry point and start-up: DI, single instance (Windows), window set-up (desktop), saved theme and language before the first frame, `runApp`, then onboarding / session / notifications / first-tab preload |
| `lib/app.dart` | The root `App`: router, theme, localisation, text scale (`AppTextScaleHost`), layout host, title bar, shortcuts, offline and session banners, stage tools |
| `lib/core/` | Infrastructure with no product meaning (below) |
| `lib/common/` | Shared widgets and the `imports.dart` barrel |
| `lib/utils/` | Constants, extensions, helpers, generated code |
| `lib/features/` | Product features (below) |
| `assets/l10n/` | `ar.json`, `en.json` — dotted keys, plural groups |
| `assets/mock/` | Fixtures for `USE_MOCK=true`, one folder per feature (listed in `pubspec.yaml`) |
| `assets/svgIcons/`, `assets/fonts/` | Lucide icons; the bundled Tajawal font |
| `tool/` | `generate_app_strings.dart`, `generate_feature.dart`, `build_release_apk.dart`, `build_windows_installer.dart`, `build_macos_dmg.sh`, `setup_project.dart` + `setup/runner_patches.dart` (desktop runner patches and the Windows GUID, run once), `claude_test_filter.dart` (a Claude Code hook) |
| `test/`, `integration_test/` | Unit, bloc, widget, golden and contract tests; one boot test on a device |
| `android/ ios/ windows/ macos/ web/` | Created by `flutter create`; `windows/` and `macos/` runners are patched at generation time (`docs/DESKTOP_SETUP.md`) |
| `.ai/` | Rules for AI agents, any tool. Start with `project-rules.md` |
| `CLAUDE.md`, `.claude/` | Claude Code set-up: a small `CLAUDE.md` (token discipline, imports the digest), `settings.json` (permissions, a test-output hook), path-scoped `rules/`, manual `skills/` (`/first-run`, `/new-feature`, `/add-string`, `/release`) |
| `.vscode/launch.json` | Launch configurations (debug / profile / release × mock data × stage tools) |
| `codemagic.yaml` | CI release workflows (`docs/CODEMAGIC.md`) |
| `pubspec.yaml` | Dependencies, assets, `msix_config` (Windows Store package), version (the only source of the version) |
| `flutter_launcher_icons.yaml`, `flutter_native_splash.yaml` | Icon and splash generation, including the page colour |

## `docs/`

| File | Read it for |
| --- | --- |
| `NEW_PROJECT_CHECKLIST.md` | The manual steps for a new project: create, Claude set-up, brand, release |
| `COMMANDS.md` | Every command, `--dart-define` and tool |
| `DECISIONS.md` | Durable decisions and the reasons behind them |
| `RESPONSIVE.md` | Window size classes, adaptive widgets, input, text size |
| `DESKTOP_SETUP.md` | Windows and macOS: runner patches, title bar, installers, links, warnings |
| `FEATURE_SPEC_TEMPLATE.md` | The spec a new feature starts from |
| `AGENT_TASK_PROMPT_TEMPLATE.md` | Copy-paste prompts for the person driving an agent |
| `ANDROID_RELEASE_SETUP.md`, `IOS_SETUP.md` | Native release setup, file by file |
| `CODEMAGIC.md`, `SHOREBIRD.md` | CI; optional over-the-air patches |
| `PERFORMANCE_AUDIT.md` | Start-up, frame-rate and size notes |

## `lib/core/`

| Folder | Holds |
| --- | --- |
| `config/` | `app_config.dart` (app title, stage tools, desktop ids), `localization_config.dart`, `mock_config.dart` (`MockConfig`, `MockRoutes`) |
| `layout/` | `app_layout.dart` (`AppLayout`, `WindowSize`), `app_breakpoints.dart`, `app_layout_scope.dart`, `adaptive_layout.dart`, `layout_reader.dart`, `adaptive_typography.dart` (`AppTextScale`, `AppTextScaleHost`, `AdaptiveTypography`), `app_scroll_behavior.dart` |
| `platform/` | `app_platform.dart` — what the platform can do (`supportsPush`, `isDesktop`, `rendersFlagEmoji`, …) |
| `window/` | `app_window.dart` (size, position, hidden-until-first-frame), `app_title_bar.dart` (custom title bar, caption buttons) |
| `shortcuts/` | `app_shortcuts.dart`, `app_commands.dart`, `app_shortcut_catalog.dart`, `app_menu_bar.dart` (macOS menu bar) |
| `router/` | `router_config.dart` (guard), `app_routes.dart` (`AppPage`, `AppRouteTree`), `app_navigator.dart`, `app_links.dart` (`AppLinks`, `LinkDispatcher`), `desktop_links.dart`, `app_page_transitions.dart` |
| `network/` | `dio_client.dart`, `api_config.dart`, `api_endpoints.dart`, `interceptors/` (mock, offline cache, memory, JWT refresh, localisation, log, error), `offline/` (response cache) |
| `notification/` | Local and push notifications: coordinator, services, payloads, permission, timezone |
| `services/` | `storage/`, `session/` (auth, tokens, pending action), `onboarding/`, `localization/`, `objectbox/`, `memory/`, `haptics/`, `startup/` (`bloc_preloader.dart`) |
| `theme/` | `app_colors.dart` (the palette — one file to rebrand), `app_theme_colors.dart`, `app_theme.dart`, `app_typography.dart`, `app_text_styles.dart` (legacy aliases), `app_theme_effects.dart`, `theme_controller.dart`, system UI |
| `injection/` | GetIt + Injectable (`injectable.dart`, `register_module.dart`, generated config) |
| `error/` | `app_exception.dart`, `global_error_handler.dart` (`runAsResult`, `rethrowAsAppException`) |
| `utils/` | `result.dart` (`Result<T>`), `bloc_status.dart` (`BlocStatus<T>`), `status_builder.dart` (`StatusBuilder<T>`) |
| `domain/` | Shared entities (`user_entity.dart`) |

## `lib/common/`

`imports/imports.dart` is the barrel most feature files import. `widgets/`:

| Folder / file | Holds |
| --- | --- |
| `ds/` (barrel `ds.dart`) | The design system: skeletons, motion kit, cards, badges, `AppCountBadge`, chips, icons, rails and carousels, `AppContentWidth`, `AppFocusRing`, `AppContextMenu`, `AppSettingsTile`, `AppStatusBanner`, `AppHeroDetailLayout`, `AppActionCapsule`, `AppBarAction`, … |
| `button/` | `AppButton`, its variants (grey = inactive only), child layouts |
| `form/` | `AppReactiveTextField`, `date_time_field/`, `dropdown_field/`, `AppFormFieldGrid`, field defaults, validation messages |
| `custom_scaffold/` | `AppScaffold` (`.body`, `.appBar`, `.search`, `.all`) and its parts |
| `app_dialog.dart`, `app_bottom_sheet.dart` | Dialogs and sheets (a sheet becomes a dialog in wide windows) |
| `app_gallery_screen.dart`, `full_screen_image_screen.dart`, `app_image_viewer.dart` | Image viewing |
| `empty_state_widget.dart`, `failed_state_widget.dart`, `main_loading_progress.dart`, `loading_dots.dart` | Standard states and loaders |
| `scroll_reveal.dart`, `nav_bar_visibility.dart`, `top_banner_slot.dart`, `rebuild_on_locale_change.dart`, `show_overlay.dart` | Shell-wide behaviour |
| `stage_tools/` | QA overlay (device preview, language, theme), compiled out without `STAGE_TOOLS=true` |

Read `lib/common/common_folder_guide.md` before you create a reusable widget.

## `lib/utils/`

`constants/` (`design_constants.dart` — `AppSpacing`, `AppRadii`, `AppIconSizes`, `AppDurations`; `app_flow_constants.dart` —
`AppFlowConfig`, `AuthMode`, `AppThemeConfig`, `SplashConfig`; auth and localisation constants), `extensions/` (context, theme,
date, string, widget, reactive forms, numbers), `helpers/` (`app_strings.dart`, `app_formats.dart`, `colored_print.dart`,
`input_formatters.dart`, JWT, device), `gen/` (generated `AppStrings` and FlutterGen assets).
Read `lib/utils/utils_folder_guide.md` before you add a helper.

## `lib/features/`

| Feature | What it is |
| --- | --- |
| `splash/` | The start screen |
| `onboarding/` | First-launch slides |
| `auth/` | Sign-in screen (wall or pushed page, with the brand panel in wide windows), sign-in sheet for protected actions, session-expired banner. The full-structure example |
| `root/` | The shell: `RootScreen`, the capsule / rail / sidebar navigation, tab stack, back guard, and the demo tabs in `widgets/showcase/` (Buttons, Forms, Dialogs, Alerts) |
| `settings/` | Settings: language, theme, shortcuts list, account |
| `showcase_feed/` | The behaviour reference: lazy sections, paging, search, detail page, skeletons, mock data. Delete it, with `assets/mock/showcase/` and the demo tabs, when your own features replace it |

A feature's shape: `constants/`, `data/{datasources,models,mappers,params,repositories}`,
`domain/{entities,repositories,facade}`, `presentation/{states,ui/screens,ui/widgets}` — see `.ai/architecture-rules.md`.

## Guides for one area

| Area | File |
| --- | --- |
| Start-up and the root | `lib/lib_overview.md` |
| How a screen is put together | `lib/ui_overview.md` |
| Core layer | `lib/core/core_architecture_overview.md` |
| Features, bloc, data layer | `lib/features/features_overview.md` |
| Router, guard, links | `lib/core/router/router_guide.md` |
| Session and auth | `lib/core/services/session/session_service_guide.md` |
| Storage, ObjectBox | `lib/core/services/objectbox/objectbox_service_guide.md` |
| Notifications | `lib/core/notification/notification.md` |
| Date and time fields | `lib/common/widgets/form/date_time_field/app_reactive_date_time.md` |
| Shared widgets | `lib/common/common_folder_guide.md` |
| Helpers, extensions, constants | `lib/utils/utils_folder_guide.md` |
