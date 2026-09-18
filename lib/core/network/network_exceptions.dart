import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException({required this.message, this.statusCode});

  factory NetworkException.fromDioException(DioException dioError) {
    String message;
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = 'Request to API server was cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout with API server';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout in connection with API server';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout in connection with API server';
        break;
      case DioExceptionType.badResponse:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection or server is unreachable.';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'Unexpected error occurred: ${dioError.message}';
        break;
    }
    return NetworkException(
      message: message,
      statusCode: dioError.response?.statusCode,
    );
  }

  static String _handleError(int? statusCode, dynamic errorData) {
    switch (statusCode) {
      case 400:
        return 'Bad request (400)';
      case 401:
        return 'Unauthorized (401)';
      case 403:
        return 'Forbidden (403)';
      case 404:
        return 'Not found (404)';
      case 500:
        return 'Internal server error (500)';
      default:
        return 'Received invalid status code: $statusCode';
    }
  }

  @override
  String toString() => message;
}
