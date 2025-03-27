import 'package:flutter/material.dart';
import 'package:sms/app/constants.dart';
import 'package:sms/app/router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _navigateToHome(context);
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flash_on, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Welcome to ${AppConstants.appName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!context.mounted) return;
      AppRouter.routeHome(context);
    });
  }
}