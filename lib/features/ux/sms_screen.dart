import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms/app/constants.dart';
import 'package:sms/features/logic/sms_bloc.dart';
import 'package:sms/features/logic/sms_state.dart';
import 'package:sms/shared/utils/Utils.dart';

import '../logic/sms_event.dart';

class SmsScreen extends StatefulWidget {
  const SmsScreen({super.key});

  @override
  State<SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> with WidgetsBindingObserver {
  final TextEditingController senderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SmsBloc>().add(CheckPermissionEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: Colors.blueAccent,
      ),
      body: BlocBuilder<SmsBloc, SmsState>(
        builder: (context, state) {
          if (state is PermissionDeniedState) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(AppConstants.permissionRequired),
                        content: const Text(AppConstants.smsPermissionIsRequiredToRead),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await openAppSettings();
                            },
                            child: const Text(AppConstants.openSettings),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(AppConstants.cancel),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(AppConstants.permissionDeniedTapToEnable),
              ),
            );
          }
          if (state is SmsLoadedState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: senderController,
                    decoration: const InputDecoration(
                        labelText: AppConstants.enterSenderId,
                        border: OutlineInputBorder()),
                    onChanged: (value) =>
                        context.read<SmsBloc>().add(FilterSmsEvent(value)),
                  ),
                ),
                Expanded(
                  child: state.messages.isEmpty
                      ? const Center(child: Text(AppConstants.noMessages))
                      : ListView.builder(
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final msg = state.messages[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(msg.body ?? AppConstants.noMessage,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400)),
                                    const SizedBox(height: 8),
                                    Text('${AppConstants.from} ${msg.address}',
                                        style: const TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${AppConstants.sentAT} ${formatMessageTime(msg.date)}',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          if (state is SmsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          return Container();
        },
      ),
    );
  }
}
