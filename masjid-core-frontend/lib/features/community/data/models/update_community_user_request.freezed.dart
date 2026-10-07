// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_community_user_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateCommunityUserRequest {

 String get fullName; String get phone; String get fatherName; int get age; String get gender; String? get email; bool? get isFamilyHead; int? get familyMemberCount;
/// Create a copy of UpdateCommunityUserRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCommunityUserRequestCopyWith<UpdateCommunityUserRequest> get copyWith => _$UpdateCommunityUserRequestCopyWithImpl<UpdateCommunityUserRequest>(this as UpdateCommunityUserRequest, _$identity);

  /// Serializes this UpdateCommunityUserRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCommunityUserRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.isFamilyHead, isFamilyHead) || other.isFamilyHead == isFamilyHead)&&(identical(other.familyMemberCount, familyMemberCount) || other.familyMemberCount == familyMemberCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phone,fatherName,age,gender,email,isFamilyHead,familyMemberCount);

@override
String toString() {
  return 'UpdateCommunityUserRequest(fullName: $fullName, phone: $phone, fatherName: $fatherName, age: $age, gender: $gender, email: $email, isFamilyHead: $isFamilyHead, familyMemberCount: $familyMemberCount)';
}


}

/// @nodoc
abstract mixin class $UpdateCommunityUserRequestCopyWith<$Res>  {
  factory $UpdateCommunityUserRequestCopyWith(UpdateCommunityUserRequest value, $Res Function(UpdateCommunityUserRequest) _then) = _$UpdateCommunityUserRequestCopyWithImpl;
@useResult
$Res call({
 String fullName, String phone, String fatherName, int age, String gender, String? email, bool? isFamilyHead, int? familyMemberCount
});




}
/// @nodoc
class _$UpdateCommunityUserRequestCopyWithImpl<$Res>
    implements $UpdateCommunityUserRequestCopyWith<$Res> {
  _$UpdateCommunityUserRequestCopyWithImpl(this._self, this._then);

  final UpdateCommunityUserRequest _self;
  final $Res Function(UpdateCommunityUserRequest) _then;

/// Create a copy of UpdateCommunityUserRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? phone = null,Object? fatherName = null,Object? age = null,Object? gender = null,Object? email = freezed,Object? isFamilyHead = freezed,Object? familyMemberCount = freezed,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,fatherName: null == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,isFamilyHead: freezed == isFamilyHead ? _self.isFamilyHead : isFamilyHead // ignore: cast_nullable_to_non_nullable
as bool?,familyMemberCount: freezed == familyMemberCount ? _self.familyMemberCount : familyMemberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateCommunityUserRequest].
extension UpdateCommunityUserRequestPatterns on UpdateCommunityUserRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateCommunityUserRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateCommunityUserRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateCommunityUserRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateCommunityUserRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateCommunityUserRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateCommunityUserRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fullName,  String phone,  String fatherName,  int age,  String gender,  String? email,  bool? isFamilyHead,  int? familyMemberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateCommunityUserRequest() when $default != null:
return $default(_that.fullName,_that.phone,_that.fatherName,_that.age,_that.gender,_that.email,_that.isFamilyHead,_that.familyMemberCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fullName,  String phone,  String fatherName,  int age,  String gender,  String? email,  bool? isFamilyHead,  int? familyMemberCount)  $default,) {final _that = this;
switch (_that) {
case _UpdateCommunityUserRequest():
return $default(_that.fullName,_that.phone,_that.fatherName,_that.age,_that.gender,_that.email,_that.isFamilyHead,_that.familyMemberCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fullName,  String phone,  String fatherName,  int age,  String gender,  String? email,  bool? isFamilyHead,  int? familyMemberCount)?  $default,) {final _that = this;
switch (_that) {
case _UpdateCommunityUserRequest() when $default != null:
return $default(_that.fullName,_that.phone,_that.fatherName,_that.age,_that.gender,_that.email,_that.isFamilyHead,_that.familyMemberCount);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _UpdateCommunityUserRequest implements UpdateCommunityUserRequest {
  const _UpdateCommunityUserRequest({required this.fullName, required this.phone, required this.fatherName, required this.age, required this.gender, this.email, this.isFamilyHead, this.familyMemberCount});
  factory _UpdateCommunityUserRequest.fromJson(Map<String, dynamic> json) => _$UpdateCommunityUserRequestFromJson(json);

@override final  String fullName;
@override final  String phone;
@override final  String fatherName;
@override final  int age;
@override final  String gender;
@override final  String? email;
@override final  bool? isFamilyHead;
@override final  int? familyMemberCount;

/// Create a copy of UpdateCommunityUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCommunityUserRequestCopyWith<_UpdateCommunityUserRequest> get copyWith => __$UpdateCommunityUserRequestCopyWithImpl<_UpdateCommunityUserRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateCommunityUserRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCommunityUserRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.email, email) || other.email == email)&&(identical(other.isFamilyHead, isFamilyHead) || other.isFamilyHead == isFamilyHead)&&(identical(other.familyMemberCount, familyMemberCount) || other.familyMemberCount == familyMemberCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phone,fatherName,age,gender,email,isFamilyHead,familyMemberCount);

@override
String toString() {
  return 'UpdateCommunityUserRequest(fullName: $fullName, phone: $phone, fatherName: $fatherName, age: $age, gender: $gender, email: $email, isFamilyHead: $isFamilyHead, familyMemberCount: $familyMemberCount)';
}


}

/// @nodoc
abstract mixin class _$UpdateCommunityUserRequestCopyWith<$Res> implements $UpdateCommunityUserRequestCopyWith<$Res> {
  factory _$UpdateCommunityUserRequestCopyWith(_UpdateCommunityUserRequest value, $Res Function(_UpdateCommunityUserRequest) _then) = __$UpdateCommunityUserRequestCopyWithImpl;
@override @useResult
$Res call({
 String fullName, String phone, String fatherName, int age, String gender, String? email, bool? isFamilyHead, int? familyMemberCount
});




}
/// @nodoc
class __$UpdateCommunityUserRequestCopyWithImpl<$Res>
    implements _$UpdateCommunityUserRequestCopyWith<$Res> {
  __$UpdateCommunityUserRequestCopyWithImpl(this._self, this._then);

  final _UpdateCommunityUserRequest _self;
  final $Res Function(_UpdateCommunityUserRequest) _then;

/// Create a copy of UpdateCommunityUserRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? phone = null,Object? fatherName = null,Object? age = null,Object? gender = null,Object? email = freezed,Object? isFamilyHead = freezed,Object? familyMemberCount = freezed,}) {
  return _then(_UpdateCommunityUserRequest(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,fatherName: null == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,isFamilyHead: freezed == isFamilyHead ? _self.isFamilyHead : isFamilyHead // ignore: cast_nullable_to_non_nullable
as bool?,familyMemberCount: freezed == familyMemberCount ? _self.familyMemberCount : familyMemberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
