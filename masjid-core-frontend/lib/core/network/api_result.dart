import 'package:platform_core_frontend/core/network/api_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.exception);

  final ApiException exception;
}

extension ApiResultX<T> on ApiResult<T> {
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(ApiException exception) onFailure,
  }) {
    return switch (this) {
      ApiSuccess<T>(:final data) => onSuccess(data),
      ApiFailure<T>(:final exception) => onFailure(exception),
    };
  }

  ApiResult<R> mapData<R>(R Function(T data) mapper) {
    return switch (this) {
      ApiSuccess<T>(:final data) => ApiSuccess<R>(mapper(data)),
      ApiFailure<T>(:final exception) => ApiFailure<R>(exception),
    };
  }
}
