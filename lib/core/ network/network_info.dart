import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;

  Stream<bool> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _internetConnection;

  NetworkInfoImpl({InternetConnection? internetConnection})
    : _internetConnection = internetConnection ?? InternetConnection();

  @override
  Future<bool> get isConnected {
    return _internetConnection.hasInternetAccess;
  }

  @override
  Stream<bool> get onStatusChange {
    return _internetConnection.onStatusChange
        .map((status) => status == InternetStatus.connected)
        .distinct();
  }
}
