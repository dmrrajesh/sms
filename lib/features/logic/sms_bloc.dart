import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms/features/logic/sms_event.dart';
import 'package:sms/features/logic/sms_state.dart';

class SmsBloc extends Bloc<SmsEvent, SmsState> {
  final SmsQuery _smsQuery = SmsQuery();
  List<SmsMessage> _messages = [];
  static const EventChannel _eventChannel = EventChannel('com.inbox.sms');
  StreamSubscription? _smsSubscription;

  SmsBloc() : super(SmsInitialState()) {
    on<CheckPermissionEvent>(_checkPermission);
    on<FetchSmsEvent>(_fetchSms);
    on<FilterSmsEvent>(_filterSms);
    on<NewSmsReceivedEvent>(_receivedNewSms);
  }

  bool isPermissionDialogVisible = false;

  Future<void> _checkPermission(
      CheckPermissionEvent event, Emitter<SmsState> emit) async {
    // Prevent showing dialog multiple times
    if (isPermissionDialogVisible) {
      return;
    }

    final status = await Permission.sms.status;

    if (status.isGranted) {
      emit(SmsLoadingState());
      add(FetchSmsEvent());
      _listenForIncomingSms();
      return;
    }

    if (status.isPermanentlyDenied) {
      emit(PermissionDeniedState());
      _closeEventChannel();
      return;
    }

    // Show system dialog only once
    isPermissionDialogVisible = true;
    final result = await Permission.sms.request();
    isPermissionDialogVisible = false;

    if (result.isGranted) {
      emit(SmsLoadingState());
      add(FetchSmsEvent());
      _listenForIncomingSms();
    } else {
      emit(PermissionDeniedState());
      _closeEventChannel();
    }
  }

  Future<void> _fetchSms(FetchSmsEvent event, Emitter<SmsState> emit) async {
    try {
      _messages = await _smsQuery.getAllSms;
      _messages.sort((a, b) {
        // If both dates are null, consider them equal
        if (a.date == null && b.date == null) return 0;

        // If one date is null, place it at the end
        if (a.date == null) return 1;
        if (b.date == null) return -1;

        // Compare non-null dates in descending order
        return b.date!.compareTo(a.date!);
      });
      emit(SmsLoadedState(_messages));
    } catch (e) {
      emit(SmsInitialState());
    }
  }

  void _filterSms(FilterSmsEvent event, Emitter<SmsState> emit) {
    final filteredMessages = event.senderId.isEmpty
        ? _messages
        : _messages
            .where((msg) => msg.address?.contains(event.senderId) ?? false)
            .toList();
    emit(SmsLoadedState(filteredMessages));
  }

  void _receivedNewSms(NewSmsReceivedEvent event, Emitter<SmsState> emit) {
    final currentState = state;
    if (currentState is SmsLoadedState) {
      emit(currentState.copyWith(messages: [
        ...[event.message],
        ...currentState.messages
      ]));
    } else {
      emit(SmsLoadedState([
        ...[event.message],
        ..._messages
      ]));
    }
  }

  void _listenForIncomingSms() {
    _smsSubscription?.cancel(); // Cancel previous subscription if exists
    _smsSubscription = _eventChannel.receiveBroadcastStream().listen((sms) {
      var map = Map.from(sms);
      var newMessage = SmsMessage.fromJson(formatSmsData(map));
      add(NewSmsReceivedEvent(newMessage));
    }, onError: (error) {
      log('Error receiving SMS: $error');
    });
  }

  void _closeEventChannel() {
    _smsSubscription?.cancel();
    _smsSubscription = null;
  }

  Map formatSmsData(Map data) {
    if (data.containsKey('kind')) {
      if (data['kind'] == 'received') {
        data['kind'] = SmsMessageKind.received;
      } else if (data['kind'] == 'sent') {
        data['kind'] = SmsMessageKind.sent;
      } else {
        data['kind'] = SmsMessageKind.draft;
      }
    }
    return data;
  }
}
