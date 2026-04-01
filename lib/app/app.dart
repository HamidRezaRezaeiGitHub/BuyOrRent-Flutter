import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class BuyOrRentApp extends StatelessWidget {
  const BuyOrRentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BuyOrRent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
