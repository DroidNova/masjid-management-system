// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_start_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginStartResponse {

/// `OTP_REQUIRED` or `PASSWORD_REQUIRED`.
 String get nextStep; String get phone; String? get challengeId;/// Digits the server expects; falls back to [defaultOtpLength].
 int get otpLength; String? get message;
/// Create a copy of LoginStartResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginStartResponseCopyWith<LoginStartResponse> get copyWith => _$LoginStartResponseCopyWithImpl<LoginStartResponse>(this as LoginStartResponse, _$identity);

  /// Serializes this LoginStartResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginStartResponse&&(identical(other.nextStep, nextStep) || other.nextStep == nextStep)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.otpLength, otpLength) || other.otpLength == otpLength)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nextStep,phone,challengeId,otpLength,message);

@override
String toString() {
  return 'LoginStartResponse(nextStep: $nextStep, phone: $phone, challengeId: $challengeId, otpLength: $otpLength, message: $message)';
}


}

/// @nodoc
abstract mixin class $LoginStartResponseCopyWith<$Res>  {
  factory $LoginStartResponseCopyWith(LoginStartResponse value, $Res Function(LoginStartResponse) _then) = _$LoginStartResponseCopyWithImpl;
@useResult
$Res call({
 String nextStep, String phone, String? challengeId, int otpLength, String? message
});




}
/// @nodoc
class _$LoginStartResponseCopyWithImpl<$Res>
    implements $LoginStartResponseCopyWith<$Res> {
  _$LoginStartResponseCopyWithImpl(this._self, this._then);

  final LoginStartResponse _self;
  final $Res Function(LoginStartResponse) _then;

/// Create a copy of LoginStartResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nextStep = null,Object? phone = null,Object? challengeId = freezed,Object? otpLength = null,Object? message = freezed,}) {
  return _then(_self.copyWith(
nextStep: null == nextStep ? _self.nextStep : nextStep // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,challengeId: freezed == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String?,otpLength: null == otpLength ? _self.otpLength : otpLength // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginStartResponse].
extension LoginStartResponsePatterns on LoginStartResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginStartResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginStartResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginStartResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginStartResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginStartResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginStartResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nextStep,  String phone,  String? challengeId,  int otpLength,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginStartResponse() when $default != null:
return $default(_that.nextStep,_that.phone,_that.challengeId,_that.otpLength,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nextStep,  String phone,  String? challengeId,  int otpLength,  String? message)  $default,) {final _that = this;
switch (_that) {
case _LoginStartResponse():
return $default(_that.nextStep,_that.phone,_that.challengeId,_that.otpLength,_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nextStep,  String phone,  String? challengeId,  int otpLength,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _LoginStartResponse() when $default != null:
return $default(_that.nextStep,_that.phone,_that.challengeId,_that.otpLength,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginStartResponse extends LoginStartResponse {
  const _LoginStartResponse({required this.nextStep, required this.phone, this.challengeId, this.otpLength = LoginStartResponse.defaultOtpLength, this.message}): super._();
  factory _LoginStartResponse.fromJson(Map<String, dynamic> json) => _$LoginStartResponseFromJson(json);

/// `OTP_REQUIRED` or `PASSWORD_REQUIRED`.
@override final  String nextStep;
@override final  String phone;
@override final  String? challengeId;
/// Digits the server expects; falls back to [defaultOtpLength].
@override@JsonKey() final  int otpLength;
@override final  String? message;

/// Create a copy of LoginStartResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginStartResponseCopyWith<_LoginStartResponse> get copyWith => __$LoginStartResponseCopyWithImpl<_LoginStartResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginStartResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginStartResponse&&(identical(other.nextStep, nextStep) || other.nextStep == nextStep)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.challengeId, challengeId) || other.challengeId == challengeId)&&(identical(other.otpLength, otpLength) || other.otpLength == otpLength)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nextStep,phone,challengeId,otpLength,message);

@override
String toString() {
  return 'LoginStartResponse(nextStep: $nextStep, phone: $phone, challengeId: $challengeId, otpLength: $otpLength, message: $message)';
}


}

/// @nodoc
abstract mixin class _$LoginStartResponseCopyWith<$Res> implements $LoginStartResponseCopyWith<$Res> {
  factory _$LoginStartResponseCopyWith(_LoginStartResponse value, $Res Function(_LoginStartResponse) _then) = __$LoginStartResponseCopyWithImpl;
@override @useResult
$Res call({
 String nextStep, String phone, String? challengeId, int otpLength, String? message
});




}
/// @nodoc
class __$LoginStartResponseCopyWithImpl<$Res>
    implements _$LoginStartResponseCopyWith<$Res> {
  __$LoginStartResponseCopyWithImpl(this._self, this._then);

  final _LoginStartResponse _self;
  final $Res Function(_LoginStartResponse) _then;

/// Create a copy of LoginStartResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nextStep = null,Object? phone = null,Object? challengeId = freezed,Object? otpLength = null,Object? message = freezed,}) {
  return _then(_LoginStartResponse(
nextStep: null == nextStep ? _self.nextStep : nextStep // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,challengeId: freezed == challengeId ? _self.challengeId : challengeId // ignore: cast_nullable_to_non_nullable
as String?,otpLength: null == otpLength ? _self.otpLength : otpLength // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
