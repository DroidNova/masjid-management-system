// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_namaz_time_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateNamazTimeRequest {

 String? get fajr; String? get zuhr; String? get asr; String? get maghrib; String? get isha; String? get jumma; String? get note;
/// Create a copy of UpdateNamazTimeRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateNamazTimeRequestCopyWith<UpdateNamazTimeRequest> get copyWith => _$UpdateNamazTimeRequestCopyWithImpl<UpdateNamazTimeRequest>(this as UpdateNamazTimeRequest, _$identity);

  /// Serializes this UpdateNamazTimeRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateNamazTimeRequest&&(identical(other.fajr, fajr) || other.fajr == fajr)&&(identical(other.zuhr, zuhr) || other.zuhr == zuhr)&&(identical(other.asr, asr) || other.asr == asr)&&(identical(other.maghrib, maghrib) || other.maghrib == maghrib)&&(identical(other.isha, isha) || other.isha == isha)&&(identical(other.jumma, jumma) || other.jumma == jumma)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fajr,zuhr,asr,maghrib,isha,jumma,note);

@override
String toString() {
  return 'UpdateNamazTimeRequest(fajr: $fajr, zuhr: $zuhr, asr: $asr, maghrib: $maghrib, isha: $isha, jumma: $jumma, note: $note)';
}


}

/// @nodoc
abstract mixin class $UpdateNamazTimeRequestCopyWith<$Res>  {
  factory $UpdateNamazTimeRequestCopyWith(UpdateNamazTimeRequest value, $Res Function(UpdateNamazTimeRequest) _then) = _$UpdateNamazTimeRequestCopyWithImpl;
@useResult
$Res call({
 String? fajr, String? zuhr, String? asr, String? maghrib, String? isha, String? jumma, String? note
});




}
/// @nodoc
class _$UpdateNamazTimeRequestCopyWithImpl<$Res>
    implements $UpdateNamazTimeRequestCopyWith<$Res> {
  _$UpdateNamazTimeRequestCopyWithImpl(this._self, this._then);

  final UpdateNamazTimeRequest _self;
  final $Res Function(UpdateNamazTimeRequest) _then;

/// Create a copy of UpdateNamazTimeRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fajr = freezed,Object? zuhr = freezed,Object? asr = freezed,Object? maghrib = freezed,Object? isha = freezed,Object? jumma = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
fajr: freezed == fajr ? _self.fajr : fajr // ignore: cast_nullable_to_non_nullable
as String?,zuhr: freezed == zuhr ? _self.zuhr : zuhr // ignore: cast_nullable_to_non_nullable
as String?,asr: freezed == asr ? _self.asr : asr // ignore: cast_nullable_to_non_nullable
as String?,maghrib: freezed == maghrib ? _self.maghrib : maghrib // ignore: cast_nullable_to_non_nullable
as String?,isha: freezed == isha ? _self.isha : isha // ignore: cast_nullable_to_non_nullable
as String?,jumma: freezed == jumma ? _self.jumma : jumma // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateNamazTimeRequest].
extension UpdateNamazTimeRequestPatterns on UpdateNamazTimeRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateNamazTimeRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateNamazTimeRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateNamazTimeRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateNamazTimeRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateNamazTimeRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateNamazTimeRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? fajr,  String? zuhr,  String? asr,  String? maghrib,  String? isha,  String? jumma,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateNamazTimeRequest() when $default != null:
return $default(_that.fajr,_that.zuhr,_that.asr,_that.maghrib,_that.isha,_that.jumma,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? fajr,  String? zuhr,  String? asr,  String? maghrib,  String? isha,  String? jumma,  String? note)  $default,) {final _that = this;
switch (_that) {
case _UpdateNamazTimeRequest():
return $default(_that.fajr,_that.zuhr,_that.asr,_that.maghrib,_that.isha,_that.jumma,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? fajr,  String? zuhr,  String? asr,  String? maghrib,  String? isha,  String? jumma,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _UpdateNamazTimeRequest() when $default != null:
return $default(_that.fajr,_that.zuhr,_that.asr,_that.maghrib,_that.isha,_that.jumma,_that.note);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _UpdateNamazTimeRequest implements UpdateNamazTimeRequest {
  const _UpdateNamazTimeRequest({this.fajr, this.zuhr, this.asr, this.maghrib, this.isha, this.jumma, this.note});
  factory _UpdateNamazTimeRequest.fromJson(Map<String, dynamic> json) => _$UpdateNamazTimeRequestFromJson(json);

@override final  String? fajr;
@override final  String? zuhr;
@override final  String? asr;
@override final  String? maghrib;
@override final  String? isha;
@override final  String? jumma;
@override final  String? note;

/// Create a copy of UpdateNamazTimeRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateNamazTimeRequestCopyWith<_UpdateNamazTimeRequest> get copyWith => __$UpdateNamazTimeRequestCopyWithImpl<_UpdateNamazTimeRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateNamazTimeRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateNamazTimeRequest&&(identical(other.fajr, fajr) || other.fajr == fajr)&&(identical(other.zuhr, zuhr) || other.zuhr == zuhr)&&(identical(other.asr, asr) || other.asr == asr)&&(identical(other.maghrib, maghrib) || other.maghrib == maghrib)&&(identical(other.isha, isha) || other.isha == isha)&&(identical(other.jumma, jumma) || other.jumma == jumma)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fajr,zuhr,asr,maghrib,isha,jumma,note);

@override
String toString() {
  return 'UpdateNamazTimeRequest(fajr: $fajr, zuhr: $zuhr, asr: $asr, maghrib: $maghrib, isha: $isha, jumma: $jumma, note: $note)';
}


}

/// @nodoc
abstract mixin class _$UpdateNamazTimeRequestCopyWith<$Res> implements $UpdateNamazTimeRequestCopyWith<$Res> {
  factory _$UpdateNamazTimeRequestCopyWith(_UpdateNamazTimeRequest value, $Res Function(_UpdateNamazTimeRequest) _then) = __$UpdateNamazTimeRequestCopyWithImpl;
@override @useResult
$Res call({
 String? fajr, String? zuhr, String? asr, String? maghrib, String? isha, String? jumma, String? note
});




}
/// @nodoc
class __$UpdateNamazTimeRequestCopyWithImpl<$Res>
    implements _$UpdateNamazTimeRequestCopyWith<$Res> {
  __$UpdateNamazTimeRequestCopyWithImpl(this._self, this._then);

  final _UpdateNamazTimeRequest _self;
  final $Res Function(_UpdateNamazTimeRequest) _then;

/// Create a copy of UpdateNamazTimeRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fajr = freezed,Object? zuhr = freezed,Object? asr = freezed,Object? maghrib = freezed,Object? isha = freezed,Object? jumma = freezed,Object? note = freezed,}) {
  return _then(_UpdateNamazTimeRequest(
fajr: freezed == fajr ? _self.fajr : fajr // ignore: cast_nullable_to_non_nullable
as String?,zuhr: freezed == zuhr ? _self.zuhr : zuhr // ignore: cast_nullable_to_non_nullable
as String?,asr: freezed == asr ? _self.asr : asr // ignore: cast_nullable_to_non_nullable
as String?,maghrib: freezed == maghrib ? _self.maghrib : maghrib // ignore: cast_nullable_to_non_nullable
as String?,isha: freezed == isha ? _self.isha : isha // ignore: cast_nullable_to_non_nullable
as String?,jumma: freezed == jumma ? _self.jumma : jumma // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
