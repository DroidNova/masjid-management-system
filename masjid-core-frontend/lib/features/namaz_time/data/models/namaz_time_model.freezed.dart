// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'namaz_time_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NamazTimeModel {

 String? get id; String? get masjidId; String? get fajr; String? get zuhr; String? get asr; String? get maghrib; String? get isha; String? get jumma; String? get note; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of NamazTimeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NamazTimeModelCopyWith<NamazTimeModel> get copyWith => _$NamazTimeModelCopyWithImpl<NamazTimeModel>(this as NamazTimeModel, _$identity);

  /// Serializes this NamazTimeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NamazTimeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId)&&(identical(other.fajr, fajr) || other.fajr == fajr)&&(identical(other.zuhr, zuhr) || other.zuhr == zuhr)&&(identical(other.asr, asr) || other.asr == asr)&&(identical(other.maghrib, maghrib) || other.maghrib == maghrib)&&(identical(other.isha, isha) || other.isha == isha)&&(identical(other.jumma, jumma) || other.jumma == jumma)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,masjidId,fajr,zuhr,asr,maghrib,isha,jumma,note,createdAt,updatedAt);

@override
String toString() {
  return 'NamazTimeModel(id: $id, masjidId: $masjidId, fajr: $fajr, zuhr: $zuhr, asr: $asr, maghrib: $maghrib, isha: $isha, jumma: $jumma, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NamazTimeModelCopyWith<$Res>  {
  factory $NamazTimeModelCopyWith(NamazTimeModel value, $Res Function(NamazTimeModel) _then) = _$NamazTimeModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? masjidId, String? fajr, String? zuhr, String? asr, String? maghrib, String? isha, String? jumma, String? note, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$NamazTimeModelCopyWithImpl<$Res>
    implements $NamazTimeModelCopyWith<$Res> {
  _$NamazTimeModelCopyWithImpl(this._self, this._then);

  final NamazTimeModel _self;
  final $Res Function(NamazTimeModel) _then;

/// Create a copy of NamazTimeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? masjidId = freezed,Object? fajr = freezed,Object? zuhr = freezed,Object? asr = freezed,Object? maghrib = freezed,Object? isha = freezed,Object? jumma = freezed,Object? note = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,fajr: freezed == fajr ? _self.fajr : fajr // ignore: cast_nullable_to_non_nullable
as String?,zuhr: freezed == zuhr ? _self.zuhr : zuhr // ignore: cast_nullable_to_non_nullable
as String?,asr: freezed == asr ? _self.asr : asr // ignore: cast_nullable_to_non_nullable
as String?,maghrib: freezed == maghrib ? _self.maghrib : maghrib // ignore: cast_nullable_to_non_nullable
as String?,isha: freezed == isha ? _self.isha : isha // ignore: cast_nullable_to_non_nullable
as String?,jumma: freezed == jumma ? _self.jumma : jumma // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NamazTimeModel].
extension NamazTimeModelPatterns on NamazTimeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NamazTimeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NamazTimeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NamazTimeModel value)  $default,){
final _that = this;
switch (_that) {
case _NamazTimeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NamazTimeModel value)?  $default,){
final _that = this;
switch (_that) {
case _NamazTimeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? masjidId,  String? fajr,  String? zuhr,  String? asr,  String? maghrib,  String? isha,  String? jumma,  String? note,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NamazTimeModel() when $default != null:
return $default(_that.id,_that.masjidId,_that.fajr,_that.zuhr,_that.asr,_that.maghrib,_that.isha,_that.jumma,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? masjidId,  String? fajr,  String? zuhr,  String? asr,  String? maghrib,  String? isha,  String? jumma,  String? note,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NamazTimeModel():
return $default(_that.id,_that.masjidId,_that.fajr,_that.zuhr,_that.asr,_that.maghrib,_that.isha,_that.jumma,_that.note,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? masjidId,  String? fajr,  String? zuhr,  String? asr,  String? maghrib,  String? isha,  String? jumma,  String? note,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NamazTimeModel() when $default != null:
return $default(_that.id,_that.masjidId,_that.fajr,_that.zuhr,_that.asr,_that.maghrib,_that.isha,_that.jumma,_that.note,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NamazTimeModel implements NamazTimeModel {
  const _NamazTimeModel({this.id, this.masjidId, this.fajr, this.zuhr, this.asr, this.maghrib, this.isha, this.jumma, this.note, this.createdAt, this.updatedAt});
  factory _NamazTimeModel.fromJson(Map<String, dynamic> json) => _$NamazTimeModelFromJson(json);

@override final  String? id;
@override final  String? masjidId;
@override final  String? fajr;
@override final  String? zuhr;
@override final  String? asr;
@override final  String? maghrib;
@override final  String? isha;
@override final  String? jumma;
@override final  String? note;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of NamazTimeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NamazTimeModelCopyWith<_NamazTimeModel> get copyWith => __$NamazTimeModelCopyWithImpl<_NamazTimeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NamazTimeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NamazTimeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId)&&(identical(other.fajr, fajr) || other.fajr == fajr)&&(identical(other.zuhr, zuhr) || other.zuhr == zuhr)&&(identical(other.asr, asr) || other.asr == asr)&&(identical(other.maghrib, maghrib) || other.maghrib == maghrib)&&(identical(other.isha, isha) || other.isha == isha)&&(identical(other.jumma, jumma) || other.jumma == jumma)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,masjidId,fajr,zuhr,asr,maghrib,isha,jumma,note,createdAt,updatedAt);

@override
String toString() {
  return 'NamazTimeModel(id: $id, masjidId: $masjidId, fajr: $fajr, zuhr: $zuhr, asr: $asr, maghrib: $maghrib, isha: $isha, jumma: $jumma, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NamazTimeModelCopyWith<$Res> implements $NamazTimeModelCopyWith<$Res> {
  factory _$NamazTimeModelCopyWith(_NamazTimeModel value, $Res Function(_NamazTimeModel) _then) = __$NamazTimeModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? masjidId, String? fajr, String? zuhr, String? asr, String? maghrib, String? isha, String? jumma, String? note, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$NamazTimeModelCopyWithImpl<$Res>
    implements _$NamazTimeModelCopyWith<$Res> {
  __$NamazTimeModelCopyWithImpl(this._self, this._then);

  final _NamazTimeModel _self;
  final $Res Function(_NamazTimeModel) _then;

/// Create a copy of NamazTimeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? masjidId = freezed,Object? fajr = freezed,Object? zuhr = freezed,Object? asr = freezed,Object? maghrib = freezed,Object? isha = freezed,Object? jumma = freezed,Object? note = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_NamazTimeModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,fajr: freezed == fajr ? _self.fajr : fajr // ignore: cast_nullable_to_non_nullable
as String?,zuhr: freezed == zuhr ? _self.zuhr : zuhr // ignore: cast_nullable_to_non_nullable
as String?,asr: freezed == asr ? _self.asr : asr // ignore: cast_nullable_to_non_nullable
as String?,maghrib: freezed == maghrib ? _self.maghrib : maghrib // ignore: cast_nullable_to_non_nullable
as String?,isha: freezed == isha ? _self.isha : isha // ignore: cast_nullable_to_non_nullable
as String?,jumma: freezed == jumma ? _self.jumma : jumma // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
