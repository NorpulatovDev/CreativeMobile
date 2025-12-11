import 'package:injectable/injectable.dart';
import '../storage/token_storage.dart';
import 'app_router.dart';

@module
abstract class RouterModule {
  @lazySingleton
  AppRouter appRouter(TokenStorage tokenStorage) => AppRouter(tokenStorage);
}