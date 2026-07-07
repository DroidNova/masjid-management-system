import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:platform_core_frontend/core/config/app_config.dart';
import 'package:platform_core_frontend/core/network/dio_client.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';
import 'package:platform_core_frontend/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:platform_core_frontend/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:platform_core_frontend/features/admin/domain/repositories/admin_repository.dart';
import 'package:platform_core_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:platform_core_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:platform_core_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:platform_core_frontend/features/auth/presentation/controllers/auth_controller.dart';

class AppServices {
  AppServices({
    required this.config,
    required this.tokenStorage,
    required this.dioClient,
    required this.authRepository,
    required this.adminRepository,
    required this.authController,
  });

  final AppConfig config;
  final TokenStorage tokenStorage;
  final DioClient dioClient;
  final AuthRepository authRepository;
  final AdminRepository adminRepository;
  final AuthController authController;
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = await builder();
  runApp(app);
}

AppServices bootstrapServices(AppConfig config) {
  final tokenStorage = TokenStorage();
  final dioClient = DioClient(
    config: config,
    tokenStorage: tokenStorage,
  );
  final authRemoteDataSource = AuthRemoteDataSource(dioClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    tokenStorage: tokenStorage,
  );
  final adminRemoteDataSource = AdminRemoteDataSource(dioClient);
  final adminRepository = AdminRepositoryImpl(adminRemoteDataSource);
  final authController = AuthController(
    authRepository: authRepository,
    tokenStorage: tokenStorage,
  );

  return AppServices(
    config: config,
    tokenStorage: tokenStorage,
    dioClient: dioClient,
    authRepository: authRepository,
    adminRepository: adminRepository,
    authController: authController,
  );
}
