// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_imam_salary_month.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyImamSalaryMonth {

 int get month; int get year; double get expectedAmount; double get paidAmount; double get dueAmount; String get status; int get paymentsCount; DateTime? get lastPaidAt;
/// Create a copy of MyImamSalaryMonth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyImamSalaryMonthCopyWith<MyImamSalaryMonth> get copyWith => _$MyImamSalaryMonthCopyWithImpl<MyImamSalaryMonth>(this as MyImamSalaryMonth, _$identity);

  /// Serializes this MyImamSalaryMonth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyImamSalaryMonth&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueAmount, dueAmount) || other.dueAmount == dueAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentsCount, paymentsCount) || other.paymentsCount == paymentsCount)&&(identical(other.lastPaidAt, lastPaidAt) || other.lastPaidAt == lastPaidAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,expectedAmount,paidAmount,dueAmount,status,paymentsCount,lastPaidAt);

@override
String toString() {
  return 'MyImamSalaryMonth(month: $month, year: $year, expectedAmount: $expectedAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, status: $status, paymentsCount: $paymentsCount, lastPaidAt: $lastPaidAt)';
}


}

/// @nodoc
abstract mixin class $MyImamSalaryMonthCopyWith<$Res>  {
  factory $MyImamSalaryMonthCopyWith(MyImamSalaryMonth value, $Res Function(MyImamSalaryMonth) _then) = _$MyImamSalaryMonthCopyWithImpl;
@useResult
$Res call({
 int month, int year, double expectedAmount, double paidAmount, double dueAmount, String status, int paymentsCount, DateTime? lastPaidAt
});




}
/// @nodoc
class _$MyImamSalaryMonthCopyWithImpl<$Res>
    implements $MyImamSalaryMonthCopyWith<$Res> {
  _$MyImamSalaryMonthCopyWithImpl(this._self, this._then);

  final MyImamSalaryMonth _self;
  final $Res Function(MyImamSalaryMonth) _then;

/// Create a copy of MyImamSalaryMonth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? year = null,Object? expectedAmount = null,Object? paidAmount = null,Object? dueAmount = null,Object? status = null,Object? paymentsCount = null,Object? lastPaidAt = freezed,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,dueAmount: null == dueAmount ? _self.dueAmount : dueAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentsCount: null == paymentsCount ? _self.paymentsCount : paymentsCount // ignore: cast_nullable_to_non_nullable
as int,lastPaidAt: freezed == lastPaidAt ? _self.lastPaidAt : lastPaidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MyImamSalaryMonth].
extension MyImamSalaryMonthPatterns on MyImamSalaryMonth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyImamSalaryMonth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyImamSalaryMonth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyImamSalaryMonth value)  $default,){
final _that = this;
switch (_that) {
case _MyImamSalaryMonth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyImamSalaryMonth value)?  $default,){
final _that = this;
switch (_that) {
case _MyImamSalaryMonth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int month,  int year,  double expectedAmount,  double paidAmount,  double dueAmount,  String status,  int paymentsCount,  DateTime? lastPaidAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyImamSalaryMonth() when $default != null:
return $default(_that.month,_that.year,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status,_that.paymentsCount,_that.lastPaidAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int month,  int year,  double expectedAmount,  double paidAmount,  double dueAmount,  String status,  int paymentsCount,  DateTime? lastPaidAt)  $default,) {final _that = this;
switch (_that) {
case _MyImamSalaryMonth():
return $default(_that.month,_that.year,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status,_that.paymentsCount,_that.lastPaidAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int month,  int year,  double expectedAmount,  double paidAmount,  double dueAmount,  String status,  int paymentsCount,  DateTime? lastPaidAt)?  $default,) {final _that = this;
switch (_that) {
case _MyImamSalaryMonth() when $default != null:
return $default(_that.month,_that.year,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status,_that.paymentsCount,_that.lastPaidAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyImamSalaryMonth implements MyImamSalaryMonth {
  const _MyImamSalaryMonth({required this.month, required this.year, this.expectedAmount = 0, this.paidAmount = 0, this.dueAmount = 0, this.status = 'UNPAID', this.paymentsCount = 0, this.lastPaidAt});
  factory _MyImamSalaryMonth.fromJson(Map<String, dynamic> json) => _$MyImamSalaryMonthFromJson(json);

@override final  int month;
@override final  int year;
@override@JsonKey() final  double expectedAmount;
@override@JsonKey() final  double paidAmount;
@override@JsonKey() final  double dueAmount;
@override@JsonKey() final  String status;
@override@JsonKey() final  int paymentsCount;
@override final  DateTime? lastPaidAt;

/// Create a copy of MyImamSalaryMonth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyImamSalaryMonthCopyWith<_MyImamSalaryMonth> get copyWith => __$MyImamSalaryMonthCopyWithImpl<_MyImamSalaryMonth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyImamSalaryMonthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyImamSalaryMonth&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueAmount, dueAmount) || other.dueAmount == dueAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentsCount, paymentsCount) || other.paymentsCount == paymentsCount)&&(identical(other.lastPaidAt, lastPaidAt) || other.lastPaidAt == lastPaidAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,expectedAmount,paidAmount,dueAmount,status,paymentsCount,lastPaidAt);

@override
String toString() {
  return 'MyImamSalaryMonth(month: $month, year: $year, expectedAmount: $expectedAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, status: $status, paymentsCount: $paymentsCount, lastPaidAt: $lastPaidAt)';
}


}

/// @nodoc
abstract mixin class _$MyImamSalaryMonthCopyWith<$Res> implements $MyImamSalaryMonthCopyWith<$Res> {
  factory _$MyImamSalaryMonthCopyWith(_MyImamSalaryMonth value, $Res Function(_MyImamSalaryMonth) _then) = __$MyImamSalaryMonthCopyWithImpl;
@override @useResult
$Res call({
 int month, int year, double expectedAmount, double paidAmount, double dueAmount, String status, int paymentsCount, DateTime? lastPaidAt
});




}
/// @nodoc
class __$MyImamSalaryMonthCopyWithImpl<$Res>
    implements _$MyImamSalaryMonthCopyWith<$Res> {
  __$MyImamSalaryMonthCopyWithImpl(this._self, this._then);

  final _MyImamSalaryMonth _self;
  final $Res Function(_MyImamSalaryMonth) _then;

/// Create a copy of MyImamSalaryMonth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? year = null,Object? expectedAmount = null,Object? paidAmount = null,Object? dueAmount = null,Object? status = null,Object? paymentsCount = null,Object? lastPaidAt = freezed,}) {
  return _then(_MyImamSalaryMonth(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,dueAmount: null == dueAmount ? _self.dueAmount : dueAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentsCount: null == paymentsCount ? _self.paymentsCount : paymentsCount // ignore: cast_nullable_to_non_nullable
as int,lastPaidAt: freezed == lastPaidAt ? _self.lastPaidAt : lastPaidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
