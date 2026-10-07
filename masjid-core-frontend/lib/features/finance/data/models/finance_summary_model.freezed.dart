// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finance_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinanceSummaryModel {

 double get totalCollection; double get totalExpense; double get currentBalance; double get thisMonthCollection; double get thisMonthExpense; double get thisMonthBalance; FinanceBreakdown get breakdown;
/// Create a copy of FinanceSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinanceSummaryModelCopyWith<FinanceSummaryModel> get copyWith => _$FinanceSummaryModelCopyWithImpl<FinanceSummaryModel>(this as FinanceSummaryModel, _$identity);

  /// Serializes this FinanceSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinanceSummaryModel&&(identical(other.totalCollection, totalCollection) || other.totalCollection == totalCollection)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&(identical(other.thisMonthCollection, thisMonthCollection) || other.thisMonthCollection == thisMonthCollection)&&(identical(other.thisMonthExpense, thisMonthExpense) || other.thisMonthExpense == thisMonthExpense)&&(identical(other.thisMonthBalance, thisMonthBalance) || other.thisMonthBalance == thisMonthBalance)&&(identical(other.breakdown, breakdown) || other.breakdown == breakdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCollection,totalExpense,currentBalance,thisMonthCollection,thisMonthExpense,thisMonthBalance,breakdown);

@override
String toString() {
  return 'FinanceSummaryModel(totalCollection: $totalCollection, totalExpense: $totalExpense, currentBalance: $currentBalance, thisMonthCollection: $thisMonthCollection, thisMonthExpense: $thisMonthExpense, thisMonthBalance: $thisMonthBalance, breakdown: $breakdown)';
}


}

/// @nodoc
abstract mixin class $FinanceSummaryModelCopyWith<$Res>  {
  factory $FinanceSummaryModelCopyWith(FinanceSummaryModel value, $Res Function(FinanceSummaryModel) _then) = _$FinanceSummaryModelCopyWithImpl;
@useResult
$Res call({
 double totalCollection, double totalExpense, double currentBalance, double thisMonthCollection, double thisMonthExpense, double thisMonthBalance, FinanceBreakdown breakdown
});


$FinanceBreakdownCopyWith<$Res> get breakdown;

}
/// @nodoc
class _$FinanceSummaryModelCopyWithImpl<$Res>
    implements $FinanceSummaryModelCopyWith<$Res> {
  _$FinanceSummaryModelCopyWithImpl(this._self, this._then);

  final FinanceSummaryModel _self;
  final $Res Function(FinanceSummaryModel) _then;

/// Create a copy of FinanceSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCollection = null,Object? totalExpense = null,Object? currentBalance = null,Object? thisMonthCollection = null,Object? thisMonthExpense = null,Object? thisMonthBalance = null,Object? breakdown = null,}) {
  return _then(_self.copyWith(
totalCollection: null == totalCollection ? _self.totalCollection : totalCollection // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as double,thisMonthCollection: null == thisMonthCollection ? _self.thisMonthCollection : thisMonthCollection // ignore: cast_nullable_to_non_nullable
as double,thisMonthExpense: null == thisMonthExpense ? _self.thisMonthExpense : thisMonthExpense // ignore: cast_nullable_to_non_nullable
as double,thisMonthBalance: null == thisMonthBalance ? _self.thisMonthBalance : thisMonthBalance // ignore: cast_nullable_to_non_nullable
as double,breakdown: null == breakdown ? _self.breakdown : breakdown // ignore: cast_nullable_to_non_nullable
as FinanceBreakdown,
  ));
}
/// Create a copy of FinanceSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinanceBreakdownCopyWith<$Res> get breakdown {
  
  return $FinanceBreakdownCopyWith<$Res>(_self.breakdown, (value) {
    return _then(_self.copyWith(breakdown: value));
  });
}
}


