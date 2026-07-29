import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../authentication/domain/entities/auth_user_entity.dart';
import '../../authentication/presentation/cubit/auth_cubit.dart';
import '../../authentication/presentation/cubit/auth_state.dart';
import '../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../favorites/presentation/cubit/favorites_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
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
        final user = authState.user;
        final isLoading = authState.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                32,
              ),
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: 20),
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  buildWhen: (previous, current) {
                    return previous.favorites.length !=
                        current.favorites.length;
                  },
                  builder: (context, state) {
                    return _ProfileStatistic(
                      icon: Icons.favorite_rounded,
                      title: 'Saved articles',
                      value: '${state.favorites.length}',
                      color: colors.tertiary,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Account',
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _ProfileTile(
                  icon: Icons.email_outlined,
                  title: 'Email address',
                  subtitle:
                  user?.email.isNotEmpty == true
                      ? user!.email
                      : 'Email is unavailable',
                  onTap: () {},
                  showArrow: false,
                ),
                const SizedBox(height: 24),
                Text(
                  'Preferences',
                  style:
                  Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _ProfileTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle:
                  'Manage notification preferences',
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                const SizedBox(height: 10),
                _ProfileTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Appearance',
                  subtitle: 'Using your system theme',
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                const SizedBox(height: 10),
                _ProfileTile(
                  icon: Icons.info_outline_rounded,
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
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed:
                    isLoading
                        ? null
                        : () {
                      _confirmSignOut(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(
                        color: colors.error,
                      ),
                    ),
                    icon:
                    isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.error,
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
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true || !context.mounted) {
      return;
    }

    await context.read<AuthCubit>().signOut();
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'This feature will be connected in the next step.',
          ),
        ),
      );
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
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          _ProfileAvatar(user: user),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style:
            Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style:
            Theme.of(context).textTheme.bodyMedium,
          ),
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
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.primary,
          width: 3,
        ),
      ),
      child: ClipOval(
        child:
        photoUrl != null && photoUrl.isNotEmpty
            ? Image.network(
          photoUrl,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return _InitialsAvatar(
              initials: user?.initials ?? 'U',
            );
          },
        )
            : _InitialsAvatar(
          initials: user?.initials ?? 'U',
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

class _ProfileStatistic extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _ProfileStatistic({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style:
              Theme.of(
                context,
              ).textTheme.titleMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showArrow;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: showArrow ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: colors.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      Theme.of(
                        context,
                      ).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style:
                      Theme.of(
                        context,
                      ).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (showArrow)
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