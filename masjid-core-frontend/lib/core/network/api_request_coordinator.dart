class ApiRequestCoordinator {
  ApiRequestCoordinator._();

  static final ApiRequestCoordinator instance = ApiRequestCoordinator._();

  final Map<String, Future<dynamic>> _inFlightRequests = <String, Future<dynamic>>{};

  Future<T> run<T>({
    required String key,
    required Future<T> Function() request,
  }) {
    final existing = _inFlightRequests[key];
    if (existing != null) {
      return existing as Future<T>;
    }

    final future = request();
    _inFlightRequests[key] = future;

    return future.whenComplete(() {
      _inFlightRequests.remove(key);
    });
  }
}
