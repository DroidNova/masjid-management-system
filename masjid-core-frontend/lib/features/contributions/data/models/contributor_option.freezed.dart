// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contributor_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContributorOption {

 String get id; String get fullName; String? get phone;
/// Create a copy of ContributorOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributorOptionCopyWith<ContributorOption> get copyWith => _$ContributorOptionCopyWithImpl<ContributorOption>(this as ContributorOption, _$identity);

  /// Serializes this ContributorOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributorOption&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone);

@override
String toString() {
  return 'ContributorOption(id: $id, fullName: $fullName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $ContributorOptionCopyWith<$Res>  {
  factory $ContributorOptionCopyWith(ContributorOption value, $Res Function(ContributorOption) _then) = _$ContributorOptionCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? phone
});




}
/// @nodoc
class _$ContributorOptionCopyWithImpl<$Res>
    implements $ContributorOptionCopyWith<$Res> {
  _$ContributorOptionCopyWithImpl(this._self, this._then);

  final ContributorOption _self;
  final $Res Function(ContributorOption) _then;

/// Create a copy of ContributorOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phone = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributorOption].
extension ContributorOptionPatterns on ContributorOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributorOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributorOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributorOption value)  $default,){
final _that = this;
switch (_that) {
case _ContributorOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributorOption value)?  $default,){
final _that = this;
switch (_that) {
case _ContributorOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributorOption() when $default != null:
return $default(_that.id,_that.fullName,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _ContributorOption():
return $default(_that.id,_that.fullName,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _ContributorOption() when $default != null:
return $default(_that.id,_that.fullName,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributorOption implements ContributorOption {
  const _ContributorOption({required this.id, this.fullName = '', this.phone});
  factory _ContributorOption.fromJson(Map<String, dynamic> json) => _$ContributorOptionFromJson(json);

@override final  String id;
@override@JsonKey() final  String fullName;
@override final  String? phone;

/// Create a copy of ContributorOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributorOptionCopyWith<_ContributorOption> get copyWith => __$ContributorOptionCopyWithImpl<_ContributorOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributorOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributorOption&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone);

@override
String toString() {
  return 'ContributorOption(id: $id, fullName: $fullName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$ContributorOptionCopyWith<$Res> implements $ContributorOptionCopyWith<$Res> {
  factory _$ContributorOptionCopyWith(_ContributorOption value, $Res Function(_ContributorOption) _then) = __$ContributorOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? phone
});




}
/// @nodoc
class __$ContributorOptionCopyWithImpl<$Res>
    implements _$ContributorOptionCopyWith<$Res> {
  __$ContributorOptionCopyWithImpl(this._self, this._then);

  final _ContributorOption _self;
  final $Res Function(_ContributorOption) _then;

/// Create a copy of ContributorOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phone = freezed,}) {
  return _then(_ContributorOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