/// Adds pattern-matching-related methods to [FinanceSummaryModel].
extension FinanceSummaryModelPatterns on FinanceSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinanceSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinanceSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinanceSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _FinanceSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinanceSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _FinanceSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double totalCollection,  double totalExpense,  double currentBalance,  double thisMonthCollection,  double thisMonthExpense,  double thisMonthBalance,  FinanceBreakdown breakdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinanceSummaryModel() when $default != null:
return $default(_that.totalCollection,_that.totalExpense,_that.currentBalance,_that.thisMonthCollection,_that.thisMonthExpense,_that.thisMonthBalance,_that.breakdown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double totalCollection,  double totalExpense,  double currentBalance,  double thisMonthCollection,  double thisMonthExpense,  double thisMonthBalance,  FinanceBreakdown breakdown)  $default,) {final _that = this;
switch (_that) {
case _FinanceSummaryModel():
return $default(_that.totalCollection,_that.totalExpense,_that.currentBalance,_that.thisMonthCollection,_that.thisMonthExpense,_that.thisMonthBalance,_that.breakdown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double totalCollection,  double totalExpense,  double currentBalance,  double thisMonthCollection,  double thisMonthExpense,  double thisMonthBalance,  FinanceBreakdown breakdown)?  $default,) {final _that = this;
switch (_that) {
case _FinanceSummaryModel() when $default != null:
return $default(_that.totalCollection,_that.totalExpense,_that.currentBalance,_that.thisMonthCollection,_that.thisMonthExpense,_that.thisMonthBalance,_that.breakdown);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinanceSummaryModel implements FinanceSummaryModel {
  const _FinanceSummaryModel({this.totalCollection = 0, this.totalExpense = 0, this.currentBalance = 0, this.thisMonthCollection = 0, this.thisMonthExpense = 0, this.thisMonthBalance = 0, this.breakdown = const FinanceBreakdown()});
  factory _FinanceSummaryModel.fromJson(Map<String, dynamic> json) => _$FinanceSummaryModelFromJson(json);

@override@JsonKey() final  double totalCollection;
@override@JsonKey() final  double totalExpense;
@override@JsonKey() final  double currentBalance;
@override@JsonKey() final  double thisMonthCollection;
@override@JsonKey() final  double thisMonthExpense;
@override@JsonKey() final  double thisMonthBalance;
@override@JsonKey() final  FinanceBreakdown breakdown;

/// Create a copy of FinanceSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinanceSummaryModelCopyWith<_FinanceSummaryModel> get copyWith => __$FinanceSummaryModelCopyWithImpl<_FinanceSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinanceSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinanceSummaryModel&&(identical(other.totalCollection, totalCollection) || other.totalCollection == totalCollection)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.currentBalance, currentBalance) || other.currentBalance == currentBalance)&&(identical(other.thisMonthCollection, thisMonthCollection) || other.thisMonthCollection == thisMonthCollection)&&(identical(other.thisMonthExpense, thisMonthExpense) || other.thisMonthExpense == thisMonthExpense)&&(identical(other.thisMonthBalance, thisMonthBalance) || other.thisMonthBalance == thisMonthBalance)&&(identical(other.breakdown, breakdown) || other.breakdown == breakdown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCollection,totalExpense,currentBalance,thisMonthCollection,thisMonthExpense,thisMonthBalance,breakdown);

@override
String toString() {
  return 'FinanceSummaryModel(totalCollection: $totalCollection, totalExpense: $totalExpense, currentBalance: $currentBalance, thisMonthCollection: $thisMonthCollection, thisMonthExpense: $thisMonthExpense, thisMonthBalance: $thisMonthBalance, breakdown: $breakdown)';
}


}

/// @nodoc
abstract mixin class _$FinanceSummaryModelCopyWith<$Res> implements $FinanceSummaryModelCopyWith<$Res> {
  factory _$FinanceSummaryModelCopyWith(_FinanceSummaryModel value, $Res Function(_FinanceSummaryModel) _then) = __$FinanceSummaryModelCopyWithImpl;
@override @useResult
$Res call({
 double totalCollection, double totalExpense, double currentBalance, double thisMonthCollection, double thisMonthExpense, double thisMonthBalance, FinanceBreakdown breakdown
});


@override $FinanceBreakdownCopyWith<$Res> get breakdown;

}
/// @nodoc
class __$FinanceSummaryModelCopyWithImpl<$Res>
    implements _$FinanceSummaryModelCopyWith<$Res> {
  __$FinanceSummaryModelCopyWithImpl(this._self, this._then);

  final _FinanceSummaryModel _self;
  final $Res Function(_FinanceSummaryModel) _then;

/// Create a copy of FinanceSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCollection = null,Object? totalExpense = null,Object? currentBalance = null,Object? thisMonthCollection = null,Object? thisMonthExpense = null,Object? thisMonthBalance = null,Object? breakdown = null,}) {
  return _then(_FinanceSummaryModel(
totalCollection: null == totalCollection ? _self.totalCollection : totalCollection // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,currentBalance: null == currentBalance ? _self.currentBalance : currentBalance // ignore: cast_nullable_to_non_nullable
as double,thisMonthCollection: null == thisMonthCollection ? _self.thisMonthCollection : thisMonthCollection // ignore: cast_nullable_to_non_nullable
as double,thisMonthExpense: null == thisMonthExpense ? _self.thisMonthExpense : thisMonthExpense // ignore: cast_nullable_to_non_nullable
as double,thisMonthBalance: null == thisMonthBalance ? _self.thisMonthBalance : thisMonthBalance // ignore: cast_nullable_to_non_nullable
as double,breakdown: null == breakdown ? _self.breakdown : breakdown // ignore: cast_nullable_to_non_nullable
as FinanceBreakdown,
  ));
}

/// Create a copy of FinanceSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinanceBreakdownCopyWith<$Res> get breakdown {
  
  return $FinanceBreakdownCopyWith<$Res>(_self.breakdown, (value) {
    return _then(_self.copyWith(breakdown: value));
  });
}
}


/// @nodoc
mixin _$FinanceBreakdown {

 FinanceTotals get total; FinanceTotals get period;
/// Create a copy of FinanceBreakdown
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinanceBreakdownCopyWith<FinanceBreakdown> get copyWith => _$FinanceBreakdownCopyWithImpl<FinanceBreakdown>(this as FinanceBreakdown, _$identity);

  /// Serializes this FinanceBreakdown to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinanceBreakdown&&(identical(other.total, total) || other.total == total)&&(identical(other.period, period) || other.period == period));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,period);

@override
String toString() {
  return 'FinanceBreakdown(total: $total, period: $period)';
}


}

/// @nodoc
abstract mixin class $FinanceBreakdownCopyWith<$Res>  {
  factory $FinanceBreakdownCopyWith(FinanceBreakdown value, $Res Function(FinanceBreakdown) _then) = _$FinanceBreakdownCopyWithImpl;
@useResult
$Res call({
 FinanceTotals total, FinanceTotals period
});


$FinanceTotalsCopyWith<$Res> get total;$FinanceTotalsCopyWith<$Res> get period;

}
/// @nodoc
class _$FinanceBreakdownCopyWithImpl<$Res>
    implements $FinanceBreakdownCopyWith<$Res> {
  _$FinanceBreakdownCopyWithImpl(this._self, this._then);

  final FinanceBreakdown _self;
  final $Res Function(FinanceBreakdown) _then;

/// Create a copy of FinanceBreakdown
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? period = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as FinanceTotals,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as FinanceTotals,
  ));
}
/// Create a copy of FinanceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinanceTotalsCopyWith<$Res> get total {
  
  return $FinanceTotalsCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of FinanceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinanceTotalsCopyWith<$Res> get period {
  
  return $FinanceTotalsCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// Adds pattern-matching-related methods to [FinanceBreakdown].
extension FinanceBreakdownPatterns on FinanceBreakdown {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinanceBreakdown value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinanceBreakdown() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinanceBreakdown value)  $default,){
final _that = this;
switch (_that) {
case _FinanceBreakdown():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinanceBreakdown value)?  $default,){
final _that = this;
switch (_that) {
case _FinanceBreakdown() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FinanceTotals total,  FinanceTotals period)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinanceBreakdown() when $default != null:
return $default(_that.total,_that.period);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FinanceTotals total,  FinanceTotals period)  $default,) {final _that = this;
switch (_that) {
case _FinanceBreakdown():
return $default(_that.total,_that.period);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FinanceTotals total,  FinanceTotals period)?  $default,) {final _that = this;
switch (_that) {
case _FinanceBreakdown() when $default != null:
return $default(_that.total,_that.period);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinanceBreakdown implements FinanceBreakdown {
  const _FinanceBreakdown({this.total = const FinanceTotals(), this.period = const FinanceTotals()});
  factory _FinanceBreakdown.fromJson(Map<String, dynamic> json) => _$FinanceBreakdownFromJson(json);

@override@JsonKey() final  FinanceTotals total;
@override@JsonKey() final  FinanceTotals period;

/// Create a copy of FinanceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinanceBreakdownCopyWith<_FinanceBreakdown> get copyWith => __$FinanceBreakdownCopyWithImpl<_FinanceBreakdown>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinanceBreakdownToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinanceBreakdown&&(identical(other.total, total) || other.total == total)&&(identical(other.period, period) || other.period == period));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,period);

@override
String toString() {
  return 'FinanceBreakdown(total: $total, period: $period)';
}


}

/// @nodoc
abstract mixin class _$FinanceBreakdownCopyWith<$Res> implements $FinanceBreakdownCopyWith<$Res> {
  factory _$FinanceBreakdownCopyWith(_FinanceBreakdown value, $Res Function(_FinanceBreakdown) _then) = __$FinanceBreakdownCopyWithImpl;
@override @useResult
$Res call({
 FinanceTotals total, FinanceTotals period
});


@override $FinanceTotalsCopyWith<$Res> get total;@override $FinanceTotalsCopyWith<$Res> get period;

}
/// @nodoc
class __$FinanceBreakdownCopyWithImpl<$Res>
    implements _$FinanceBreakdownCopyWith<$Res> {
  __$FinanceBreakdownCopyWithImpl(this._self, this._then);

  final _FinanceBreakdown _self;
  final $Res Function(_FinanceBreakdown) _then;

/// Create a copy of FinanceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? period = null,}) {
  return _then(_FinanceBreakdown(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as FinanceTotals,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as FinanceTotals,
  ));
}

/// Create a copy of FinanceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinanceTotalsCopyWith<$Res> get total {
  
  return $FinanceTotalsCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}/// Create a copy of FinanceBreakdown
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FinanceTotalsCopyWith<$Res> get period {
  
  return $FinanceTotalsCopyWith<$Res>(_self.period, (value) {
    return _then(_self.copyWith(period: value));
  });
}
}


