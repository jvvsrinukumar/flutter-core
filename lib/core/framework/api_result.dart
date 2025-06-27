class ApiResult<T> {
  final T? data; // The data returned by the API on success
  final String? error; // The error message if the API call fails
  final bool isSuccess; // Indicates whether the result is a success or error

  /// Constructor for a successful API result
  ApiResult.success(this.data)
      : error = null,
        isSuccess = true;

  /// Constructor for an error API result
  ApiResult.error(this.error)
      : data = null,
        isSuccess = false;

  /// Helper method to check if the result is an error
  bool get isError => !isSuccess;
}

class Pair<T, U> {
  final T first;
  final U second;

  Pair(this.first, this.second);

  @override
  String toString() => '($first, $second)';
}
