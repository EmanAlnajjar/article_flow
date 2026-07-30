import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_router.dart';
import '../../domain/entities/notification_entity.dart';
import '../cubite/notifications_cubit.dart';
import '../cubite/notifications_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() {
    return _NotificationsPageState();
  }
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  bool _showUnreadOnly = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
        NotificationsCubit,
        NotificationsState
    >(
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
            ),
          );
      },
      builder: (context, state) {
        final notifications =
        _showUnreadOnly
            ? state.unreadNotifications
            : state.notifications;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              if (state.hasUnreadNotifications)
                IconButton(
                  tooltip: 'Mark all as read',
                  onPressed:
                  state.isProcessing
                      ? null
                      : () {
                    context
                        .read<
                        NotificationsCubit
                    >()
                        .markAllAsRead();
                  },
                  icon: const Icon(
                    Icons.done_all_rounded,
                  ),
                ),
              if (state.notifications.isNotEmpty)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'clear') {
                      _confirmClear(context);
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_sweep_outlined,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Clear notifications',
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _FilterSelector(
                  showUnreadOnly:
                  _showUnreadOnly,
                  unreadCount: state.unreadCount,
                  onChanged: (value) {
                    setState(() {
                      _showUnreadOnly = value;
                    });
                  },
                ),
                Expanded(
                  child: _buildContent(
                    context: context,
                    state: state,
                    notifications: notifications,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required NotificationsState state,
    required List<NotificationEntity>
    notifications,
  }) {
    if (state.status ==
        NotificationsStatus.loading &&
        state.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status ==
        NotificationsStatus.failure &&
        state.notifications.isEmpty) {
      return _NotificationsMessage(
        icon: Icons.error_outline_rounded,
        title: 'Unable to load notifications',
        message:
        state.errorMessage ??
            'Please try again later.',
      );
    }

    if (notifications.isEmpty) {
      return _NotificationsMessage(
        icon:
        _showUnreadOnly
            ? Icons.mark_email_read_outlined
            : Icons.notifications_none_rounded,
        title:
        _showUnreadOnly
            ? 'You are all caught up'
            : 'No notifications yet',
        message:
        _showUnreadOnly
            ? 'You have no unread notifications.'
            : 'New updates will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        28,
      ),
      itemCount: notifications.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return Dismissible(
          key: ValueKey(notification.id),
          direction:
          DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding:
            const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.errorContainer,
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(
                context,
              ).colorScheme.onErrorContainer,
            ),
          ),
          onDismissed: (_) {
            context
                .read<NotificationsCubit>()
                .deleteNotification(
              notification.id,
            );
          },
          child: _NotificationCard(
            notification: notification,
            onTap: () {
              _openNotification(
                context,
                notification,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _openNotification(
      BuildContext context,
      NotificationEntity notification,
      ) async {
    await context
        .read<NotificationsCubit>()
        .markAsRead(notification.id);

    if (!context.mounted ||
        !notification.opensArticle) {
      return;
    }

    context.pushNamed(
      AppRouter.articleNotificationName,
      pathParameters: {
        'articleId':
        notification.articleId.toString(),
      },
    );
  }

  Future<void> _confirmClear(
      BuildContext context,
      ) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_sweep_outlined,
          ),
          title: const Text(
            'Clear notifications?',
          ),
          content: const Text(
            'This will permanently remove all saved notifications.',
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
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true ||
        !context.mounted) {
      return;
    }

    await context
        .read<NotificationsCubit>()
        .clearNotifications();
  }
}

class _FilterSelector extends StatelessWidget {
  final bool showUnreadOnly;
  final int unreadCount;
  final ValueChanged<bool> onChanged;

  const _FilterSelector({
    required this.showUnreadOnly,
    required this.unreadCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12,
      ),
      child: SegmentedButton<bool>(
        segments: [
          ButtonSegment<bool>(
            value: true,
            icon: const Icon(
              Icons.mark_email_unread_outlined,
            ),
            label: Text(
              'Unread ($unreadCount)',
            ),
          ),
          const ButtonSegment<bool>(
            value: false,
            icon: Icon(
              Icons.notifications_outlined,
            ),
            label: Text('All'),
          ),
        ],
        selected: {
          showUnreadOnly,
        },
        onSelectionChanged: (selection) {
          onChanged(selection.first);
        },
        showSelectedIcon: false,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color:
      notification.isRead
          ? colors.surface
          : colors.primaryContainer
          .withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color:
              notification.isRead
                  ? colors.outlineVariant
                  : colors.primary.withValues(
                alpha: 0.35,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                  notification.opensArticle
                      ? colors.secondaryContainer
                      : colors.tertiaryContainer,
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Icon(
                  notification.opensArticle
                      ? Icons.article_outlined
                      : Icons.notifications_outlined,
                  color:
                  notification.opensArticle
                      ? colors.onSecondaryContainer
                      : colors.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight:
                              notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      maxLines: 3,
                      overflow:
                      TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDate(
                        notification.receivedAt,
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color:
                        colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final notificationDay = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );

    final time =
        '${localDate.hour.toString().padLeft(2, '0')}:'
        '${localDate.minute.toString().padLeft(2, '0')}';

    if (notificationDay == today) {
      return 'Today at $time';
    }

    if (notificationDay ==
        today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $time';
    }

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year} at $time';
  }
}

class _NotificationsMessage
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _NotificationsMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: Theme.of(
                context,
              ).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}