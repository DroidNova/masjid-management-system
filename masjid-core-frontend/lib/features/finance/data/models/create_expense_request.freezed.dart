// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_expense_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateExpenseRequest {

 String get type; double get amount; String? get title; String? get description;/// `yyyy-MM-dd`.
 String? get spentAt;
/// Create a copy of CreateExpenseRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateExpenseRequestCopyWith<CreateExpenseRequest> get copyWith => _$CreateExpenseRequestCopyWithImpl<CreateExpenseRequest>(this as CreateExpenseRequest, _$identity);

  /// Serializes this CreateExpenseRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateExpenseRequest&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.spentAt, spentAt) || other.spentAt == spentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,amount,title,description,spentAt);

@override
String toString() {
  return 'CreateExpenseRequest(type: $type, amount: $amount, title: $title, description: $description, spentAt: $spentAt)';
}


}

/// @nodoc
abstract mixin class $CreateExpenseRequestCopyWith<$Res>  {
  factory $CreateExpenseRequestCopyWith(CreateExpenseRequest value, $Res Function(CreateExpenseRequest) _then) = _$CreateExpenseRequestCopyWithImpl;
@useResult
$Res call({
 String type, double amount, String? title, String? description, String? spentAt
});




}
/// @nodoc
class _$CreateExpenseRequestCopyWithImpl<$Res>
    implements $CreateExpenseRequestCopyWith<$Res> {
  _$CreateExpenseRequestCopyWithImpl(this._self, this._then);

  final CreateExpenseRequest _self;
  final $Res Function(CreateExpenseRequest) _then;

/// Create a copy of CreateExpenseRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? amount = null,Object? title = freezed,Object? description = freezed,Object? spentAt = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,spentAt: freezed == spentAt ? _self.spentAt : spentAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateExpenseRequest].
extension CreateExpenseRequestPatterns on CreateExpenseRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateExpenseRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateExpenseRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateExpenseRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateExpenseRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateExpenseRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateExpenseRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  double amount,  String? title,  String? description,  String? spentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateExpenseRequest() when $default != null:
return $default(_that.type,_that.amount,_that.title,_that.description,_that.spentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  double amount,  String? title,  String? description,  String? spentAt)  $default,) {final _that = this;
switch (_that) {
case _CreateExpenseRequest():
return $default(_that.type,_that.amount,_that.title,_that.description,_that.spentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  double amount,  String? title,  String? description,  String? spentAt)?  $default,) {final _that = this;
switch (_that) {
case _CreateExpenseRequest() when $default != null:
return $default(_that.type,_that.amount,_that.title,_that.description,_that.spentAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _CreateExpenseRequest implements CreateExpenseRequest {
  const _CreateExpenseRequest({required this.type, required this.amount, this.title, this.description, this.spentAt});
  factory _CreateExpenseRequest.fromJson(Map<String, dynamic> json) => _$CreateExpenseRequestFromJson(json);

@override final  String type;
@override final  double amount;
@override final  String? title;
@override final  String? description;
/// `yyyy-MM-dd`.
@override final  String? spentAt;

/// Create a copy of CreateExpenseRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateExpenseRequestCopyWith<_CreateExpenseRequest> get copyWith => __$CreateExpenseRequestCopyWithImpl<_CreateExpenseRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateExpenseRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateExpenseRequest&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.spentAt, spentAt) || other.spentAt == spentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,amount,title,description,spentAt);

@override
String toString() {
  return 'CreateExpenseRequest(type: $type, amount: $amount, title: $title, description: $description, spentAt: $spentAt)';
}


}

/// @nodoc
abstract mixin class _$CreateExpenseRequestCopyWith<$Res> implements $CreateExpenseRequestCopyWith<$Res> {
  factory _$CreateExpenseRequestCopyWith(_CreateExpenseRequest value, $Res Function(_CreateExpenseRequest) _then) = __$CreateExpenseRequestCopyWithImpl;
@override @useResult
$Res call({
 String type, double amount, String? title, String? description, String? spentAt
});




}
/// @nodoc
class __$CreateExpenseRequestCopyWithImpl<$Res>
    implements _$CreateExpenseRequestCopyWith<$Res> {
  __$CreateExpenseRequestCopyWithImpl(this._self, this._then);

  final _CreateExpenseRequest _self;
  final $Res Function(_CreateExpenseRequest) _then;

/// Create a copy of CreateExpenseRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? amount = null,Object? title = freezed,Object? description = freezed,Object? spentAt = freezed,}) {
  return _then(_CreateExpenseRequest(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,spentAt: freezed == spentAt ? _self.spentAt : spentAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
