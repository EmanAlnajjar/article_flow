import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../authentication/domain/entities/auth_user_entity.dart';
import '../../authentication/presentation/cubit/auth_cubit.dart';
import '../../authentication/presentation/cubit/auth_state.dart';
import '../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../favorites/presentation/cubit/favorites_state.dart';
import '../../notifications/ presentation/cubit/notifications_cubit.dart';
import '../../notifications/ presentation/cubit/notifications_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return previous.errorMessage !=
            current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: colors.error,
            ),
          );
      },
      builder: (context, authState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                32,
              ),
              children: [
                _ProfileHeader(
                  user: authState.user,
                ),

                const SizedBox(height: 28),
                Text(
                  'Preferences',
                  style:
                  Theme.of(
                    context,
                  ).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const _PreferencesCard(),
                const SizedBox(height: 28),
                _SignOutButton(
                  isLoading: authState.isLoading,
                  onPressed: () {
                    _confirmSignOut(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(
      BuildContext context,
      ) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.logout_rounded,
          ),
          title: const Text('Sign out?'),
          content: const Text(
            'You will need to sign in again to access your account.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true ||
        !context.mounted) {
      return;
    }

    await context.read<AuthCubit>().signOut();
  }
}

class _ProfileHeader extends StatelessWidget {
  final AuthUserEntity? user;

  const _ProfileHeader({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final displayName =
    user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'ArticleFlow Reader';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(
              alpha: 0.08,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileAvatar(user: user),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (user?.email.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              user!.email,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final AuthUserEntity? user;

  const _ProfileAvatar({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final photoUrl = user?.photoUrl;

    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(
              alpha: 0.18,
            ),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipOval(
        child:
        photoUrl != null &&
            photoUrl.isNotEmpty
            ? Image.network(
          photoUrl,
          width: 92,
          height: 92,
          fit: BoxFit.cover,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return _InitialsAvatar(
              initials:
              user?.initials ?? 'U',
            );
          },
        )
            : _InitialsAvatar(
          initials:
          user?.initials ?? 'U',
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surface,
      child: Center(
        child: Text(
          initials,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProfileStatistics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
        FavoritesCubit,
        FavoritesState
    >(
      buildWhen: (previous, current) {
        return previous.favorites.length !=
            current.favorites.length;
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color:
            Theme.of(
              context,
            ).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
              Theme.of(
                context,
              ).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .tertiaryContainer,
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onTertiaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved articles',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Your personal reading list',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '${state.favorites.length}',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          BlocBuilder<
              NotificationsCubit,
              NotificationsState
          >(
            buildWhen: (previous, current) {
              return previous.unreadCount !=
                  current.unreadCount;
            },
            builder: (context, state) {
              return _SettingsTile(
                icon:
                Icons.notifications_outlined,
                iconColor: colors.primary,
                iconBackground:
                colors.primaryContainer,
                title: 'Notifications',
                subtitle:
                state.unreadCount == 0
                    ? 'You are all caught up'
                    : '${state.unreadCount} unread '
                    '${state.unreadCount == 1 ? 'notification' : 'notifications'}',
                trailing: _NotificationBadge(
                  count: state.unreadCount,
                ),
                onTap: () {
                  context.pushNamed(
                    AppRouter.notificationsName,
                  );
                },
              );
            },
          ),
          const _SettingsDivider(),
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              final effectiveDark =
                  themeMode == ThemeMode.dark ||
                      (themeMode ==
                          ThemeMode.system &&
                          Theme.of(context).brightness ==
                              Brightness.dark);

              final subtitle =
              themeMode == ThemeMode.system
                  ? 'Following your system theme'
                  : effectiveDark
                  ? 'Dark mode is enabled'
                  : 'Light mode is enabled';

              return _SettingsTile(
                icon:
                effectiveDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                iconColor: colors.secondary,
                iconBackground:
                colors.secondaryContainer,
                title: 'Dark mode',
                subtitle: subtitle,
                trailing: Switch.adaptive(
                  value: effectiveDark,
                  onChanged: (_) {
                    context
                        .read<ThemeCubit>()
                        .toggleTheme(
                      currentBrightness:
                      Theme.of(
                        context,
                      ).brightness,
                    );
                  },
                ),
                onTap: () {
                  context
                      .read<ThemeCubit>()
                      .toggleTheme(
                    currentBrightness:
                    Theme.of(
                      context,
                    ).brightness,
                  );
                },
              );
            },
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: colors.tertiary,
            iconBackground:
            colors.tertiaryContainer,
            title: 'About ArticleFlow',
            subtitle: 'Version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'ArticleFlow',
                applicationVersion: '1.0.0',
                applicationLegalese:
                'A comfortable way to discover and save articles.',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 76,
      endIndent: 16,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant,
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const Icon(
        Icons.chevron_right_rounded,
      );
    }

    final colors = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 28,
        minHeight: 28,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(
          color: colors.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SignOutButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed:
        isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.errorContainer,
          foregroundColor:
          colors.onErrorContainer,
          elevation: 0,
        ),
        icon:
        isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color:
            colors.onErrorContainer,
          ),
        )
            : const Icon(
          Icons.logout_rounded,
        ),
        label: Text(
          isLoading
              ? 'Signing out...'
              : 'Sign out',
        ),
      ),
    );
  }
}