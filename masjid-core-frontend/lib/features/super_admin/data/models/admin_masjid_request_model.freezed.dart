// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_masjid_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommitteeMember {

 String? get name; String? get phone; String? get fatherName; int? get age; String? get gender;
/// Create a copy of CommitteeMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommitteeMemberCopyWith<CommitteeMember> get copyWith => _$CommitteeMemberCopyWithImpl<CommitteeMember>(this as CommitteeMember, _$identity);

  /// Serializes this CommitteeMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommitteeMember&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,phone,fatherName,age,gender);

@override
String toString() {
  return 'CommitteeMember(name: $name, phone: $phone, fatherName: $fatherName, age: $age, gender: $gender)';
}


}

/// @nodoc
abstract mixin class $CommitteeMemberCopyWith<$Res>  {
  factory $CommitteeMemberCopyWith(CommitteeMember value, $Res Function(CommitteeMember) _then) = _$CommitteeMemberCopyWithImpl;
@useResult
$Res call({
 String? name, String? phone, String? fatherName, int? age, String? gender
});




}
/// @nodoc
class _$CommitteeMemberCopyWithImpl<$Res>
    implements $CommitteeMemberCopyWith<$Res> {
  _$CommitteeMemberCopyWithImpl(this._self, this._then);

  final CommitteeMember _self;
  final $Res Function(CommitteeMember) _then;

/// Create a copy of CommitteeMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? phone = freezed,Object? fatherName = freezed,Object? age = freezed,Object? gender = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommitteeMember].
extension CommitteeMemberPatterns on CommitteeMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommitteeMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommitteeMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommitteeMember value)  $default,){
final _that = this;
switch (_that) {
case _CommitteeMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommitteeMember value)?  $default,){
final _that = this;
switch (_that) {
case _CommitteeMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? phone,  String? fatherName,  int? age,  String? gender)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommitteeMember() when $default != null:
return $default(_that.name,_that.phone,_that.fatherName,_that.age,_that.gender);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? phone,  String? fatherName,  int? age,  String? gender)  $default,) {final _that = this;
switch (_that) {
case _CommitteeMember():
return $default(_that.name,_that.phone,_that.fatherName,_that.age,_that.gender);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? phone,  String? fatherName,  int? age,  String? gender)?  $default,) {final _that = this;
switch (_that) {
case _CommitteeMember() when $default != null:
return $default(_that.name,_that.phone,_that.fatherName,_that.age,_that.gender);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommitteeMember implements CommitteeMember {
  const _CommitteeMember({this.name, this.phone, this.fatherName, this.age, this.gender});
  factory _CommitteeMember.fromJson(Map<String, dynamic> json) => _$CommitteeMemberFromJson(json);

@override final  String? name;
@override final  String? phone;
@override final  String? fatherName;
@override final  int? age;
@override final  String? gender;

/// Create a copy of CommitteeMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommitteeMemberCopyWith<_CommitteeMember> get copyWith => __$CommitteeMemberCopyWithImpl<_CommitteeMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommitteeMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommitteeMember&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,phone,fatherName,age,gender);

@override
String toString() {
  return 'CommitteeMember(name: $name, phone: $phone, fatherName: $fatherName, age: $age, gender: $gender)';
}


}

/// @nodoc
abstract mixin class _$CommitteeMemberCopyWith<$Res> implements $CommitteeMemberCopyWith<$Res> {
  factory _$CommitteeMemberCopyWith(_CommitteeMember value, $Res Function(_CommitteeMember) _then) = __$CommitteeMemberCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? phone, String? fatherName, int? age, String? gender
});




}
/// @nodoc
class __$CommitteeMemberCopyWithImpl<$Res>
    implements _$CommitteeMemberCopyWith<$Res> {
  __$CommitteeMemberCopyWithImpl(this._self, this._then);

  final _CommitteeMember _self;
  final $Res Function(_CommitteeMember) _then;

/// Create a copy of CommitteeMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? phone = freezed,Object? fatherName = freezed,Object? age = freezed,Object? gender = freezed,}) {
  return _then(_CommitteeMember(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,fatherName: freezed == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdminMasjidRequestModel {

 String get id; String get masjidName;/// `PENDING`, `APPROVED` or `REJECTED`.
 String get status; String? get requesterName; String? get requesterPhone; String? get requesterEmail; String? get country; String? get state; String? get district; String? get locality; String? get address; String? get contactNo; String? get description; String? get welcomeMsg; String? get imamName; String? get imamEmail; String? get imamPhone; String? get imamAddress; String? get imamFatherName; int? get imamAge; String? get imamGender; List<CommitteeMember> get committeeMembers; String? get rejectionReason; String? get createdMasjidId; DateTime? get reviewedAt; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of AdminMasjidRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminMasjidRequestModelCopyWith<AdminMasjidRequestModel> get copyWith => _$AdminMasjidRequestModelCopyWithImpl<AdminMasjidRequestModel>(this as AdminMasjidRequestModel, _$identity);

  /// Serializes this AdminMasjidRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminMasjidRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.masjidName, masjidName) || other.masjidName == masjidName)&&(identical(other.status, status) || other.status == status)&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requesterPhone, requesterPhone) || other.requesterPhone == requesterPhone)&&(identical(other.requesterEmail, requesterEmail) || other.requesterEmail == requesterEmail)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.district, district) || other.district == district)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.address, address) || other.address == address)&&(identical(other.contactNo, contactNo) || other.contactNo == contactNo)&&(identical(other.description, description) || other.description == description)&&(identical(other.welcomeMsg, welcomeMsg) || other.welcomeMsg == welcomeMsg)&&(identical(other.imamName, imamName) || other.imamName == imamName)&&(identical(other.imamEmail, imamEmail) || other.imamEmail == imamEmail)&&(identical(other.imamPhone, imamPhone) || other.imamPhone == imamPhone)&&(identical(other.imamAddress, imamAddress) || other.imamAddress == imamAddress)&&(identical(other.imamFatherName, imamFatherName) || other.imamFatherName == imamFatherName)&&(identical(other.imamAge, imamAge) || other.imamAge == imamAge)&&(identical(other.imamGender, imamGender) || other.imamGender == imamGender)&&const DeepCollectionEquality().equals(other.committeeMembers, committeeMembers)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdMasjidId, createdMasjidId) || other.createdMasjidId == createdMasjidId)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,masjidName,status,requesterName,requesterPhone,requesterEmail,country,state,district,locality,address,contactNo,description,welcomeMsg,imamName,imamEmail,imamPhone,imamAddress,imamFatherName,imamAge,imamGender,const DeepCollectionEquality().hash(committeeMembers),rejectionReason,createdMasjidId,reviewedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'AdminMasjidRequestModel(id: $id, masjidName: $masjidName, status: $status, requesterName: $requesterName, requesterPhone: $requesterPhone, requesterEmail: $requesterEmail, country: $country, state: $state, district: $district, locality: $locality, address: $address, contactNo: $contactNo, description: $description, welcomeMsg: $welcomeMsg, imamName: $imamName, imamEmail: $imamEmail, imamPhone: $imamPhone, imamAddress: $imamAddress, imamFatherName: $imamFatherName, imamAge: $imamAge, imamGender: $imamGender, committeeMembers: $committeeMembers, rejectionReason: $rejectionReason, createdMasjidId: $createdMasjidId, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AdminMasjidRequestModelCopyWith<$Res>  {
  factory $AdminMasjidRequestModelCopyWith(AdminMasjidRequestModel value, $Res Function(AdminMasjidRequestModel) _then) = _$AdminMasjidRequestModelCopyWithImpl;
@useResult
$Res call({
 String id, String masjidName, String status, String? requesterName, String? requesterPhone, String? requesterEmail, String? country, String? state, String? district, String? locality, String? address, String? contactNo, String? description, String? welcomeMsg, String? imamName, String? imamEmail, String? imamPhone, String? imamAddress, String? imamFatherName, int? imamAge, String? imamGender, List<CommitteeMember> committeeMembers, String? rejectionReason, String? createdMasjidId, DateTime? reviewedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AdminMasjidRequestModelCopyWithImpl<$Res>
    implements $AdminMasjidRequestModelCopyWith<$Res> {
  _$AdminMasjidRequestModelCopyWithImpl(this._self, this._then);

  final AdminMasjidRequestModel _self;
  final $Res Function(AdminMasjidRequestModel) _then;

/// Create a copy of AdminMasjidRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? masjidName = null,Object? status = null,Object? requesterName = freezed,Object? requesterPhone = freezed,Object? requesterEmail = freezed,Object? country = freezed,Object? state = freezed,Object? district = freezed,Object? locality = freezed,Object? address = freezed,Object? contactNo = freezed,Object? description = freezed,Object? welcomeMsg = freezed,Object? imamName = freezed,Object? imamEmail = freezed,Object? imamPhone = freezed,Object? imamAddress = freezed,Object? imamFatherName = freezed,Object? imamAge = freezed,Object? imamGender = freezed,Object? committeeMembers = null,Object? rejectionReason = freezed,Object? createdMasjidId = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,masjidName: null == masjidName ? _self.masjidName : masjidName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requesterName: freezed == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String?,requesterPhone: freezed == requesterPhone ? _self.requesterPhone : requesterPhone // ignore: cast_nullable_to_non_nullable
as String?,requesterEmail: freezed == requesterEmail ? _self.requesterEmail : requesterEmail // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,locality: freezed == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,contactNo: freezed == contactNo ? _self.contactNo : contactNo // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,welcomeMsg: freezed == welcomeMsg ? _self.welcomeMsg : welcomeMsg // ignore: cast_nullable_to_non_nullable
as String?,imamName: freezed == imamName ? _self.imamName : imamName // ignore: cast_nullable_to_non_nullable
as String?,imamEmail: freezed == imamEmail ? _self.imamEmail : imamEmail // ignore: cast_nullable_to_non_nullable
as String?,imamPhone: freezed == imamPhone ? _self.imamPhone : imamPhone // ignore: cast_nullable_to_non_nullable
as String?,imamAddress: freezed == imamAddress ? _self.imamAddress : imamAddress // ignore: cast_nullable_to_non_nullable
as String?,imamFatherName: freezed == imamFatherName ? _self.imamFatherName : imamFatherName // ignore: cast_nullable_to_non_nullable
as String?,imamAge: freezed == imamAge ? _self.imamAge : imamAge // ignore: cast_nullable_to_non_nullable
as int?,imamGender: freezed == imamGender ? _self.imamGender : imamGender // ignore: cast_nullable_to_non_nullable
as String?,committeeMembers: null == committeeMembers ? _self.committeeMembers : committeeMembers // ignore: cast_nullable_to_non_nullable
as List<CommitteeMember>,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdMasjidId: freezed == createdMasjidId ? _self.createdMasjidId : createdMasjidId // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminMasjidRequestModel].
extension AdminMasjidRequestModelPatterns on AdminMasjidRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminMasjidRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminMasjidRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminMasjidRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _AdminMasjidRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminMasjidRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _AdminMasjidRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String masjidName,  String status,  String? requesterName,  String? requesterPhone,  String? requesterEmail,  String? country,  String? state,  String? district,  String? locality,  String? address,  String? contactNo,  String? description,  String? welcomeMsg,  String? imamName,  String? imamEmail,  String? imamPhone,  String? imamAddress,  String? imamFatherName,  int? imamAge,  String? imamGender,  List<CommitteeMember> committeeMembers,  String? rejectionReason,  String? createdMasjidId,  DateTime? reviewedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminMasjidRequestModel() when $default != null:
return $default(_that.id,_that.masjidName,_that.status,_that.requesterName,_that.requesterPhone,_that.requesterEmail,_that.country,_that.state,_that.district,_that.locality,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.imamName,_that.imamEmail,_that.imamPhone,_that.imamAddress,_that.imamFatherName,_that.imamAge,_that.imamGender,_that.committeeMembers,_that.rejectionReason,_that.createdMasjidId,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String masjidName,  String status,  String? requesterName,  String? requesterPhone,  String? requesterEmail,  String? country,  String? state,  String? district,  String? locality,  String? address,  String? contactNo,  String? description,  String? welcomeMsg,  String? imamName,  String? imamEmail,  String? imamPhone,  String? imamAddress,  String? imamFatherName,  int? imamAge,  String? imamGender,  List<CommitteeMember> committeeMembers,  String? rejectionReason,  String? createdMasjidId,  DateTime? reviewedAt,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AdminMasjidRequestModel():
return $default(_that.id,_that.masjidName,_that.status,_that.requesterName,_that.requesterPhone,_that.requesterEmail,_that.country,_that.state,_that.district,_that.locality,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.imamName,_that.imamEmail,_that.imamPhone,_that.imamAddress,_that.imamFatherName,_that.imamAge,_that.imamGender,_that.committeeMembers,_that.rejectionReason,_that.createdMasjidId,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String masjidName,  String status,  String? requesterName,  String? requesterPhone,  String? requesterEmail,  String? country,  String? state,  String? district,  String? locality,  String? address,  String? contactNo,  String? description,  String? welcomeMsg,  String? imamName,  String? imamEmail,  String? imamPhone,  String? imamAddress,  String? imamFatherName,  int? imamAge,  String? imamGender,  List<CommitteeMember> committeeMembers,  String? rejectionReason,  String? createdMasjidId,  DateTime? reviewedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminMasjidRequestModel() when $default != null:
return $default(_that.id,_that.masjidName,_that.status,_that.requesterName,_that.requesterPhone,_that.requesterEmail,_that.country,_that.state,_that.district,_that.locality,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.imamName,_that.imamEmail,_that.imamPhone,_that.imamAddress,_that.imamFatherName,_that.imamAge,_that.imamGender,_that.committeeMembers,_that.rejectionReason,_that.createdMasjidId,_that.reviewedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminMasjidRequestModel extends AdminMasjidRequestModel {
  const _AdminMasjidRequestModel({required this.id, required this.masjidName, required this.status, this.requesterName, this.requesterPhone, this.requesterEmail, this.country, this.state, this.district, this.locality, this.address, this.contactNo, this.description, this.welcomeMsg, this.imamName, this.imamEmail, this.imamPhone, this.imamAddress, this.imamFatherName, this.imamAge, this.imamGender, final  List<CommitteeMember> committeeMembers = const <CommitteeMember>[], this.rejectionReason, this.createdMasjidId, this.reviewedAt, this.createdAt, this.updatedAt}): _committeeMembers = committeeMembers,super._();
  factory _AdminMasjidRequestModel.fromJson(Map<String, dynamic> json) => _$AdminMasjidRequestModelFromJson(json);

@override final  String id;
@override final  String masjidName;
/// `PENDING`, `APPROVED` or `REJECTED`.
@override final  String status;
@override final  String? requesterName;
@override final  String? requesterPhone;
@override final  String? requesterEmail;
@override final  String? country;
@override final  String? state;
@override final  String? district;
@override final  String? locality;
@override final  String? address;
@override final  String? contactNo;
@override final  String? description;
@override final  String? welcomeMsg;
@override final  String? imamName;
@override final  String? imamEmail;
@override final  String? imamPhone;
@override final  String? imamAddress;
@override final  String? imamFatherName;
@override final  int? imamAge;
@override final  String? imamGender;
 final  List<CommitteeMember> _committeeMembers;
@override@JsonKey() List<CommitteeMember> get committeeMembers {
  if (_committeeMembers is EqualUnmodifiableListView) return _committeeMembers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_committeeMembers);
}

@override final  String? rejectionReason;
@override final  String? createdMasjidId;
@override final  DateTime? reviewedAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of AdminMasjidRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminMasjidRequestModelCopyWith<_AdminMasjidRequestModel> get copyWith => __$AdminMasjidRequestModelCopyWithImpl<_AdminMasjidRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminMasjidRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminMasjidRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.masjidName, masjidName) || other.masjidName == masjidName)&&(identical(other.status, status) || other.status == status)&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requesterPhone, requesterPhone) || other.requesterPhone == requesterPhone)&&(identical(other.requesterEmail, requesterEmail) || other.requesterEmail == requesterEmail)&&(identical(other.country, country) || other.country == country)&&(identical(other.state, state) || other.state == state)&&(identical(other.district, district) || other.district == district)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.address, address) || other.address == address)&&(identical(other.contactNo, contactNo) || other.contactNo == contactNo)&&(identical(other.description, description) || other.description == description)&&(identical(other.welcomeMsg, welcomeMsg) || other.welcomeMsg == welcomeMsg)&&(identical(other.imamName, imamName) || other.imamName == imamName)&&(identical(other.imamEmail, imamEmail) || other.imamEmail == imamEmail)&&(identical(other.imamPhone, imamPhone) || other.imamPhone == imamPhone)&&(identical(other.imamAddress, imamAddress) || other.imamAddress == imamAddress)&&(identical(other.imamFatherName, imamFatherName) || other.imamFatherName == imamFatherName)&&(identical(other.imamAge, imamAge) || other.imamAge == imamAge)&&(identical(other.imamGender, imamGender) || other.imamGender == imamGender)&&const DeepCollectionEquality().equals(other._committeeMembers, _committeeMembers)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.createdMasjidId, createdMasjidId) || other.createdMasjidId == createdMasjidId)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,masjidName,status,requesterName,requesterPhone,requesterEmail,country,state,district,locality,address,contactNo,description,welcomeMsg,imamName,imamEmail,imamPhone,imamAddress,imamFatherName,imamAge,imamGender,const DeepCollectionEquality().hash(_committeeMembers),rejectionReason,createdMasjidId,reviewedAt,createdAt,updatedAt]);

