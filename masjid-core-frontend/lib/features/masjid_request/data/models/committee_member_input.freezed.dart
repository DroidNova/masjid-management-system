// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'committee_member_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommitteeMemberInput {

 String get name; String get phone; String get fatherName; int get age; String get gender;
/// Create a copy of CommitteeMemberInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommitteeMemberInputCopyWith<CommitteeMemberInput> get copyWith => _$CommitteeMemberInputCopyWithImpl<CommitteeMemberInput>(this as CommitteeMemberInput, _$identity);

  /// Serializes this CommitteeMemberInput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommitteeMemberInput&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,phone,fatherName,age,gender);

@override
String toString() {
  return 'CommitteeMemberInput(name: $name, phone: $phone, fatherName: $fatherName, age: $age, gender: $gender)';
}


}

/// @nodoc
abstract mixin class $CommitteeMemberInputCopyWith<$Res>  {
  factory $CommitteeMemberInputCopyWith(CommitteeMemberInput value, $Res Function(CommitteeMemberInput) _then) = _$CommitteeMemberInputCopyWithImpl;
@useResult
$Res call({
 String name, String phone, String fatherName, int age, String gender
});




}
/// @nodoc
class _$CommitteeMemberInputCopyWithImpl<$Res>
    implements $CommitteeMemberInputCopyWith<$Res> {
  _$CommitteeMemberInputCopyWithImpl(this._self, this._then);

  final CommitteeMemberInput _self;
  final $Res Function(CommitteeMemberInput) _then;

/// Create a copy of CommitteeMemberInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = null,Object? fatherName = null,Object? age = null,Object? gender = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,fatherName: null == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CommitteeMemberInput].
extension CommitteeMemberInputPatterns on CommitteeMemberInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommitteeMemberInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommitteeMemberInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommitteeMemberInput value)  $default,){
final _that = this;
switch (_that) {
case _CommitteeMemberInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommitteeMemberInput value)?  $default,){
final _that = this;
switch (_that) {
case _CommitteeMemberInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String phone,  String fatherName,  int age,  String gender)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommitteeMemberInput() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String phone,  String fatherName,  int age,  String gender)  $default,) {final _that = this;
switch (_that) {
case _CommitteeMemberInput():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String phone,  String fatherName,  int age,  String gender)?  $default,) {final _that = this;
switch (_that) {
case _CommitteeMemberInput() when $default != null:
return $default(_that.name,_that.phone,_that.fatherName,_that.age,_that.gender);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommitteeMemberInput implements CommitteeMemberInput {
  const _CommitteeMemberInput({required this.name, required this.phone, required this.fatherName, required this.age, required this.gender});
  factory _CommitteeMemberInput.fromJson(Map<String, dynamic> json) => _$CommitteeMemberInputFromJson(json);

@override final  String name;
@override final  String phone;
@override final  String fatherName;
@override final  int age;
@override final  String gender;

/// Create a copy of CommitteeMemberInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommitteeMemberInputCopyWith<_CommitteeMemberInput> get copyWith => __$CommitteeMemberInputCopyWithImpl<_CommitteeMemberInput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommitteeMemberInputToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommitteeMemberInput&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.fatherName, fatherName) || other.fatherName == fatherName)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,phone,fatherName,age,gender);

@override
String toString() {
  return 'CommitteeMemberInput(name: $name, phone: $phone, fatherName: $fatherName, age: $age, gender: $gender)';
}


}

/// @nodoc
abstract mixin class _$CommitteeMemberInputCopyWith<$Res> implements $CommitteeMemberInputCopyWith<$Res> {
  factory _$CommitteeMemberInputCopyWith(_CommitteeMemberInput value, $Res Function(_CommitteeMemberInput) _then) = __$CommitteeMemberInputCopyWithImpl;
@override @useResult
$Res call({
 String name, String phone, String fatherName, int age, String gender
});




}
/// @nodoc
class __$CommitteeMemberInputCopyWithImpl<$Res>
    implements _$CommitteeMemberInputCopyWith<$Res> {
  __$CommitteeMemberInputCopyWithImpl(this._self, this._then);

  final _CommitteeMemberInput _self;
  final $Res Function(_CommitteeMemberInput) _then;

/// Create a copy of CommitteeMemberInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = null,Object? fatherName = null,Object? age = null,Object? gender = null,}) {
  return _then(_CommitteeMemberInput(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,fatherName: null == fatherName ? _self.fatherName : fatherName // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
