// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

 String get id; String get fullName; List<String> get roles;/// Permission names from `masjid-core/src/access/permissions.ts`.
 List<String> get permissions; String? get email; String? get phone; String? get status; String? get masjidId; bool get isEmailVerified; bool get isPhoneVerified; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&const DeepCollectionEquality().equals(other.roles, roles)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,const DeepCollectionEquality().hash(roles),const DeepCollectionEquality().hash(permissions),email,phone,status,masjidId,isEmailVerified,isPhoneVerified,createdAt,updatedAt);

@override
String toString() {
  return 'AppUser(id: $id, fullName: $fullName, roles: $roles, permissions: $permissions, email: $email, phone: $phone, status: $status, masjidId: $masjidId, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, List<String> roles, List<String> permissions, String? email, String? phone, String? status, String? masjidId, bool isEmailVerified, bool isPhoneVerified, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? roles = null,Object? permissions = null,Object? email = freezed,Object? phone = freezed,Object? status = freezed,Object? masjidId = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  List<String> roles,  List<String> permissions,  String? email,  String? phone,  String? status,  String? masjidId,  bool isEmailVerified,  bool isPhoneVerified,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.fullName,_that.roles,_that.permissions,_that.email,_that.phone,_that.status,_that.masjidId,_that.isEmailVerified,_that.isPhoneVerified,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  List<String> roles,  List<String> permissions,  String? email,  String? phone,  String? status,  String? masjidId,  bool isEmailVerified,  bool isPhoneVerified,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.id,_that.fullName,_that.roles,_that.permissions,_that.email,_that.phone,_that.status,_that.masjidId,_that.isEmailVerified,_that.isPhoneVerified,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  List<String> roles,  List<String> permissions,  String? email,  String? phone,  String? status,  String? masjidId,  bool isEmailVerified,  bool isPhoneVerified,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.id,_that.fullName,_that.roles,_that.permissions,_that.email,_that.phone,_that.status,_that.masjidId,_that.isEmailVerified,_that.isPhoneVerified,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser implements AppUser {
  const _AppUser({required this.id, required this.fullName, final  List<String> roles = const <String>[], final  List<String> permissions = const <String>[], this.email, this.phone, this.status, this.masjidId, this.isEmailVerified = false, this.isPhoneVerified = false, this.createdAt, this.updatedAt}): _roles = roles,_permissions = permissions;
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

@override final  String id;
@override final  String fullName;
 final  List<String> _roles;
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

/// Permission names from `masjid-core/src/access/permissions.ts`.
 final  List<String> _permissions;
/// Permission names from `masjid-core/src/access/permissions.ts`.
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

@override final  String? email;
@override final  String? phone;
@override final  String? status;
@override final  String? masjidId;
@override@JsonKey() final  bool isEmailVerified;
@override@JsonKey() final  bool isPhoneVerified;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&const DeepCollectionEquality().equals(other._roles, _roles)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.status, status) || other.status == status)&&(identical(other.masjidId, masjidId) || other.masjidId == masjidId)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isPhoneVerified, isPhoneVerified) || other.isPhoneVerified == isPhoneVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_permissions),email,phone,status,masjidId,isEmailVerified,isPhoneVerified,createdAt,updatedAt);

@override
String toString() {
  return 'AppUser(id: $id, fullName: $fullName, roles: $roles, permissions: $permissions, email: $email, phone: $phone, status: $status, masjidId: $masjidId, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, List<String> roles, List<String> permissions, String? email, String? phone, String? status, String? masjidId, bool isEmailVerified, bool isPhoneVerified, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? roles = null,Object? permissions = null,Object? email = freezed,Object? phone = freezed,Object? status = freezed,Object? masjidId = freezed,Object? isEmailVerified = null,Object? isPhoneVerified = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AppUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,masjidId: freezed == masjidId ? _self.masjidId : masjidId // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isPhoneVerified: null == isPhoneVerified ? _self.isPhoneVerified : isPhoneVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
