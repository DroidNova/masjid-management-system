// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_community_user_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateCommunityUserRequest {

 String get fullName; String get phone; String get role; String get fatherName; int get age; String get gender; String? get email; bool? get isFamilyHead; int? get familyMemberCount; String? get masjidId;
/// Create a copy of CreateCommunityUserRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCommunityUserRequestCopyWith<CreateCommunityUserRequest> get copyWith => _$CreateCommunityUserRequestCopyWithImpl<CreateCommunityUserRequest>(this as CreateCommunityUserRequest, _$identity);

  /// Serializes this CreateCommunityUserRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCommunityUserRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.isFamilyHead, isFamilyHead) || other.isFamilyHead == isFamilyHead)&&(identical(other.familyMemberCount, familyMemberCount) || other.familyMemberCount == familyMemberCount)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phone,role,fatherName,age,gender,email,isFamilyHead,familyMemberCount,masjidId);

@override
String toString() {
  return 'CreateCommunityUserRequest(fullName: $fullName, phone: $phone, role: $role, fatherName: $fatherName, age: $age, gender: $gender, email: $email, isFamilyHead: $isFamilyHead, familyMemberCount: $familyMemberCount, masjidId: $masjidId)';
}


}

/// @nodoc
abstract mixin class $CreateCommunityUserRequestCopyWith<$Res>  {
  factory $CreateCommunityUserRequestCopyWith(CreateCommunityUserRequest value, $Res Function(CreateCommunityUserRequest) _then) = _$CreateCommunityUserRequestCopyWithImpl;
@useResult
$Res call({
 String fullName, String phone, String role, String fatherName, int age, String gender, String? email, bool? isFamilyHead, int? familyMemberCount, String? masjidId
});




}
/// @nodoc
class _$CreateCommunityUserRequestCopyWithImpl<$Res>
    implements $CreateCommunityUserRequestCopyWith<$Res> {
  _$CreateCommunityUserRequestCopyWithImpl(this._self, this._then);

  final CreateCommunityUserRequest _self;
  final $Res Function(CreateCommunityUserRequest) _then;

/// Create a copy of CreateCommunityUserRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? phone = null,Object? role = null,Object? fatherName = null,Object? age = null,Object? gender = null,Object? email = freezed,Object? isFamilyHead = freezed,Object? familyMemberCount = freezed,Object? masjidId = freezed,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,fatherName: null == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,isFamilyHead: freezed == isFamilyHead ? _self.isFamilyHead : isFamilyHead // ignore: cast_nullable_to_non_nullable
as bool?,familyMemberCount: freezed == familyMemberCount ? _self.familyMemberCount : familyMemberCount // ignore: cast_nullable_to_non_nullable
as int?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCommunityUserRequest].
extension CreateCommunityUserRequestPatterns on CreateCommunityUserRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCommunityUserRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCommunityUserRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCommunityUserRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateCommunityUserRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCommunityUserRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCommunityUserRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullName,  String phone,  String role,  String fatherName,  int age,  String gender,  String? email,  bool? isFamilyHead,  int? familyMemberCount,  String? masjidId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCommunityUserRequest() when $default != null:
return $default(_that.fullName,_that.phone,_that.role,_that.fatherName,_that.age,_that.gender,_that.email,_that.isFamilyHead,_that.familyMemberCount,_that.masjidId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullName,  String phone,  String role,  String fatherName,  int age,  String gender,  String? email,  bool? isFamilyHead,  int? familyMemberCount,  String? masjidId)  $default,) {final _that = this;
switch (_that) {
case _CreateCommunityUserRequest():
return $default(_that.fullName,_that.phone,_that.role,_that.fatherName,_that.age,_that.gender,_that.email,_that.isFamilyHead,_that.familyMemberCount,_that.masjidId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullName,  String phone,  String role,  String fatherName,  int age,  String gender,  String? email,  bool? isFamilyHead,  int? familyMemberCount,  String? masjidId)?  $default,) {final _that = this;
switch (_that) {
case _CreateCommunityUserRequest() when $default != null:
return $default(_that.fullName,_that.phone,_that.role,_that.fatherName,_that.age,_that.gender,_that.email,_that.isFamilyHead,_that.familyMemberCount,_that.masjidId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _CreateCommunityUserRequest implements CreateCommunityUserRequest {
  const _CreateCommunityUserRequest({required this.fullName, required this.phone, required this.role, required this.fatherName, required this.age, required this.gender, this.email, this.isFamilyHead, this.familyMemberCount, this.masjidId});
  factory _CreateCommunityUserRequest.fromJson(Map<String, dynamic> json) => _$CreateCommunityUserRequestFromJson(json);

@override final  String fullName;
@override final  String phone;
@override final  String role;
@override final  String fatherName;
@override final  int age;
@override final  String gender;
@override final  String? email;
@override final  bool? isFamilyHead;
@override final  int? familyMemberCount;
@override final  String? masjidId;

/// Create a copy of CreateCommunityUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCommunityUserRequestCopyWith<_CreateCommunityUserRequest> get copyWith => __$CreateCommunityUserRequestCopyWithImpl<_CreateCommunityUserRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCommunityUserRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCommunityUserRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.isFamilyHead, isFamilyHead) || other.isFamilyHead == isFamilyHead)&&(identical(other.familyMemberCount, familyMemberCount) || other.familyMemberCount == familyMemberCount)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phone,role,fatherName,age,gender,email,isFamilyHead,familyMemberCount,masjidId);

@override
String toString() {
  return 'CreateCommunityUserRequest(fullName: $fullName, phone: $phone, role: $role, fatherName: $fatherName, age: $age, gender: $gender, email: $email, isFamilyHead: $isFamilyHead, familyMemberCount: $familyMemberCount, masjidId: $masjidId)';
}


}

/// @nodoc
abstract mixin class _$CreateCommunityUserRequestCopyWith<$Res> implements $CreateCommunityUserRequestCopyWith<$Res> {
  factory _$CreateCommunityUserRequestCopyWith(_CreateCommunityUserRequest value, $Res Function(_CreateCommunityUserRequest) _then) = __$CreateCommunityUserRequestCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String phone, String role, String fatherName, int age, String gender, String? email, bool? isFamilyHead, int? familyMemberCount, String? masjidId
});




}
/// @nodoc
class __$CreateCommunityUserRequestCopyWithImpl<$Res>
    implements _$CreateCommunityUserRequestCopyWith<$Res> {
  __$CreateCommunityUserRequestCopyWithImpl(this._self, this._then);

  final _CreateCommunityUserRequest _self;
  final $Res Function(_CreateCommunityUserRequest) _then;

/// Create a copy of CreateCommunityUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? phone = null,Object? role = null,Object? fatherName = null,Object? age = null,Object? gender = null,Object? email = freezed,Object? isFamilyHead = freezed,Object? familyMemberCount = freezed,Object? masjidId = freezed,}) {
  return _then(_CreateCommunityUserRequest(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,fatherName: null == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,isFamilyHead: freezed == isFamilyHead ? _self.isFamilyHead : isFamilyHead // ignore: cast_nullable_to_non_nullable
as bool?,familyMemberCount: freezed == familyMemberCount ? _self.familyMemberCount : familyMemberCount // ignore: cast_nullable_to_non_nullable
as int?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
