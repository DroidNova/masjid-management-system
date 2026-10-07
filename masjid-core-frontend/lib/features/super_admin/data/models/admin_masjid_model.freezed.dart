// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_masjid_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminMasjidModel {

 String get id; String get name; String get status; String? get country; String? get state; String? get district; String? get locality; String? get address; String? get contactNo; String? get description; String? get welcomeMsg; String? get rejectionReason; String? get requestedByName; String? get requestedByPhone; String? get requestedByEmail; String? get imamUserId; String? get imamName; int get usersCount; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of AdminMasjidModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminMasjidModelCopyWith<AdminMasjidModel> get copyWith => _$AdminMasjidModelCopyWithImpl<AdminMasjidModel>(this as AdminMasjidModel, _$identity);

  /// Serializes this AdminMasjidModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminMasjidModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.district, district) || other.district == district)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.address, address) || other.address == address)&&(identical(other.contactNo, contactNo) || other.contactNo == contactNo)&&(identical(other.description, description) || other.description == description)&&(identical(other.welcomeMsg, welcomeMsg) || other.welcomeMsg == welcomeMsg)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.requestedByName, requestedByName) || other.requestedByName == requestedByName)&&(identical(other.requestedByPhone, requestedByPhone) || other.requestedByPhone == requestedByPhone)&&(identical(other.requestedByEmail, requestedByEmail) || other.requestedByEmail == requestedByEmail)&&(identical(other.imamUserId, imamUserId) || other.imamUserId == imamUserId)&&(identical(other.imamName, imamName) || other.imamName == imamName)&&(identical(other.usersCount, usersCount) || other.usersCount == usersCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,status,country,state,district,locality,address,contactNo,description,welcomeMsg,rejectionReason,requestedByName,requestedByPhone,requestedByEmail,imamUserId,imamName,usersCount,createdAt,updatedAt]);

