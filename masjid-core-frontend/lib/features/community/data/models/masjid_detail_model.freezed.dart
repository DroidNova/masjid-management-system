// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'masjid_detail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MasjidDetailModel {

 String get id; String get name; String? get country; String? get locality; String? get district; String? get state; String? get address; String? get contactNo; String? get description; String? get welcomeMsg; String? get status; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of MasjidDetailModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MasjidDetailModelCopyWith<MasjidDetailModel> get copyWith => _$MasjidDetailModelCopyWithImpl<MasjidDetailModel>(this as MasjidDetailModel, _$identity);

  /// Serializes this MasjidDetailModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MasjidDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.country, country) || other.country == country)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.district, district) || other.district == district)&&(identical(other.state, state) || other.state == state)&&(identical(other.address, address) || other.address == address)&&(identical(other.contactNo, contactNo) || other.contactNo == contactNo)&&(identical(other.description, description) || other.description == description)&&(identical(other.welcomeMsg, welcomeMsg) || other.welcomeMsg == welcomeMsg)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,country,locality,district,state,address,contactNo,description,welcomeMsg,status,createdAt,updatedAt);

@override
String toString() {
  return 'MasjidDetailModel(id: $id, name: $name, country: $country, locality: $locality, district: $district, state: $state, address: $address, contactNo: $contactNo, description: $description, welcomeMsg: $welcomeMsg, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MasjidDetailModelCopyWith<$Res>  {
  factory $MasjidDetailModelCopyWith(MasjidDetailModel value, $Res Function(MasjidDetailModel) _then) = _$MasjidDetailModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? country, String? locality, String? district, String? state, String? address, String? contactNo, String? description, String? welcomeMsg, String? status, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$MasjidDetailModelCopyWithImpl<$Res>
    implements $MasjidDetailModelCopyWith<$Res> {
  _$MasjidDetailModelCopyWithImpl(this._self, this._then);

  final MasjidDetailModel _self;
  final $Res Function(MasjidDetailModel) _then;

/// Create a copy of MasjidDetailModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? country = freezed,Object? locality = freezed,Object? district = freezed,Object? state = freezed,Object? address = freezed,Object? contactNo = freezed,Object? description = freezed,Object? welcomeMsg = freezed,Object? status = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,locality: freezed == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,contactNo: freezed == contactNo ? _self.contactNo : contactNo // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,welcomeMsg: freezed == welcomeMsg ? _self.welcomeMsg : welcomeMsg // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MasjidDetailModel].
extension MasjidDetailModelPatterns on MasjidDetailModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MasjidDetailModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MasjidDetailModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MasjidDetailModel value)  $default,){
final _that = this;
switch (_that) {
case _MasjidDetailModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MasjidDetailModel value)?  $default,){
final _that = this;
switch (_that) {
case _MasjidDetailModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? country,  String? locality,  String? district,  String? state,  String? address,  String? contactNo,  String? description,  String? welcomeMsg,  String? status,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MasjidDetailModel() when $default != null:
return $default(_that.id,_that.name,_that.country,_that.locality,_that.district,_that.state,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? country,  String? locality,  String? district,  String? state,  String? address,  String? contactNo,  String? description,  String? welcomeMsg,  String? status,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MasjidDetailModel():
return $default(_that.id,_that.name,_that.country,_that.locality,_that.district,_that.state,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? country,  String? locality,  String? district,  String? state,  String? address,  String? contactNo,  String? description,  String? welcomeMsg,  String? status,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MasjidDetailModel() when $default != null:
return $default(_that.id,_that.name,_that.country,_that.locality,_that.district,_that.state,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MasjidDetailModel implements MasjidDetailModel {
  const _MasjidDetailModel({required this.id, required this.name, this.country, this.locality, this.district, this.state, this.address, this.contactNo, this.description, this.welcomeMsg, this.status, this.createdAt, this.updatedAt});
  factory _MasjidDetailModel.fromJson(Map<String, dynamic> json) => _$MasjidDetailModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? country;
@override final  String? locality;
@override final  String? district;
@override final  String? state;
@override final  String? address;
@override final  String? contactNo;
@override final  String? description;
@override final  String? welcomeMsg;
@override final  String? status;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of MasjidDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MasjidDetailModelCopyWith<_MasjidDetailModel> get copyWith => __$MasjidDetailModelCopyWithImpl<_MasjidDetailModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MasjidDetailModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MasjidDetailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.country, country) || other.country == country)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.district, district) || other.district == district)&&(identical(other.state, state) || other.state == state)&&(identical(other.address, address) || other.address == address)&&(identical(other.contactNo, contactNo) || other.contactNo == contactNo)&&(identical(other.description, description) || other.description == description)&&(identical(other.welcomeMsg, welcomeMsg) || other.welcomeMsg == welcomeMsg)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,country,locality,district,state,address,contactNo,description,welcomeMsg,status,createdAt,updatedAt);

@override
String toString() {
  return 'MasjidDetailModel(id: $id, name: $name, country: $country, locality: $locality, district: $district, state: $state, address: $address, contactNo: $contactNo, description: $description, welcomeMsg: $welcomeMsg, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MasjidDetailModelCopyWith<$Res> implements $MasjidDetailModelCopyWith<$Res> {
  factory _$MasjidDetailModelCopyWith(_MasjidDetailModel value, $Res Function(_MasjidDetailModel) _then) = __$MasjidDetailModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? country, String? locality, String? district, String? state, String? address, String? contactNo, String? description, String? welcomeMsg, String? status, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$MasjidDetailModelCopyWithImpl<$Res>
    implements _$MasjidDetailModelCopyWith<$Res> {
  __$MasjidDetailModelCopyWithImpl(this._self, this._then);

  final _MasjidDetailModel _self;
  final $Res Function(_MasjidDetailModel) _then;

/// Create a copy of MasjidDetailModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? country = freezed,Object? locality = freezed,Object? district = freezed,Object? state = freezed,Object? address = freezed,Object? contactNo = freezed,Object? description = freezed,Object? welcomeMsg = freezed,Object? status = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_MasjidDetailModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,locality: freezed == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,contactNo: freezed == contactNo ? _self.contactNo : contactNo // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,welcomeMsg: freezed == welcomeMsg ? _self.welcomeMsg : welcomeMsg // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
