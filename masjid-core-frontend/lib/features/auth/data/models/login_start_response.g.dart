// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_start_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginStartResponse _$LoginStartResponseFromJson(Map<String, dynamic> json) =>
    _LoginStartResponse(
      nextStep: json['nextStep'] as String,
      phone: json['phone'] as String,
      challengeId: json['challengeId'] as String?,
      otpLength:
          (json['otpLength'] as num?)?.toInt() ??
          LoginStartResponse.defaultOtpLength,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$LoginStartResponseToJson(_LoginStartResponse instance) =>
    <String, dynamic>{
      'nextStep': instance.nextStep,
      'phone': instance.phone,
      'challengeId': instance.challengeId,
      'otpLength': instance.otpLength,
      'message': instance.message,
    };