@override
String toString() {
  return 'AdminMasjidModel(id: $id, name: $name, status: $status, country: $country, state: $state, district: $district, locality: $locality, address: $address, contactNo: $contactNo, description: $description, welcomeMsg: $welcomeMsg, rejectionReason: $rejectionReason, requestedByName: $requestedByName, requestedByPhone: $requestedByPhone, requestedByEmail: $requestedByEmail, imamUserId: $imamUserId, imamName: $imamName, usersCount: $usersCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AdminMasjidModelCopyWith<$Res>  {
  factory $AdminMasjidModelCopyWith(AdminMasjidModel value, $Res Function(AdminMasjidModel) _then) = _$AdminMasjidModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String status, String? country, String? state, String? district, String? locality, String? address, String? contactNo, String? description, String? welcomeMsg, String? rejectionReason, String? requestedByName, String? requestedByPhone, String? requestedByEmail, String? imamUserId, String? imamName, int usersCount, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AdminMasjidModelCopyWithImpl<$Res>
    implements $AdminMasjidModelCopyWith<$Res> {
  _$AdminMasjidModelCopyWithImpl(this._self, this._then);

  final AdminMasjidModel _self;
  final $Res Function(AdminMasjidModel) _then;

/// Create a copy of AdminMasjidModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? status = null,Object? country = freezed,Object? state = freezed,Object? district = freezed,Object? locality = freezed,Object? address = freezed,Object? contactNo = freezed,Object? description = freezed,Object? welcomeMsg = freezed,Object? rejectionReason = freezed,Object? requestedByName = freezed,Object? requestedByPhone = freezed,Object? requestedByEmail = freezed,Object? imamUserId = freezed,Object? imamName = freezed,Object? usersCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,locality: freezed == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,contactNo: freezed == contactNo ? _self.contactNo : contactNo // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,welcomeMsg: freezed == welcomeMsg ? _self.welcomeMsg : welcomeMsg // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,requestedByName: freezed == requestedByName ? _self.requestedByName : requestedByName // ignore: cast_nullable_to_non_nullable
as String?,requestedByPhone: freezed == requestedByPhone ? _self.requestedByPhone : requestedByPhone // ignore: cast_nullable_to_non_nullable
as String?,requestedByEmail: freezed == requestedByEmail ? _self.requestedByEmail : requestedByEmail // ignore: cast_nullable_to_non_nullable
as String?,imamUserId: freezed == imamUserId ? _self.imamUserId : imamUserId // ignore: cast_nullable_to_non_nullable
as String?,imamName: freezed == imamName ? _self.imamName : imamName // ignore: cast_nullable_to_non_nullable
as String?,usersCount: null == usersCount ? _self.usersCount : usersCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminMasjidModel].
extension AdminMasjidModelPatterns on AdminMasjidModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminMasjidModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminMasjidModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminMasjidModel value)  $default,){
final _that = this;
switch (_that) {
case _AdminMasjidModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminMasjidModel value)?  $default,){
final _that = this;
switch (_that) {
case _AdminMasjidModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String status,  String? country,  String? state,  String? district,  String? locality,  String? address,  String? contactNo,  String? description,  String? welcomeMsg,  String? rejectionReason,  String? requestedByName,  String? requestedByPhone,  String? requestedByEmail,  String? imamUserId,  String? imamName,  int usersCount,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminMasjidModel() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.country,_that.state,_that.district,_that.locality,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.rejectionReason,_that.requestedByName,_that.requestedByPhone,_that.requestedByEmail,_that.imamUserId,_that.imamName,_that.usersCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String status,  String? country,  String? state,  String? district,  String? locality,  String? address,  String? contactNo,  String? description,  String? welcomeMsg,  String? rejectionReason,  String? requestedByName,  String? requestedByPhone,  String? requestedByEmail,  String? imamUserId,  String? imamName,  int usersCount,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AdminMasjidModel():
return $default(_that.id,_that.name,_that.status,_that.country,_that.state,_that.district,_that.locality,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.rejectionReason,_that.requestedByName,_that.requestedByPhone,_that.requestedByEmail,_that.imamUserId,_that.imamName,_that.usersCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String status,  String? country,  String? state,  String? district,  String? locality,  String? address,  String? contactNo,  String? description,  String? welcomeMsg,  String? rejectionReason,  String? requestedByName,  String? requestedByPhone,  String? requestedByEmail,  String? imamUserId,  String? imamName,  int usersCount,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminMasjidModel() when $default != null:
return $default(_that.id,_that.name,_that.status,_that.country,_that.state,_that.district,_that.locality,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.rejectionReason,_that.requestedByName,_that.requestedByPhone,_that.requestedByEmail,_that.imamUserId,_that.imamName,_that.usersCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminMasjidModel implements AdminMasjidModel {
  const _AdminMasjidModel({required this.id, required this.name, required this.status, this.country, this.state, this.district, this.locality, this.address, this.contactNo, this.description, this.welcomeMsg, this.rejectionReason, this.requestedByName, this.requestedByPhone, this.requestedByEmail, this.imamUserId, this.imamName, this.usersCount = 0, this.createdAt, this.updatedAt});
  factory _AdminMasjidModel.fromJson(Map<String, dynamic> json) => _$AdminMasjidModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String status;
@override final  String? country;
@override final  String? state;
@override final  String? district;
@override final  String? locality;
@override final  String? address;
@override final  String? contactNo;
@override final  String? description;
@override final  String? welcomeMsg;
@override final  String? rejectionReason;
@override final  String? requestedByName;
@override final  String? requestedByPhone;
@override final  String? requestedByEmail;
@override final  String? imamUserId;
@override final  String? imamName;
@override@JsonKey() final  int usersCount;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of AdminMasjidModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminMasjidModelCopyWith<_AdminMasjidModel> get copyWith => __$AdminMasjidModelCopyWithImpl<_AdminMasjidModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminMasjidModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminMasjidModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.district, district) || other.district == district)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.address, address) || other.address == address)&&(identical(other.contactNo, contactNo) || other.contactNo == contactNo)&&(identical(other.description, description) || other.description == description)&&(identical(other.welcomeMsg, welcomeMsg) || other.welcomeMsg == welcomeMsg)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.requestedByName, requestedByName) || other.requestedByName == requestedByName)&&(identical(other.requestedByPhone, requestedByPhone) || other.requestedByPhone == requestedByPhone)&&(identical(other.requestedByEmail, requestedByEmail) || other.requestedByEmail == requestedByEmail)&&(identical(other.imamUserId, imamUserId) || other.imamUserId == imamUserId)&&(identical(other.imamName, imamName) || other.imamName == imamName)&&(identical(other.usersCount, usersCount) || other.usersCount == usersCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,status,country,state,district,locality,address,contactNo,description,welcomeMsg,rejectionReason,requestedByName,requestedByPhone,requestedByEmail,imamUserId,imamName,usersCount,createdAt,updatedAt]);

