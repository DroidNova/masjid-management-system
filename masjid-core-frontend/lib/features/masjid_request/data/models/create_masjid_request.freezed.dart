// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_masjid_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateMasjidRequest {

 String get requesterName; String get requesterPhone; String? get requesterEmail; String get masjidName; String get country; String? get district; String get locality; String get state; String get address; String? get contactNo; String? get description; String? get welcomeMsg; String get imamName; String get imamPhone; String? get imamEmail; String get imamAddress; String get imamFatherName; int get imamAge; String get imamGender; List<CommitteeMemberInput> get committeeMembers;
/// Create a copy of CreateMasjidRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateMasjidRequestCopyWith<CreateMasjidRequest> get copyWith => _$CreateMasjidRequestCopyWithImpl<CreateMasjidRequest>(this as CreateMasjidRequest, _$identity);

  /// Serializes this CreateMasjidRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateMasjidRequest&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requesterPhone, requesterPhone) || other.requesterPhone == requesterPhone)&&(identical(other.requesterEmail, requesterEmail) || other.requesterEmail == requesterEmail)&&(identical(other.masjidName, masjidName) || other.masjidName == masjidName)&&(identical(other.country, country) || other.country == country)&&(identical(other.district, district) || other.district == district)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.state, state) || other.state == state)&&(identical(other.address, address) || other.address == address)&&(identical(other.contactNo, contactNo) || other.contactNo == contactNo)&&(identical(other.description, description) || other.description == description)&&(identical(other.welcomeMsg, welcomeMsg) || other.welcomeMsg == welcomeMsg)&&(identical(other.imamName, imamName) || other.imamName == imamName)&&(identical(other.imamPhone, imamPhone) || other.imamPhone == imamPhone)&&(identical(other.imamEmail, imamEmail) || other.imamEmail == imamEmail)&&(identical(other.imamAddress, imamAddress) || other.imamAddress == imamAddress)&&(identical(other.imamFatherName, imamFatherName) || other.imamFatherName == imamFatherName)&&(identical(other.imamAge, imamAge) || other.imamAge == imamAge)&&(identical(other.imamGender, imamGender) || other.imamGender == imamGender)&&const DeepCollectionEquality().equals(other.committeeMembers, committeeMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,requesterName,requesterPhone,requesterEmail,masjidName,country,district,locality,state,address,contactNo,description,welcomeMsg,imamName,imamPhone,imamEmail,imamAddress,imamFatherName,imamAge,imamGender,const DeepCollectionEquality().hash(committeeMembers)]);

@override
String toString() {
  return 'CreateMasjidRequest(requesterName: $requesterName, requesterPhone: $requesterPhone, requesterEmail: $requesterEmail, masjidName: $masjidName, country: $country, district: $district, locality: $locality, state: $state, address: $address, contactNo: $contactNo, description: $description, welcomeMsg: $welcomeMsg, imamName: $imamName, imamPhone: $imamPhone, imamEmail: $imamEmail, imamAddress: $imamAddress, imamFatherName: $imamFatherName, imamAge: $imamAge, imamGender: $imamGender, committeeMembers: $committeeMembers)';
}


}

