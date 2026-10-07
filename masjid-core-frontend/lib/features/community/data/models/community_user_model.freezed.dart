// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommunityUserModel {

 String get id; String get fullName; List<String> get roles; String? get email; String? get phone; String? get status; String? get masjidId; String? get message; String? get temporaryPassword; String? get fatherName; int? get age; String? get gender; bool get isFamilyHead; int? get familyMemberCount; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of CommunityUserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommunityUserModelCopyWith<CommunityUserModel> get copyWith => _$CommunityUserModelCopyWithImpl<CommunityUserModel>(this as CommunityUserModel, _$identity);

  /// Serializes this CommunityUserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommunityUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId)&&(identical(other.message, message) || other.message == message)&&(identical(other.temporaryPassword, temporaryPassword) || other.temporaryPassword == temporaryPassword)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.isFamilyHead, isFamilyHead) || other.isFamilyHead == isFamilyHead)&&(identical(other.familyMemberCount, familyMemberCount) || other.familyMemberCount == familyMemberCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,const DeepCollectionEquality().hash(roles),email,phone,status,masjidId,message,temporaryPassword,fatherName,age,gender,isFamilyHead,familyMemberCount,createdAt,updatedAt);

@override
String toString() {
  return 'CommunityUserModel(id: $id, fullName: $fullName, roles: $roles, email: $email, phone: $phone, status: $status, masjidId: $masjidId, message: $message, temporaryPassword: $temporaryPassword, fatherName: $fatherName, age: $age, gender: $gender, isFamilyHead: $isFamilyHead, familyMemberCount: $familyMemberCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CommunityUserModelCopyWith<$Res>  {
  factory $CommunityUserModelCopyWith(CommunityUserModel value, $Res Function(CommunityUserModel) _then) = _$CommunityUserModelCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, List<String> roles, String? email, String? phone, String? status, String? masjidId, String? message, String? temporaryPassword, String? fatherName, int? age, String? gender, bool isFamilyHead, int? familyMemberCount, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CommunityUserModelCopyWithImpl<$Res>
    implements $CommunityUserModelCopyWith<$Res> {
  _$CommunityUserModelCopyWithImpl(this._self, this._then);

  final CommunityUserModel _self;
  final $Res Function(CommunityUserModel) _then;

/// Create a copy of CommunityUserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? roles = null,Object? email = freezed,Object? phone = freezed,Object? status = freezed,Object? masjidId = freezed,Object? message = freezed,Object? temporaryPassword = freezed,Object? fatherName = freezed,Object? age = freezed,Object? gender = freezed,Object? isFamilyHead = null,Object? familyMemberCount = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,temporaryPassword: freezed == temporaryPassword ? _self.temporaryPassword : temporaryPassword // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,isFamilyHead: null == isFamilyHead ? _self.isFamilyHead : isFamilyHead // ignore: cast_nullable_to_non_nullable
as bool,familyMemberCount: freezed == familyMemberCount ? _self.familyMemberCount : familyMemberCount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommunityUserModel].
extension CommunityUserModelPatterns on CommunityUserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommunityUserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommunityUserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommunityUserModel value)  $default,){
final _that = this;
switch (_that) {
case _CommunityUserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommunityUserModel value)?  $default,){
final _that = this;
switch (_that) {
case _CommunityUserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  List<String> roles,  String? email,  String? phone,  String? status,  String? masjidId,  String? message,  String? temporaryPassword,  String? fatherName,  int? age,  String? gender,  bool isFamilyHead,  int? familyMemberCount,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommunityUserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.roles,_that.email,_that.phone,_that.status,_that.masjidId,_that.message,_that.temporaryPassword,_that.fatherName,_that.age,_that.gender,_that.isFamilyHead,_that.familyMemberCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  List<String> roles,  String? email,  String? phone,  String? status,  String? masjidId,  String? message,  String? temporaryPassword,  String? fatherName,  int? age,  String? gender,  bool isFamilyHead,  int? familyMemberCount,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CommunityUserModel():
return $default(_that.id,_that.fullName,_that.roles,_that.email,_that.phone,_that.status,_that.masjidId,_that.message,_that.temporaryPassword,_that.fatherName,_that.age,_that.gender,_that.isFamilyHead,_that.familyMemberCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  List<String> roles,  String? email,  String? phone,  String? status,  String? masjidId,  String? message,  String? temporaryPassword,  String? fatherName,  int? age,  String? gender,  bool isFamilyHead,  int? familyMemberCount,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CommunityUserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.roles,_that.email,_that.phone,_that.status,_that.masjidId,_that.message,_that.temporaryPassword,_that.fatherName,_that.age,_that.gender,_that.isFamilyHead,_that.familyMemberCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommunityUserModel extends CommunityUserModel {
  const _CommunityUserModel({required this.id, required this.fullName, final  List<String> roles = const <String>[], this.email, this.phone, this.status, this.masjidId, this.message, this.temporaryPassword, this.fatherName, this.age, this.gender, this.isFamilyHead = false, this.familyMemberCount, this.createdAt, this.updatedAt}): _roles = roles,super._();
  factory _CommunityUserModel.fromJson(Map<String, dynamic> json) => _$CommunityUserModelFromJson(json);

@override final  String id;
@override final  String fullName;
 final  List<String> _roles;
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  String? email;
@override final  String? phone;
@override final  String? status;
@override final  String? masjidId;
@override final  String? message;
@override final  String? temporaryPassword;
@override final  String? fatherName;
@override final  int? age;
@override final  String? gender;
@override@JsonKey() final  bool isFamilyHead;
@override final  int? familyMemberCount;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of CommunityUserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommunityUserModelCopyWith<_CommunityUserModel> get copyWith => __$CommunityUserModelCopyWithImpl<_CommunityUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommunityUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommunityUserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId)&&(identical(other.message, message) || other.message == message)&&(identical(other.temporaryPassword, temporaryPassword) || other.temporaryPassword == temporaryPassword)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.isFamilyHead, isFamilyHead) || other.isFamilyHead == isFamilyHead)&&(identical(other.familyMemberCount, familyMemberCount) || other.familyMemberCount == familyMemberCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,const DeepCollectionEquality().hash(_roles),email,phone,status,masjidId,message,temporaryPassword,fatherName,age,gender,isFamilyHead,familyMemberCount,createdAt,updatedAt);

@override
String toString() {
  return 'CommunityUserModel(id: $id, fullName: $fullName, roles: $roles, email: $email, phone: $phone, status: $status, masjidId: $masjidId, message: $message, temporaryPassword: $temporaryPassword, fatherName: $fatherName, age: $age, gender: $gender, isFamilyHead: $isFamilyHead, familyMemberCount: $familyMemberCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CommunityUserModelCopyWith<$Res> implements $CommunityUserModelCopyWith<$Res> {
  factory _$CommunityUserModelCopyWith(_CommunityUserModel value, $Res Function(_CommunityUserModel) _then) = __$CommunityUserModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, List<String> roles, String? email, String? phone, String? status, String? masjidId, String? message, String? temporaryPassword, String? fatherName, int? age, String? gender, bool isFamilyHead, int? familyMemberCount, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CommunityUserModelCopyWithImpl<$Res>
    implements _$CommunityUserModelCopyWith<$Res> {
  __$CommunityUserModelCopyWithImpl(this._self, this._then);

  final _CommunityUserModel _self;
  final $Res Function(_CommunityUserModel) _then;

/// Create a copy of CommunityUserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? roles = null,Object? email = freezed,Object? phone = freezed,Object? status = freezed,Object? masjidId = freezed,Object? message = freezed,Object? temporaryPassword = freezed,Object? fatherName = freezed,Object? age = freezed,Object? gender = freezed,Object? isFamilyHead = null,Object? familyMemberCount = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_CommunityUserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,temporaryPassword: freezed == temporaryPassword ? _self.temporaryPassword : temporaryPassword // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,isFamilyHead: null == isFamilyHead ? _self.isFamilyHead : isFamilyHead // ignore: cast_nullable_to_non_nullable
as bool,familyMemberCount: freezed == familyMemberCount ? _self.familyMemberCount : familyMemberCount // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