@override
String toString() {
  return 'AdminMasjidModel(id: $id, name: $name, status: $status, country: $country, state: $state, district: $district, locality: $locality, address: $address, contactNo: $contactNo, description: $description, welcomeMsg: $welcomeMsg, rejectionReason: $rejectionReason, requestedByName: $requestedByName, requestedByPhone: $requestedByPhone, requestedByEmail: $requestedByEmail, imamUserId: $imamUserId, imamName: $imamName, usersCount: $usersCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AdminMasjidModelCopyWith<$Res> implements $AdminMasjidModelCopyWith<$Res> {
  factory _$AdminMasjidModelCopyWith(_AdminMasjidModel value, $Res Function(_AdminMasjidModel) _then) = __$AdminMasjidModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String status, String? country, String? state, String? district, String? locality, String? address, String? contactNo, String? description, String? welcomeMsg, String? rejectionReason, String? requestedByName, String? requestedByPhone, String? requestedByEmail, String? imamUserId, String? imamName, int usersCount, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AdminMasjidModelCopyWithImpl<$Res>
    implements _$AdminMasjidModelCopyWith<$Res> {
  __$AdminMasjidModelCopyWithImpl(this._self, this._then);

  final _AdminMasjidModel _self;
  final $Res Function(_AdminMasjidModel) _then;

/// Create a copy of AdminMasjidModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? status = null,Object? country = freezed,Object? state = freezed,Object? district = freezed,Object? locality = freezed,Object? address = freezed,Object? contactNo = freezed,Object? description = freezed,Object? welcomeMsg = freezed,Object? rejectionReason = freezed,Object? requestedByName = freezed,Object? requestedByPhone = freezed,Object? requestedByEmail = freezed,Object? imamUserId = freezed,Object? imamName = freezed,Object? usersCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AdminMasjidModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,locality: freezed == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,contactNo: freezed == contactNo ? _self.contactNo : contactNo // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,welcomeMsg: freezed == welcomeMsg ? _self.welcomeMsg : welcomeMsg // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,requestedByName: freezed == requestedByName ? _self.requestedByName : requestedByName // ignore: cast_nullable_to_non_nullable
as String?,requestedByPhone: freezed == requestedByPhone ? _self.requestedByPhone : requestedByPhone // ignore: cast_nullable_to_non_nullable
as String?,requestedByEmail: freezed == requestedByEmail ? _self.requestedByEmail : requestedByEmail // ignore: cast_nullable_to_non_nullable
as String?,imamUserId: freezed == imamUserId ? _self.imamUserId : imamUserId // ignore: cast_nullable_to_non_nullable
as String?,imamName: freezed == imamName ? _self.imamName : imamName // ignore: cast_nullable_to_non_nullable
as String?,usersCount: null == usersCount ? _self.usersCount : usersCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
