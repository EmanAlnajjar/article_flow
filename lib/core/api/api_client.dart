import 'package:dio/dio.dart';

import '../errors/app_exception.dart';
import 'api_endpoints.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      return response.data;
    } on DioException catch (exception) {
      throw _handleDioException(exception);
    } catch (_) {
      throw const AppException(
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  AppException _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(
          message: 'The connection timed out. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const AppException(message: 'No internet connection.');

      case DioExceptionType.badResponse:
        return AppException(
          message: _getServerErrorMessage(exception.response),
          statusCode: exception.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return const AppException(message: 'The request was cancelled.');

      case DioExceptionType.badCertificate:
        return const AppException(
          message: 'Could not establish a secure connection.',
        );

      case DioExceptionType.unknown:
        return const AppException(message: 'Could not connect to the server.');

      default:
        return const AppException(
          message: 'An unexpected network error occurred.',
        );
    }
  }

  String _getServerErrorMessage(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    switch (statusCode) {
      case 400:
        return 'The request is invalid.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested data was not found.';
      case 500:
      case 502:
      case 503:
        return 'A server error occurred. Please try again later.';
      default:
        return 'Failed to load data.';
    }
  }
}