/// @nodoc
mixin _$FinanceTotals {

 double get generalCollections; double get projectContributions; double get imamSalaryCollected; double get income; double get expenses; double get balance;
/// Create a copy of FinanceTotals
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinanceTotalsCopyWith<FinanceTotals> get copyWith => _$FinanceTotalsCopyWithImpl<FinanceTotals>(this as FinanceTotals, _$identity);

  /// Serializes this FinanceTotals to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinanceTotals&&(identical(other.generalCollections, generalCollections) || other.generalCollections == generalCollections)&&(identical(other.projectContributions, projectContributions) || other.projectContributions == projectContributions)&&(identical(other.imamSalaryCollected, imamSalaryCollected) || other.imamSalaryCollected == imamSalaryCollected)&&(identical(other.income, income) || other.income == income)&&(identical(other.expenses, expenses) || other.expenses == expenses)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,generalCollections,projectContributions,imamSalaryCollected,income,expenses,balance);

@override
String toString() {
  return 'FinanceTotals(generalCollections: $generalCollections, projectContributions: $projectContributions, imamSalaryCollected: $imamSalaryCollected, income: $income, expenses: $expenses, balance: $balance)';
}


}

/// @nodoc
abstract mixin class $FinanceTotalsCopyWith<$Res>  {
  factory $FinanceTotalsCopyWith(FinanceTotals value, $Res Function(FinanceTotals) _then) = _$FinanceTotalsCopyWithImpl;
@useResult
$Res call({
 double generalCollections, double projectContributions, double imamSalaryCollected, double income, double expenses, double balance
});




}
/// @nodoc
class _$FinanceTotalsCopyWithImpl<$Res>
    implements $FinanceTotalsCopyWith<$Res> {
  _$FinanceTotalsCopyWithImpl(this._self, this._then);

  final FinanceTotals _self;
  final $Res Function(FinanceTotals) _then;

/// Create a copy of FinanceTotals
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? generalCollections = null,Object? projectContributions = null,Object? imamSalaryCollected = null,Object? income = null,Object? expenses = null,Object? balance = null,}) {
  return _then(_self.copyWith(
generalCollections: null == generalCollections ? _self.generalCollections : generalCollections // ignore: cast_nullable_to_non_nullable
as double,projectContributions: null == projectContributions ? _self.projectContributions : projectContributions // ignore: cast_nullable_to_non_nullable
as double,imamSalaryCollected: null == imamSalaryCollected ? _self.imamSalaryCollected : imamSalaryCollected // ignore: cast_nullable_to_non_nullable
as double,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FinanceTotals].
extension FinanceTotalsPatterns on FinanceTotals {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinanceTotals value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinanceTotals() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinanceTotals value)  $default,){
final _that = this;
switch (_that) {
case _FinanceTotals():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinanceTotals value)?  $default,){
final _that = this;
switch (_that) {
case _FinanceTotals() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double generalCollections,  double projectContributions,  double imamSalaryCollected,  double income,  double expenses,  double balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinanceTotals() when $default != null:
return $default(_that.generalCollections,_that.projectContributions,_that.imamSalaryCollected,_that.income,_that.expenses,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double generalCollections,  double projectContributions,  double imamSalaryCollected,  double income,  double expenses,  double balance)  $default,) {final _that = this;
switch (_that) {
case _FinanceTotals():
return $default(_that.generalCollections,_that.projectContributions,_that.imamSalaryCollected,_that.income,_that.expenses,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double generalCollections,  double projectContributions,  double imamSalaryCollected,  double income,  double expenses,  double balance)?  $default,) {final _that = this;
switch (_that) {
case _FinanceTotals() when $default != null:
return $default(_that.generalCollections,_that.projectContributions,_that.imamSalaryCollected,_that.income,_that.expenses,_that.balance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinanceTotals implements FinanceTotals {
  const _FinanceTotals({this.generalCollections = 0, this.projectContributions = 0, this.imamSalaryCollected = 0, this.income = 0, this.expenses = 0, this.balance = 0});
  factory _FinanceTotals.fromJson(Map<String, dynamic> json) => _$FinanceTotalsFromJson(json);

@override@JsonKey() final  double generalCollections;
@override@JsonKey() final  double projectContributions;
@override@JsonKey() final  double imamSalaryCollected;
@override@JsonKey() final  double income;
@override@JsonKey() final  double expenses;
@override@JsonKey() final  double balance;

/// Create a copy of FinanceTotals
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinanceTotalsCopyWith<_FinanceTotals> get copyWith => __$FinanceTotalsCopyWithImpl<_FinanceTotals>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinanceTotalsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinanceTotals&&(identical(other.generalCollections, generalCollections) || other.generalCollections == generalCollections)&&(identical(other.projectContributions, projectContributions) || other.projectContributions == projectContributions)&&(identical(other.imamSalaryCollected, imamSalaryCollected) || other.imamSalaryCollected == imamSalaryCollected)&&(identical(other.income, income) || other.income == income)&&(identical(other.expenses, expenses) || other.expenses == expenses)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,generalCollections,projectContributions,imamSalaryCollected,income,expenses,balance);

@override
String toString() {
  return 'FinanceTotals(generalCollections: $generalCollections, projectContributions: $projectContributions, imamSalaryCollected: $imamSalaryCollected, income: $income, expenses: $expenses, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$FinanceTotalsCopyWith<$Res> implements $FinanceTotalsCopyWith<$Res> {
  factory _$FinanceTotalsCopyWith(_FinanceTotals value, $Res Function(_FinanceTotals) _then) = __$FinanceTotalsCopyWithImpl;
@override @useResult
$Res call({
 double generalCollections, double projectContributions, double imamSalaryCollected, double income, double expenses, double balance
});




}
/// @nodoc
class __$FinanceTotalsCopyWithImpl<$Res>
    implements _$FinanceTotalsCopyWith<$Res> {
  __$FinanceTotalsCopyWithImpl(this._self, this._then);

  final _FinanceTotals _self;
  final $Res Function(_FinanceTotals) _then;

/// Create a copy of FinanceTotals
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? generalCollections = null,Object? projectContributions = null,Object? imamSalaryCollected = null,Object? income = null,Object? expenses = null,Object? balance = null,}) {
  return _then(_FinanceTotals(
generalCollections: null == generalCollections ? _self.generalCollections : generalCollections // ignore: cast_nullable_to_non_nullable
as double,projectContributions: null == projectContributions ? _self.projectContributions : projectContributions // ignore: cast_nullable_to_non_nullable
as double,imamSalaryCollected: null == imamSalaryCollected ? _self.imamSalaryCollected : imamSalaryCollected // ignore: cast_nullable_to_non_nullable
as double,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as double,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
