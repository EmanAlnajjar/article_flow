import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/use_cases/notification_use_cases.dart';
import 'notifications_state.dart';

class NotificationsCubit
    extends Cubit<NotificationsState> {
  final WatchNotificationsUseCase
  _watchNotificationsUseCase;

  final MarkNotificationAsReadUseCase
  _markNotificationAsReadUseCase;

  final MarkAllNotificationsAsReadUseCase
  _markAllNotificationsAsReadUseCase;

  final DeleteNotificationUseCase
  _deleteNotificationUseCase;

  final ClearNotificationsUseCase
  _clearNotificationsUseCase;

  StreamSubscription<List<NotificationEntity>>?
  _notificationsSubscription;

  NotificationsCubit({
    required WatchNotificationsUseCase
    watchNotificationsUseCase,
    required MarkNotificationAsReadUseCase
    markNotificationAsReadUseCase,
    required MarkAllNotificationsAsReadUseCase
    markAllNotificationsAsReadUseCase,
    required DeleteNotificationUseCase
    deleteNotificationUseCase,
    required ClearNotificationsUseCase
    clearNotificationsUseCase,
  }) : _watchNotificationsUseCase =
      watchNotificationsUseCase,
        _markNotificationAsReadUseCase =
            markNotificationAsReadUseCase,
        _markAllNotificationsAsReadUseCase =
            markAllNotificationsAsReadUseCase,
        _deleteNotificationUseCase =
            deleteNotificationUseCase,
        _clearNotificationsUseCase =
            clearNotificationsUseCase,
        super(const NotificationsState()) {
    _watchNotifications();
  }

  void _watchNotifications() {
    emit(
      state.copyWith(
        status: NotificationsStatus.loading,
        clearError: true,
      ),
    );

    _notificationsSubscription =
        _watchNotificationsUseCase().listen(
              (notifications) {
            if (isClosed) {
              return;
            }

            emit(
              state.copyWith(
                status: NotificationsStatus.success,
                notifications: notifications,
                isProcessing: false,
                clearError: true,
              ),
            );
          },
          onError: (Object error) {
            if (isClosed) {
              return;
            }

            emit(
              state.copyWith(
                status: NotificationsStatus.failure,
                isProcessing: false,
                errorMessage: _getErrorMessage(error),
              ),
            );
          },
        );
  }

  Future<void> markAsRead(
      String id,
      ) async {
    if (state.isProcessing) {
      return;
    }

    emit(
      state.copyWith(
        isProcessing: true,
        clearError: true,
      ),
    );

    try {
      await _markNotificationAsReadUseCase(
        id: id,
      );

      if (!isClosed) {
        emit(
          state.copyWith(
            isProcessing: false,
            clearError: true,
          ),
        );
      }
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<void> markAllAsRead() async {
    if (state.isProcessing ||
        !state.hasUnreadNotifications) {
      return;
    }

    emit(
      state.copyWith(
        isProcessing: true,
        clearError: true,
      ),
    );

    try {
      await _markAllNotificationsAsReadUseCase();

      if (!isClosed) {
        emit(
          state.copyWith(
            isProcessing: false,
            clearError: true,
          ),
        );
      }
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<void> deleteNotification(
      String id,
      ) async {
    if (state.isProcessing) {
      return;
    }

    try {
      await _deleteNotificationUseCase(
        id: id,
      );
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<void> clearNotifications() async {
    if (state.isProcessing ||
        state.notifications.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        isProcessing: true,
        clearError: true,
      ),
    );

    try {
      await _clearNotificationsUseCase();

      if (!isClosed) {
        emit(
          state.copyWith(
            isProcessing: false,
            clearError: true,
          ),
        );
      }
    } catch (error) {
      _emitFailure(error);
    }
  }

  void _emitFailure(Object error) {
    if (isClosed) {
      return;
    }

    emit(
      state.copyWith(
        status: NotificationsStatus.failure,
        isProcessing: false,
        errorMessage: _getErrorMessage(error),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }

    return 'Unable to update notifications.';
  }

  @override
  Future<void> close() async {
    await _notificationsSubscription?.cancel();

    return super.close();
  }
}