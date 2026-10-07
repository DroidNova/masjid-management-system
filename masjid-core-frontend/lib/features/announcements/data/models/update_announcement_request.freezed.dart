// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_announcement_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateAnnouncementRequest {

 String? get title; String? get message; bool? get isActive;
/// Create a copy of UpdateAnnouncementRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateAnnouncementRequestCopyWith<UpdateAnnouncementRequest> get copyWith => _$UpdateAnnouncementRequestCopyWithImpl<UpdateAnnouncementRequest>(this as UpdateAnnouncementRequest, _$identity);

  /// Serializes this UpdateAnnouncementRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateAnnouncementRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,message,isActive);

@override
String toString() {
  return 'UpdateAnnouncementRequest(title: $title, message: $message, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $UpdateAnnouncementRequestCopyWith<$Res>  {
  factory $UpdateAnnouncementRequestCopyWith(UpdateAnnouncementRequest value, $Res Function(UpdateAnnouncementRequest) _then) = _$UpdateAnnouncementRequestCopyWithImpl;
@useResult
$Res call({
 String? title, String? message, bool? isActive
});




}
/// @nodoc
class _$UpdateAnnouncementRequestCopyWithImpl<$Res>
    implements $UpdateAnnouncementRequestCopyWith<$Res> {
  _$UpdateAnnouncementRequestCopyWithImpl(this._self, this._then);

  final UpdateAnnouncementRequest _self;
  final $Res Function(UpdateAnnouncementRequest) _then;

/// Create a copy of UpdateAnnouncementRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? message = freezed,Object? isActive = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateAnnouncementRequest].
extension UpdateAnnouncementRequestPatterns on UpdateAnnouncementRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateAnnouncementRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateAnnouncementRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateAnnouncementRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateAnnouncementRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateAnnouncementRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateAnnouncementRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? message,  bool? isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateAnnouncementRequest() when $default != null:
return $default(_that.title,_that.message,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? message,  bool? isActive)  $default,) {final _that = this;
switch (_that) {
case _UpdateAnnouncementRequest():
return $default(_that.title,_that.message,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? message,  bool? isActive)?  $default,) {final _that = this;
switch (_that) {
case _UpdateAnnouncementRequest() when $default != null:
return $default(_that.title,_that.message,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _UpdateAnnouncementRequest implements UpdateAnnouncementRequest {
  const _UpdateAnnouncementRequest({this.title, this.message, this.isActive});
  factory _UpdateAnnouncementRequest.fromJson(Map<String, dynamic> json) => _$UpdateAnnouncementRequestFromJson(json);

@override final  String? title;
@override final  String? message;
@override final  bool? isActive;

/// Create a copy of UpdateAnnouncementRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateAnnouncementRequestCopyWith<_UpdateAnnouncementRequest> get copyWith => __$UpdateAnnouncementRequestCopyWithImpl<_UpdateAnnouncementRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateAnnouncementRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateAnnouncementRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,message,isActive);

@override
String toString() {
  return 'UpdateAnnouncementRequest(title: $title, message: $message, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$UpdateAnnouncementRequestCopyWith<$Res> implements $UpdateAnnouncementRequestCopyWith<$Res> {
  factory _$UpdateAnnouncementRequestCopyWith(_UpdateAnnouncementRequest value, $Res Function(_UpdateAnnouncementRequest) _then) = __$UpdateAnnouncementRequestCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? message, bool? isActive
});




}
/// @nodoc
class __$UpdateAnnouncementRequestCopyWithImpl<$Res>
    implements _$UpdateAnnouncementRequestCopyWith<$Res> {
  __$UpdateAnnouncementRequestCopyWithImpl(this._self, this._then);

  final _UpdateAnnouncementRequest _self;
  final $Res Function(_UpdateAnnouncementRequest) _then;

/// Create a copy of UpdateAnnouncementRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? message = freezed,Object? isActive = freezed,}) {
  return _then(_UpdateAnnouncementRequest(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
