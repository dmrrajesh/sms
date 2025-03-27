import 'package:equatable/equatable.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

abstract class SmsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckPermissionEvent extends SmsEvent {}

class FetchSmsEvent extends SmsEvent {}

class FilterSmsEvent extends SmsEvent {
  final String senderId;

  FilterSmsEvent(this.senderId);

  @override
  List<Object> get props => [senderId];
}

class NewSmsReceivedEvent extends SmsEvent {
  final SmsMessage message;

  NewSmsReceivedEvent(this.message);

  @override
  List<Object> get props => [message];
}
