import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  factory SocketService() => _instance;

  SocketService._internal() {
    initSocket();
  }
  static final SocketService _instance = SocketService._internal();

  late IO.Socket _socket;

  Future<void> initSocket() async {
    _socket = IO.io(
      'http://localhost:3002/',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          // .setExtraHeaders({'Authorisation': 'Bearer $token'})
          .build(),
    );

    _socket
      ..connect()
      ..onConnect(
        (_) {
          print('Socket Connected: ${_socket.id}');
        },
      )
      ..onDisconnect(
        (_) {
          print('Socket Disconnected');
        },
      );
  }

  void connect() {
    _socket = IO.io(
      'http://192.168.0.113:3002/',
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter Web use 'websocket'
          .disableAutoConnect()
          // .setExtraHeaders({'Authorisation': 'Bearer $token'})
          .build(),
    );

    _socket
      ..connect()
      ..onConnect(
        (_) {
          print('Socket Connected: ${_socket.id}');
        },
      )
      ..onDisconnect(
        (_) {
          print('Socket Disconnected');
        },
      );
  }

  void emit(String event, dynamic data) {
    print('=================================================$data');
    _socket.emit(event, data);
  }

  // Send data to the server
  void updateDriverLocation(Map<String, dynamic> driverData) {
    _socket.emit('update_driver_location', driverData);
    print('Sent driver location: $driverData');
  }

  // Close the socket connection
  void disconnect() {
    _socket.disconnect();
  }

  IO.Socket get socket => _socket;

  void listenToVehicleVerification(String vehicleId) {
    // Implement logic to listen for vehicle verification updates
    print('Listening for vehicle verification updates for vehicle ID: $vehicleId');
    // Example: Use WebSocket or other socket connection to listen for updates
  }

  void listenToProfileUpdates(String driverId) {
    // Implement logic to listen for profile updates
    print('Listening for profile updates for driver ID: $driverId');
    // Example: Use WebSocket or other socket connection to listen for updates
  }

  void listenToDocumentVerification(String driverId) {
    // Implement logic to listen for document verification updates
    print('Listening for document verification updates for driver ID: $driverId');
    // Example: Use WebSocket or other socket connection to listen for updates
  }
}
