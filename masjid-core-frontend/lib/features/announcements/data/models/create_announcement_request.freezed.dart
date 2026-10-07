// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_announcement_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateAnnouncementRequest {

 String get title; String get message; bool get isActive;
/// Create a copy of CreateAnnouncementRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateAnnouncementRequestCopyWith<CreateAnnouncementRequest> get copyWith => _$CreateAnnouncementRequestCopyWithImpl<CreateAnnouncementRequest>(this as CreateAnnouncementRequest, _$identity);

  /// Serializes this CreateAnnouncementRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateAnnouncementRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,message,isActive);

@override
String toString() {
  return 'CreateAnnouncementRequest(title: $title, message: $message, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $CreateAnnouncementRequestCopyWith<$Res>  {
  factory $CreateAnnouncementRequestCopyWith(CreateAnnouncementRequest value, $Res Function(CreateAnnouncementRequest) _then) = _$CreateAnnouncementRequestCopyWithImpl;
@useResult
$Res call({
 String title, String message, bool isActive
});




}
/// @nodoc
class _$CreateAnnouncementRequestCopyWithImpl<$Res>
    implements $CreateAnnouncementRequestCopyWith<$Res> {
  _$CreateAnnouncementRequestCopyWithImpl(this._self, this._then);

  final CreateAnnouncementRequest _self;
  final $Res Function(CreateAnnouncementRequest) _then;

/// Create a copy of CreateAnnouncementRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? message = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateAnnouncementRequest].
extension CreateAnnouncementRequestPatterns on CreateAnnouncementRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateAnnouncementRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateAnnouncementRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateAnnouncementRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateAnnouncementRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateAnnouncementRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateAnnouncementRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String message,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateAnnouncementRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String message,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _CreateAnnouncementRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String message,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _CreateAnnouncementRequest() when $default != null:
return $default(_that.title,_that.message,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateAnnouncementRequest implements CreateAnnouncementRequest {
  const _CreateAnnouncementRequest({required this.title, required this.message, this.isActive = true});
  factory _CreateAnnouncementRequest.fromJson(Map<String, dynamic> json) => _$CreateAnnouncementRequestFromJson(json);

@override final  String title;
@override final  String message;
@override@JsonKey() final  bool isActive;

/// Create a copy of CreateAnnouncementRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateAnnouncementRequestCopyWith<_CreateAnnouncementRequest> get copyWith => __$CreateAnnouncementRequestCopyWithImpl<_CreateAnnouncementRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateAnnouncementRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateAnnouncementRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,message,isActive);

@override
String toString() {
  return 'CreateAnnouncementRequest(title: $title, message: $message, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$CreateAnnouncementRequestCopyWith<$Res> implements $CreateAnnouncementRequestCopyWith<$Res> {
  factory _$CreateAnnouncementRequestCopyWith(_CreateAnnouncementRequest value, $Res Function(_CreateAnnouncementRequest) _then) = __$CreateAnnouncementRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, String message, bool isActive
});




}
/// @nodoc
class __$CreateAnnouncementRequestCopyWithImpl<$Res>
    implements _$CreateAnnouncementRequestCopyWith<$Res> {
  __$CreateAnnouncementRequestCopyWithImpl(this._self, this._then);

  final _CreateAnnouncementRequest _self;
  final $Res Function(_CreateAnnouncementRequest) _then;

/// Create a copy of CreateAnnouncementRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? message = null,Object? isActive = null,}) {
  return _then(_CreateAnnouncementRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