@override
String toString() {
  return 'AdminMasjidRequestModel(id: $id, masjidName: $masjidName, status: $status, requesterName: $requesterName, requesterPhone: $requesterPhone, requesterEmail: $requesterEmail, country: $country, state: $state, district: $district, locality: $locality, address: $address, contactNo: $contactNo, description: $description, welcomeMsg: $welcomeMsg, imamName: $imamName, imamEmail: $imamEmail, imamPhone: $imamPhone, imamAddress: $imamAddress, imamFatherName: $imamFatherName, imamAge: $imamAge, imamGender: $imamGender, committeeMembers: $committeeMembers, rejectionReason: $rejectionReason, createdMasjidId: $createdMasjidId, reviewedAt: $reviewedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AdminMasjidRequestModelCopyWith<$Res> implements $AdminMasjidRequestModelCopyWith<$Res> {
  factory _$AdminMasjidRequestModelCopyWith(_AdminMasjidRequestModel value, $Res Function(_AdminMasjidRequestModel) _then) = __$AdminMasjidRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String masjidName, String status, String? requesterName, String? requesterPhone, String? requesterEmail, String? country, String? state, String? district, String? locality, String? address, String? contactNo, String? description, String? welcomeMsg, String? imamName, String? imamEmail, String? imamPhone, String? imamAddress, String? imamFatherName, int? imamAge, String? imamGender, List<CommitteeMember> committeeMembers, String? rejectionReason, String? createdMasjidId, DateTime? reviewedAt, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AdminMasjidRequestModelCopyWithImpl<$Res>
    implements _$AdminMasjidRequestModelCopyWith<$Res> {
  __$AdminMasjidRequestModelCopyWithImpl(this._self, this._then);

  final _AdminMasjidRequestModel _self;
  final $Res Function(_AdminMasjidRequestModel) _then;

/// Create a copy of AdminMasjidRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? masjidName = null,Object? status = null,Object? requesterName = freezed,Object? requesterPhone = freezed,Object? requesterEmail = freezed,Object? country = freezed,Object? state = freezed,Object? district = freezed,Object? locality = freezed,Object? address = freezed,Object? contactNo = freezed,Object? description = freezed,Object? welcomeMsg = freezed,Object? imamName = freezed,Object? imamEmail = freezed,Object? imamPhone = freezed,Object? imamAddress = freezed,Object? imamFatherName = freezed,Object? imamAge = freezed,Object? imamGender = freezed,Object? committeeMembers = null,Object? rejectionReason = freezed,Object? createdMasjidId = freezed,Object? reviewedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AdminMasjidRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,masjidName: null == masjidName ? _self.masjidName : masjidName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,requesterName: freezed == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String?,requesterPhone: freezed == requesterPhone ? _self.requesterPhone : requesterPhone // ignore: cast_nullable_to_non_nullable
as String?,requesterEmail: freezed == requesterEmail ? _self.requesterEmail : requesterEmail // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,locality: freezed == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,contactNo: freezed == contactNo ? _self.contactNo : contactNo // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,welcomeMsg: freezed == welcomeMsg ? _self.welcomeMsg : welcomeMsg // ignore: cast_nullable_to_non_nullable
as String?,imamName: freezed == imamName ? _self.imamName : imamName // ignore: cast_nullable_to_non_nullable
as String?,imamEmail: freezed == imamEmail ? _self.imamEmail : imamEmail // ignore: cast_nullable_to_non_nullable
as String?,imamPhone: freezed == imamPhone ? _self.imamPhone : imamPhone // ignore: cast_nullable_to_non_nullable
as String?,imamAddress: freezed == imamAddress ? _self.imamAddress : imamAddress // ignore: cast_nullable_to_non_nullable
as String?,imamFatherName: freezed == imamFatherName ? _self.imamFatherName : imamFatherName // ignore: cast_nullable_to_non_nullable
as String?,imamAge: freezed == imamAge ? _self.imamAge : imamAge // ignore: cast_nullable_to_non_nullable
as int?,imamGender: freezed == imamGender ? _self.imamGender : imamGender // ignore: cast_nullable_to_non_nullable
as String?,committeeMembers: null == committeeMembers ? _self._committeeMembers : committeeMembers // ignore: cast_nullable_to_non_nullable
as List<CommitteeMember>,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,createdMasjidId: freezed == createdMasjidId ? _self.createdMasjidId : createdMasjidId // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
