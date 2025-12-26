import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/api/api_client.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surfaceLight,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  await configureDependencies();
  
  // Set up logout callback for token expiration handling
  final authBloc = getIt<AuthBloc>();
  ApiClient.setLogoutCallback(() async {
    authBloc.add(AuthLogout());
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Creative O\'quv Markazi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: getIt<AppRouter>().router,
      ),
    );
  }
}