import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms/features/logic/sms_bloc.dart';
import 'package:sms/features/logic/sms_event.dart';
import 'package:sms/features/ux/sms_screen.dart';

class AppRouter {
  AppRouter._();

  static void routeHome(BuildContext context, {Function(dynamic)? callback}) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<SmsBloc>(
          create: (context) => SmsBloc()..add(CheckPermissionEvent()),
          child: const SmsScreen(),
        ),
      ),
      (route) => false,
    ).then((value) => callback?.call(value));
  }
}