/// @nodoc
abstract mixin class $CreateMasjidRequestCopyWith<$Res>  {
  factory $CreateMasjidRequestCopyWith(CreateMasjidRequest value, $Res Function(CreateMasjidRequest) _then) = _$CreateMasjidRequestCopyWithImpl;
@useResult
$Res call({
 String requesterName, String requesterPhone, String? requesterEmail, String masjidName, String country, String? district, String locality, String state, String address, String? contactNo, String? description, String? welcomeMsg, String imamName, String imamPhone, String? imamEmail, String imamAddress, String imamFatherName, int imamAge, String imamGender, List<CommitteeMemberInput> committeeMembers
});




}
/// @nodoc
class _$CreateMasjidRequestCopyWithImpl<$Res>
    implements $CreateMasjidRequestCopyWith<$Res> {
  _$CreateMasjidRequestCopyWithImpl(this._self, this._then);

  final CreateMasjidRequest _self;
  final $Res Function(CreateMasjidRequest) _then;

/// Create a copy of CreateMasjidRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? requesterName = null,Object? requesterPhone = null,Object? requesterEmail = freezed,Object? masjidName = null,Object? country = null,Object? district = freezed,Object? locality = null,Object? state = null,Object? address = null,Object? contactNo = freezed,Object? description = freezed,Object? welcomeMsg = freezed,Object? imamName = null,Object? imamPhone = null,Object? imamEmail = freezed,Object? imamAddress = null,Object? imamFatherName = null,Object? imamAge = null,Object? imamGender = null,Object? committeeMembers = null,}) {
  return _then(_self.copyWith(
requesterName: null == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String,requesterPhone: null == requesterPhone ? _self.requesterPhone : requesterPhone // ignore: cast_nullable_to_non_nullable
as String,requesterEmail: freezed == requesterEmail ? _self.requesterEmail : requesterEmail // ignore: cast_nullable_to_non_nullable
as String?,masjidName: null == masjidName ? _self.masjidName : masjidName // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,contactNo: freezed == contactNo ? _self.contactNo : contactNo // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,welcomeMsg: freezed == welcomeMsg ? _self.welcomeMsg : welcomeMsg // ignore: cast_nullable_to_non_nullable
as String?,imamName: null == imamName ? _self.imamName : imamName // ignore: cast_nullable_to_non_nullable
as String,imamPhone: null == imamPhone ? _self.imamPhone : imamPhone // ignore: cast_nullable_to_non_nullable
as String,imamEmail: freezed == imamEmail ? _self.imamEmail : imamEmail // ignore: cast_nullable_to_non_nullable
as String?,imamAddress: null == imamAddress ? _self.imamAddress : imamAddress // ignore: cast_nullable_to_non_nullable
as String,imamFatherName: null == imamFatherName ? _self.imamFatherName : imamFatherName // ignore: cast_nullable_to_non_nullable
as String,imamAge: null == imamAge ? _self.imamAge : imamAge // ignore: cast_nullable_to_non_nullable
as int,imamGender: null == imamGender ? _self.imamGender : imamGender // ignore: cast_nullable_to_non_nullable
as String,committeeMembers: null == committeeMembers ? _self.committeeMembers : committeeMembers // ignore: cast_nullable_to_non_nullable
as List<CommitteeMemberInput>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateMasjidRequest].
extension CreateMasjidRequestPatterns on CreateMasjidRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateMasjidRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateMasjidRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateMasjidRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateMasjidRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateMasjidRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateMasjidRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String requesterName,  String requesterPhone,  String? requesterEmail,  String masjidName,  String country,  String? district,  String locality,  String state,  String address,  String? contactNo,  String? description,  String? welcomeMsg,  String imamName,  String imamPhone,  String? imamEmail,  String imamAddress,  String imamFatherName,  int imamAge,  String imamGender,  List<CommitteeMemberInput> committeeMembers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateMasjidRequest() when $default != null:
return $default(_that.requesterName,_that.requesterPhone,_that.requesterEmail,_that.masjidName,_that.country,_that.district,_that.locality,_that.state,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.imamName,_that.imamPhone,_that.imamEmail,_that.imamAddress,_that.imamFatherName,_that.imamAge,_that.imamGender,_that.committeeMembers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String requesterName,  String requesterPhone,  String? requesterEmail,  String masjidName,  String country,  String? district,  String locality,  String state,  String address,  String? contactNo,  String? description,  String? welcomeMsg,  String imamName,  String imamPhone,  String? imamEmail,  String imamAddress,  String imamFatherName,  int imamAge,  String imamGender,  List<CommitteeMemberInput> committeeMembers)  $default,) {final _that = this;
switch (_that) {
case _CreateMasjidRequest():
return $default(_that.requesterName,_that.requesterPhone,_that.requesterEmail,_that.masjidName,_that.country,_that.district,_that.locality,_that.state,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.imamName,_that.imamPhone,_that.imamEmail,_that.imamAddress,_that.imamFatherName,_that.imamAge,_that.imamGender,_that.committeeMembers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String requesterName,  String requesterPhone,  String? requesterEmail,  String masjidName,  String country,  String? district,  String locality,  String state,  String address,  String? contactNo,  String? description,  String? welcomeMsg,  String imamName,  String imamPhone,  String? imamEmail,  String imamAddress,  String imamFatherName,  int imamAge,  String imamGender,  List<CommitteeMemberInput> committeeMembers)?  $default,) {final _that = this;
switch (_that) {
case _CreateMasjidRequest() when $default != null:
return $default(_that.requesterName,_that.requesterPhone,_that.requesterEmail,_that.masjidName,_that.country,_that.district,_that.locality,_that.state,_that.address,_that.contactNo,_that.description,_that.welcomeMsg,_that.imamName,_that.imamPhone,_that.imamEmail,_that.imamAddress,_that.imamFatherName,_that.imamAge,_that.imamGender,_that.committeeMembers);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _CreateMasjidRequest implements CreateMasjidRequest {
  const _CreateMasjidRequest({required this.requesterName, required this.requesterPhone, this.requesterEmail, required this.masjidName, required this.country, this.district, required this.locality, required this.state, required this.address, this.contactNo, this.description, this.welcomeMsg, required this.imamName, required this.imamPhone, this.imamEmail, required this.imamAddress, required this.imamFatherName, required this.imamAge, required this.imamGender, required final  List<CommitteeMemberInput> committeeMembers}): _committeeMembers = committeeMembers;
  factory _CreateMasjidRequest.fromJson(Map<String, dynamic> json) => _$CreateMasjidRequestFromJson(json);

@override final  String requesterName;
@override final  String requesterPhone;
@override final  String? requesterEmail;
@override final  String masjidName;
@override final  String country;
@override final  String? district;
@override final  String locality;
@override final  String state;
@override final  String address;
@override final  String? contactNo;
@override final  String? description;
@override final  String? welcomeMsg;
@override final  String imamName;
@override final  String imamPhone;
@override final  String? imamEmail;
@override final  String imamAddress;
@override final  String imamFatherName;
@override final  int imamAge;
@override final  String imamGender;
 final  List<CommitteeMemberInput> _committeeMembers;
@override List<CommitteeMemberInput> get committeeMembers {
  if (_committeeMembers is EqualUnmodifiableListView) return _committeeMembers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_committeeMembers);
}


/// Create a copy of CreateMasjidRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateMasjidRequestCopyWith<_CreateMasjidRequest> get copyWith => __$CreateMasjidRequestCopyWithImpl<_CreateMasjidRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateMasjidRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateMasjidRequest&&(identical(other.requesterName, requesterName) || other.requesterName == requesterName)&&(identical(other.requesterPhone, requesterPhone) || other.requesterPhone == requesterPhone)&&(identical(other.requesterEmail, requesterEmail) || other.requesterEmail == requesterEmail)&&(identical(other.masjidName, masjidName) || other.masjidName == masjidName)&&(identical(other.country, country) || other.country == country)&&(identical(other.district, district) || other.district == district)&&(identical(other.locality, locality) || other.locality == locality)&&(identical(other.state, state) || other.state == state)&&(identical(other.address, address) || other.address == address)&&(identical(other.contactNo, contactNo) || other.contactNo == contactNo)&&(identical(other.description, description) || other.description == description)&&(identical(other.welcomeMsg, welcomeMsg) || other.welcomeMsg == welcomeMsg)&&(identical(other.imamName, imamName) || other.imamName == imamName)&&(identical(other.imamPhone, imamPhone) || other.imamPhone == imamPhone)&&(identical(other.imamEmail, imamEmail) || other.imamEmail == imamEmail)&&(identical(other.imamAddress, imamAddress) || other.imamAddress == imamAddress)&&(identical(other.imamFatherName, imamFatherName) || other.imamFatherName == imamFatherName)&&(identical(other.imamAge, imamAge) || other.imamAge == imamAge)&&(identical(other.imamGender, imamGender) || other.imamGender == imamGender)&&const DeepCollectionEquality().equals(other._committeeMembers, _committeeMembers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,requesterName,requesterPhone,requesterEmail,masjidName,country,district,locality,state,address,contactNo,description,welcomeMsg,imamName,imamPhone,imamEmail,imamAddress,imamFatherName,imamAge,imamGender,const DeepCollectionEquality().hash(_committeeMembers)]);

@override
String toString() {
  return 'CreateMasjidRequest(requesterName: $requesterName, requesterPhone: $requesterPhone, requesterEmail: $requesterEmail, masjidName: $masjidName, country: $country, district: $district, locality: $locality, state: $state, address: $address, contactNo: $contactNo, description: $description, welcomeMsg: $welcomeMsg, imamName: $imamName, imamPhone: $imamPhone, imamEmail: $imamEmail, imamAddress: $imamAddress, imamFatherName: $imamFatherName, imamAge: $imamAge, imamGender: $imamGender, committeeMembers: $committeeMembers)';
}


}

/// @nodoc
abstract mixin class _$CreateMasjidRequestCopyWith<$Res> implements $CreateMasjidRequestCopyWith<$Res> {
  factory _$CreateMasjidRequestCopyWith(_CreateMasjidRequest value, $Res Function(_CreateMasjidRequest) _then) = __$CreateMasjidRequestCopyWithImpl;
@override @useResult
$Res call({
 String requesterName, String requesterPhone, String? requesterEmail, String masjidName, String country, String? district, String locality, String state, String address, String? contactNo, String? description, String? welcomeMsg, String imamName, String imamPhone, String? imamEmail, String imamAddress, String imamFatherName, int imamAge, String imamGender, List<CommitteeMemberInput> committeeMembers
});




}
/// @nodoc
class __$CreateMasjidRequestCopyWithImpl<$Res>
    implements _$CreateMasjidRequestCopyWith<$Res> {
  __$CreateMasjidRequestCopyWithImpl(this._self, this._then);

  final _CreateMasjidRequest _self;
  final $Res Function(_CreateMasjidRequest) _then;

/// Create a copy of CreateMasjidRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? requesterName = null,Object? requesterPhone = null,Object? requesterEmail = freezed,Object? masjidName = null,Object? country = null,Object? district = freezed,Object? locality = null,Object? state = null,Object? address = null,Object? contactNo = freezed,Object? description = freezed,Object? welcomeMsg = freezed,Object? imamName = null,Object? imamPhone = null,Object? imamEmail = freezed,Object? imamAddress = null,Object? imamFatherName = null,Object? imamAge = null,Object? imamGender = null,Object? committeeMembers = null,}) {
  return _then(_CreateMasjidRequest(
requesterName: null == requesterName ? _self.requesterName : requesterName // ignore: cast_nullable_to_non_nullable
as String,requesterPhone: null == requesterPhone ? _self.requesterPhone : requesterPhone // ignore: cast_nullable_to_non_nullable
as String,requesterEmail: freezed == requesterEmail ? _self.requesterEmail : requesterEmail // ignore: cast_nullable_to_non_nullable
as String?,masjidName: null == masjidName ? _self.masjidName : masjidName // ignore: cast_nullable_to_non_nullable
as String,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,district: freezed == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String?,locality: null == locality ? _self.locality : locality // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,contactNo: freezed == contactNo ? _self.contactNo : contactNo // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,welcomeMsg: freezed == welcomeMsg ? _self.welcomeMsg : welcomeMsg // ignore: cast_nullable_to_non_nullable
as String?,imamName: null == imamName ? _self.imamName : imamName // ignore: cast_nullable_to_non_nullable
as String,imamPhone: null == imamPhone ? _self.imamPhone : imamPhone // ignore: cast_nullable_to_non_nullable
as String,imamEmail: freezed == imamEmail ? _self.imamEmail : imamEmail // ignore: cast_nullable_to_non_nullable
as String?,imamAddress: null == imamAddress ? _self.imamAddress : imamAddress // ignore: cast_nullable_to_non_nullable
as String,imamFatherName: null == imamFatherName ? _self.imamFatherName : imamFatherName // ignore: cast_nullable_to_non_nullable
as String,imamAge: null == imamAge ? _self.imamAge : imamAge // ignore: cast_nullable_to_non_nullable
as int,imamGender: null == imamGender ? _self.imamGender : imamGender // ignore: cast_nullable_to_non_nullable
as String,committeeMembers: null == committeeMembers ? _self._committeeMembers : committeeMembers // ignore: cast_nullable_to_non_nullable
as List<CommitteeMemberInput>,
  ));
}


}

// dart format on
