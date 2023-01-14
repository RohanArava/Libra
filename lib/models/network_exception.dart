class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = "Something went wrong"});
  @override
  String toString() {
    return message;
  }
}
