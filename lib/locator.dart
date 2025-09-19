import 'package:api_client/api_client.dart';
import 'package:auth_repo/auth_repo.dart';
import 'package:documents_repo/documents_repo.dart';
import 'package:driver/services/socket_service.dart';
import 'package:get_it/get_it.dart';
import 'package:localstorage/localstorage.dart'; // Correct import for Localstorage
import 'package:shared_preferences/shared_preferences.dart';

final lc = GetIt.instance;

Future<void> initializeDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  lc
    ..registerLazySingleton(() => Localstorage(preferences)) // Updated class name
    ..registerLazySingleton(() => ApiClient(baseUrl: 'https://api.example.com')) // Provide required arguments
    ..registerLazySingleton(SocketService.new)
    ..registerLazySingleton(() => AuthRepo(apiClient: lc<ApiClient>(), localStorage: lc<Localstorage>()))
    ..registerLazySingleton(() => DocumentsRepo(apiClient: lc<ApiClient>(), localStorage: lc<Localstorage>()));
}