abstract class DataState<T> {
  const DataState({this.data, this.error});
  final T? data;
  final DataError? error;
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(DataError error) : super(error: error);
}

class DataError {
  const DataError(this.statusCode, this.error);
  final int? statusCode;
  final dynamic error;
  
  String getErrorMessage() {
    return error.toString();
  }
}