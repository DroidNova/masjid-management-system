// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_collection_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateCollectionRequest {

 String get type; double get amount; String? get title; String? get description;/// `yyyy-MM-dd`.
 String? get collectedAt;
/// Create a copy of CreateCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCollectionRequestCopyWith<CreateCollectionRequest> get copyWith => _$CreateCollectionRequestCopyWithImpl<CreateCollectionRequest>(this as CreateCollectionRequest, _$identity);

  /// Serializes this CreateCollectionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCollectionRequest&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.collectedAt, collectedAt) || other.collectedAt == collectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,amount,title,description,collectedAt);

@override
String toString() {
  return 'CreateCollectionRequest(type: $type, amount: $amount, title: $title, description: $description, collectedAt: $collectedAt)';
}


}

/// @nodoc
abstract mixin class $CreateCollectionRequestCopyWith<$Res>  {
  factory $CreateCollectionRequestCopyWith(CreateCollectionRequest value, $Res Function(CreateCollectionRequest) _then) = _$CreateCollectionRequestCopyWithImpl;
@useResult
$Res call({
 String type, double amount, String? title, String? description, String? collectedAt
});




}
/// @nodoc
class _$CreateCollectionRequestCopyWithImpl<$Res>
    implements $CreateCollectionRequestCopyWith<$Res> {
  _$CreateCollectionRequestCopyWithImpl(this._self, this._then);

  final CreateCollectionRequest _self;
  final $Res Function(CreateCollectionRequest) _then;

/// Create a copy of CreateCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? amount = null,Object? title = freezed,Object? description = freezed,Object? collectedAt = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,collectedAt: freezed == collectedAt ? _self.collectedAt : collectedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCollectionRequest].
extension CreateCollectionRequestPatterns on CreateCollectionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCollectionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCollectionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCollectionRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateCollectionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCollectionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCollectionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  double amount,  String? title,  String? description,  String? collectedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCollectionRequest() when $default != null:
return $default(_that.type,_that.amount,_that.title,_that.description,_that.collectedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  double amount,  String? title,  String? description,  String? collectedAt)  $default,) {final _that = this;
switch (_that) {
case _CreateCollectionRequest():
return $default(_that.type,_that.amount,_that.title,_that.description,_that.collectedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  double amount,  String? title,  String? description,  String? collectedAt)?  $default,) {final _that = this;
switch (_that) {
case _CreateCollectionRequest() when $default != null:
return $default(_that.type,_that.amount,_that.title,_that.description,_that.collectedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _CreateCollectionRequest implements CreateCollectionRequest {
  const _CreateCollectionRequest({required this.type, required this.amount, this.title, this.description, this.collectedAt});
  factory _CreateCollectionRequest.fromJson(Map<String, dynamic> json) => _$CreateCollectionRequestFromJson(json);

@override final  String type;
@override final  double amount;
@override final  String? title;
@override final  String? description;
/// `yyyy-MM-dd`.
@override final  String? collectedAt;

/// Create a copy of CreateCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCollectionRequestCopyWith<_CreateCollectionRequest> get copyWith => __$CreateCollectionRequestCopyWithImpl<_CreateCollectionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCollectionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCollectionRequest&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.collectedAt, collectedAt) || other.collectedAt == collectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,amount,title,description,collectedAt);

@override
String toString() {
  return 'CreateCollectionRequest(type: $type, amount: $amount, title: $title, description: $description, collectedAt: $collectedAt)';
}


}

/// @nodoc
abstract mixin class _$CreateCollectionRequestCopyWith<$Res> implements $CreateCollectionRequestCopyWith<$Res> {
  factory _$CreateCollectionRequestCopyWith(_CreateCollectionRequest value, $Res Function(_CreateCollectionRequest) _then) = __$CreateCollectionRequestCopyWithImpl;
@override @useResult
$Res call({
 String type, double amount, String? title, String? description, String? collectedAt
});




}
/// @nodoc
class __$CreateCollectionRequestCopyWithImpl<$Res>
    implements _$CreateCollectionRequestCopyWith<$Res> {
  __$CreateCollectionRequestCopyWithImpl(this._self, this._then);

  final _CreateCollectionRequest _self;
  final $Res Function(_CreateCollectionRequest) _then;

/// Create a copy of CreateCollectionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? amount = null,Object? title = freezed,Object? description = freezed,Object? collectedAt = freezed,}) {
  return _then(_CreateCollectionRequest(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,collectedAt: freezed == collectedAt ? _self.collectedAt : collectedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
