// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_masjid_application_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackMasjidApplicationResult {

 String get masjidName; String get status; String? get imamName; DateTime? get requestedAt; DateTime? get reviewedAt;
/// Create a copy of TrackMasjidApplicationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackMasjidApplicationResultCopyWith<TrackMasjidApplicationResult> get copyWith => _$TrackMasjidApplicationResultCopyWithImpl<TrackMasjidApplicationResult>(this as TrackMasjidApplicationResult, _$identity);

  /// Serializes this TrackMasjidApplicationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackMasjidApplicationResult&&(identical(other.masjidName, masjidName) || other.masjidName == masjidName)&&(identical(other.status, status) || other.status == status)&&(identical(other.imamName, imamName) || other.imamName == imamName)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,masjidName,status,imamName,requestedAt,reviewedAt);

@override
String toString() {
  return 'TrackMasjidApplicationResult(masjidName: $masjidName, status: $status, imamName: $imamName, requestedAt: $requestedAt, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class $TrackMasjidApplicationResultCopyWith<$Res>  {
  factory $TrackMasjidApplicationResultCopyWith(TrackMasjidApplicationResult value, $Res Function(TrackMasjidApplicationResult) _then) = _$TrackMasjidApplicationResultCopyWithImpl;
@useResult
$Res call({
 String masjidName, String status, String? imamName, DateTime? requestedAt, DateTime? reviewedAt
});




}
/// @nodoc
class _$TrackMasjidApplicationResultCopyWithImpl<$Res>
    implements $TrackMasjidApplicationResultCopyWith<$Res> {
  _$TrackMasjidApplicationResultCopyWithImpl(this._self, this._then);

  final TrackMasjidApplicationResult _self;
  final $Res Function(TrackMasjidApplicationResult) _then;

/// Create a copy of TrackMasjidApplicationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? masjidName = null,Object? status = null,Object? imamName = freezed,Object? requestedAt = freezed,Object? reviewedAt = freezed,}) {
  return _then(_self.copyWith(
masjidName: null == masjidName ? _self.masjidName : masjidName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,imamName: freezed == imamName ? _self.imamName : imamName // ignore: cast_nullable_to_non_nullable
as String?,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackMasjidApplicationResult].
extension TrackMasjidApplicationResultPatterns on TrackMasjidApplicationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackMasjidApplicationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackMasjidApplicationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackMasjidApplicationResult value)  $default,){
final _that = this;
switch (_that) {
case _TrackMasjidApplicationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackMasjidApplicationResult value)?  $default,){
final _that = this;
switch (_that) {
case _TrackMasjidApplicationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String masjidName,  String status,  String? imamName,  DateTime? requestedAt,  DateTime? reviewedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackMasjidApplicationResult() when $default != null:
return $default(_that.masjidName,_that.status,_that.imamName,_that.requestedAt,_that.reviewedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String masjidName,  String status,  String? imamName,  DateTime? requestedAt,  DateTime? reviewedAt)  $default,) {final _that = this;
switch (_that) {
case _TrackMasjidApplicationResult():
return $default(_that.masjidName,_that.status,_that.imamName,_that.requestedAt,_that.reviewedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String masjidName,  String status,  String? imamName,  DateTime? requestedAt,  DateTime? reviewedAt)?  $default,) {final _that = this;
switch (_that) {
case _TrackMasjidApplicationResult() when $default != null:
return $default(_that.masjidName,_that.status,_that.imamName,_that.requestedAt,_that.reviewedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackMasjidApplicationResult implements TrackMasjidApplicationResult {
  const _TrackMasjidApplicationResult({required this.masjidName, this.status = 'PENDING', this.imamName, this.requestedAt, this.reviewedAt});
  factory _TrackMasjidApplicationResult.fromJson(Map<String, dynamic> json) => _$TrackMasjidApplicationResultFromJson(json);

@override final  String masjidName;
@override@JsonKey() final  String status;
@override final  String? imamName;
@override final  DateTime? requestedAt;
@override final  DateTime? reviewedAt;

/// Create a copy of TrackMasjidApplicationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackMasjidApplicationResultCopyWith<_TrackMasjidApplicationResult> get copyWith => __$TrackMasjidApplicationResultCopyWithImpl<_TrackMasjidApplicationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackMasjidApplicationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackMasjidApplicationResult&&(identical(other.masjidName, masjidName) || other.masjidName == masjidName)&&(identical(other.status, status) || other.status == status)&&(identical(other.imamName, imamName) || other.imamName == imamName)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,masjidName,status,imamName,requestedAt,reviewedAt);

@override
String toString() {
  return 'TrackMasjidApplicationResult(masjidName: $masjidName, status: $status, imamName: $imamName, requestedAt: $requestedAt, reviewedAt: $reviewedAt)';
}


}

/// @nodoc
abstract mixin class _$TrackMasjidApplicationResultCopyWith<$Res> implements $TrackMasjidApplicationResultCopyWith<$Res> {
  factory _$TrackMasjidApplicationResultCopyWith(_TrackMasjidApplicationResult value, $Res Function(_TrackMasjidApplicationResult) _then) = __$TrackMasjidApplicationResultCopyWithImpl;
@override @useResult
$Res call({
 String masjidName, String status, String? imamName, DateTime? requestedAt, DateTime? reviewedAt
});




}
/// @nodoc
class __$TrackMasjidApplicationResultCopyWithImpl<$Res>
    implements _$TrackMasjidApplicationResultCopyWith<$Res> {
  __$TrackMasjidApplicationResultCopyWithImpl(this._self, this._then);

  final _TrackMasjidApplicationResult _self;
  final $Res Function(_TrackMasjidApplicationResult) _then;

/// Create a copy of TrackMasjidApplicationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? masjidName = null,Object? status = null,Object? imamName = freezed,Object? requestedAt = freezed,Object? reviewedAt = freezed,}) {
  return _then(_TrackMasjidApplicationResult(
masjidName: null == masjidName ? _self.masjidName : masjidName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,imamName: freezed == imamName ? _self.imamName : imamName // ignore: cast_nullable_to_non_nullable
as String?,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
