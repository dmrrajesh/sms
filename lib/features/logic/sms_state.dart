
import 'package:equatable/equatable.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

abstract class SmsState extends Equatable {
  @override
  List<Object> get props => [];
}

class SmsInitialState extends SmsState {}

class SmsLoadingState extends SmsState {}

class PermissionDeniedState extends SmsState {}

class SmsLoadedState extends SmsState {
  final List<SmsMessage> messages;

  SmsLoadedState(this.messages);

  @override
  List<Object> get props => [messages];

  SmsLoadedState copyWith({List<SmsMessage>? messages}) {
    return SmsLoadedState(messages ?? this.messages);
  }
}

class SmsErrorState extends SmsState {
  final String errorMessage;

  SmsErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
