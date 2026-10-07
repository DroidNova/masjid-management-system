// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_imam_salary_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyImamSalaryPayment {

 String get id; double get amount; String get paymentMode; DateTime? get paidAt; String get collectedByName; String? get note;
/// Create a copy of MyImamSalaryPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyImamSalaryPaymentCopyWith<MyImamSalaryPayment> get copyWith => _$MyImamSalaryPaymentCopyWithImpl<MyImamSalaryPayment>(this as MyImamSalaryPayment, _$identity);

  /// Serializes this MyImamSalaryPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyImamSalaryPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.collectedByName, collectedByName) || other.collectedByName == collectedByName)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,paymentMode,paidAt,collectedByName,note);

@override
String toString() {
  return 'MyImamSalaryPayment(id: $id, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, collectedByName: $collectedByName, note: $note)';
}


}

/// @nodoc
abstract mixin class $MyImamSalaryPaymentCopyWith<$Res>  {
  factory $MyImamSalaryPaymentCopyWith(MyImamSalaryPayment value, $Res Function(MyImamSalaryPayment) _then) = _$MyImamSalaryPaymentCopyWithImpl;
@useResult
$Res call({
 String id, double amount, String paymentMode, DateTime? paidAt, String collectedByName, String? note
});




}
/// @nodoc
class _$MyImamSalaryPaymentCopyWithImpl<$Res>
    implements $MyImamSalaryPaymentCopyWith<$Res> {
  _$MyImamSalaryPaymentCopyWithImpl(this._self, this._then);

  final MyImamSalaryPayment _self;
  final $Res Function(MyImamSalaryPayment) _then;

/// Create a copy of MyImamSalaryPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? collectedByName = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,collectedByName: null == collectedByName ? _self.collectedByName : collectedByName // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MyImamSalaryPayment].
extension MyImamSalaryPaymentPatterns on MyImamSalaryPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyImamSalaryPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyImamSalaryPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyImamSalaryPayment value)  $default,){
final _that = this;
switch (_that) {
case _MyImamSalaryPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyImamSalaryPayment value)?  $default,){
final _that = this;
switch (_that) {
case _MyImamSalaryPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyImamSalaryPayment() when $default != null:
return $default(_that.id,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note)  $default,) {final _that = this;
switch (_that) {
case _MyImamSalaryPayment():
return $default(_that.id,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _MyImamSalaryPayment() when $default != null:
return $default(_that.id,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyImamSalaryPayment implements MyImamSalaryPayment {
  const _MyImamSalaryPayment({required this.id, this.amount = 0, this.paymentMode = '', this.paidAt, this.collectedByName = 'Not available', this.note});
  factory _MyImamSalaryPayment.fromJson(Map<String, dynamic> json) => _$MyImamSalaryPaymentFromJson(json);

@override final  String id;
@override@JsonKey() final  double amount;
@override@JsonKey() final  String paymentMode;
@override final  DateTime? paidAt;
@override@JsonKey() final  String collectedByName;
@override final  String? note;

/// Create a copy of MyImamSalaryPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyImamSalaryPaymentCopyWith<_MyImamSalaryPayment> get copyWith => __$MyImamSalaryPaymentCopyWithImpl<_MyImamSalaryPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyImamSalaryPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyImamSalaryPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.collectedByName, collectedByName) || other.collectedByName == collectedByName)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,paymentMode,paidAt,collectedByName,note);

@override
String toString() {
  return 'MyImamSalaryPayment(id: $id, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, collectedByName: $collectedByName, note: $note)';
}


}

/// @nodoc
abstract mixin class _$MyImamSalaryPaymentCopyWith<$Res> implements $MyImamSalaryPaymentCopyWith<$Res> {
  factory _$MyImamSalaryPaymentCopyWith(_MyImamSalaryPayment value, $Res Function(_MyImamSalaryPayment) _then) = __$MyImamSalaryPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount, String paymentMode, DateTime? paidAt, String collectedByName, String? note
});




}
/// @nodoc
class __$MyImamSalaryPaymentCopyWithImpl<$Res>
    implements _$MyImamSalaryPaymentCopyWith<$Res> {
  __$MyImamSalaryPaymentCopyWithImpl(this._self, this._then);

  final _MyImamSalaryPayment _self;
  final $Res Function(_MyImamSalaryPayment) _then;

/// Create a copy of MyImamSalaryPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? collectedByName = null,Object? note = freezed,}) {
  return _then(_MyImamSalaryPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,collectedByName: null == collectedByName ? _self.collectedByName : collectedByName // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
