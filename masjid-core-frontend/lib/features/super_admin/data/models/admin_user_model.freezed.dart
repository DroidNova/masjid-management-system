// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminUserModel {

 String get id; String get fullName; String get status; String? get email; String? get phone; String? get fatherName; int? get age; String? get gender; String? get masjidId; String? get masjidName; List<String> get roles; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of AdminUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserModelCopyWith<AdminUserModel> get copyWith => _$AdminUserModelCopyWithImpl<AdminUserModel>(this as AdminUserModel, _$identity);

  /// Serializes this AdminUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.status, status) || other.status == status)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId)&&(identical(other.masjidName, masjidName) || other.masjidName == masjidName)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,status,email,phone,fatherName,age,gender,masjidId,masjidName,const DeepCollectionEquality().hash(roles),createdAt,updatedAt);

@override
String toString() {
  return 'AdminUserModel(id: $id, fullName: $fullName, status: $status, email: $email, phone: $phone, fatherName: $fatherName, age: $age, gender: $gender, masjidId: $masjidId, masjidName: $masjidName, roles: $roles, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AdminUserModelCopyWith<$Res>  {
  factory $AdminUserModelCopyWith(AdminUserModel value, $Res Function(AdminUserModel) _then) = _$AdminUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String status, String? email, String? phone, String? fatherName, int? age, String? gender, String? masjidId, String? masjidName, List<String> roles, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AdminUserModelCopyWithImpl<$Res>
    implements $AdminUserModelCopyWith<$Res> {
  _$AdminUserModelCopyWithImpl(this._self, this._then);

  final AdminUserModel _self;
  final $Res Function(AdminUserModel) _then;

/// Create a copy of AdminUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? status = null,Object? email = freezed,Object? phone = freezed,Object? fatherName = freezed,Object? age = freezed,Object? gender = freezed,Object? masjidId = freezed,Object? masjidName = freezed,Object? roles = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,masjidName: freezed == masjidName ? _self.masjidName : masjidName // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminUserModel].
extension AdminUserModelPatterns on AdminUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUserModel value)  $default,){
final _that = this;
switch (_that) {
case _AdminUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String status,  String? email,  String? phone,  String? fatherName,  int? age,  String? gender,  String? masjidId,  String? masjidName,  List<String> roles,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.status,_that.email,_that.phone,_that.fatherName,_that.age,_that.gender,_that.masjidId,_that.masjidName,_that.roles,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String status,  String? email,  String? phone,  String? fatherName,  int? age,  String? gender,  String? masjidId,  String? masjidName,  List<String> roles,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AdminUserModel():
return $default(_that.id,_that.fullName,_that.status,_that.email,_that.phone,_that.fatherName,_that.age,_that.gender,_that.masjidId,_that.masjidName,_that.roles,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String status,  String? email,  String? phone,  String? fatherName,  int? age,  String? gender,  String? masjidId,  String? masjidName,  List<String> roles,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminUserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.status,_that.email,_that.phone,_that.fatherName,_that.age,_that.gender,_that.masjidId,_that.masjidName,_that.roles,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUserModel implements AdminUserModel {
  const _AdminUserModel({required this.id, required this.fullName, required this.status, this.email, this.phone, this.fatherName, this.age, this.gender, this.masjidId, this.masjidName, final  List<String> roles = const <String>[], this.createdAt, this.updatedAt}): _roles = roles;
  factory _AdminUserModel.fromJson(Map<String, dynamic> json) => _$AdminUserModelFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String status;
@override final  String? email;
@override final  String? phone;
@override final  String? fatherName;
@override final  int? age;
@override final  String? gender;
@override final  String? masjidId;
@override final  String? masjidName;
 final  List<String> _roles;
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of AdminUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserModelCopyWith<_AdminUserModel> get copyWith => __$AdminUserModelCopyWithImpl<_AdminUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.status, status) || other.status == status)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId)&&(identical(other.masjidName, masjidName) || other.masjidName == masjidName)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,status,email,phone,fatherName,age,gender,masjidId,masjidName,const DeepCollectionEquality().hash(_roles),createdAt,updatedAt);

@override
String toString() {
  return 'AdminUserModel(id: $id, fullName: $fullName, status: $status, email: $email, phone: $phone, fatherName: $fatherName, age: $age, gender: $gender, masjidId: $masjidId, masjidName: $masjidName, roles: $roles, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AdminUserModelCopyWith<$Res> implements $AdminUserModelCopyWith<$Res> {
  factory _$AdminUserModelCopyWith(_AdminUserModel value, $Res Function(_AdminUserModel) _then) = __$AdminUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String status, String? email, String? phone, String? fatherName, int? age, String? gender, String? masjidId, String? masjidName, List<String> roles, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AdminUserModelCopyWithImpl<$Res>
    implements _$AdminUserModelCopyWith<$Res> {
  __$AdminUserModelCopyWithImpl(this._self, this._then);

  final _AdminUserModel _self;
  final $Res Function(_AdminUserModel) _then;

/// Create a copy of AdminUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? status = null,Object? email = freezed,Object? phone = freezed,Object? fatherName = freezed,Object? age = freezed,Object? gender = freezed,Object? masjidId = freezed,Object? masjidName = freezed,Object? roles = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AdminUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,masjidName: freezed == masjidName ? _self.masjidName : masjidName // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
