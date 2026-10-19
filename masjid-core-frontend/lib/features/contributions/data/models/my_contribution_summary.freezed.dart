// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_contribution_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyContributionSummary {

 MyContributionUser get user; ImamSalaryContributionSummary get imamSalary; double get projectContributionTotal; double get collectionContributionTotal; double get totalContributionAmount;
/// Create a copy of MyContributionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyContributionSummaryCopyWith<MyContributionSummary> get copyWith => _$MyContributionSummaryCopyWithImpl<MyContributionSummary>(this as MyContributionSummary, _$identity);

  /// Serializes this MyContributionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyContributionSummary&&(identical(other.user, user) || other.user == user)&&(identical(other.imamSalary, imamSalary) || other.imamSalary == imamSalary)&&(identical(other.projectContributionTotal, projectContributionTotal) || other.projectContributionTotal == projectContributionTotal)&&(identical(other.collectionContributionTotal, collectionContributionTotal) || other.collectionContributionTotal == collectionContributionTotal)&&(identical(other.totalContributionAmount, totalContributionAmount) || other.totalContributionAmount == totalContributionAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,imamSalary,projectContributionTotal,collectionContributionTotal,totalContributionAmount);

@override
String toString() {
  return 'MyContributionSummary(user: $user, imamSalary: $imamSalary, projectContributionTotal: $projectContributionTotal, collectionContributionTotal: $collectionContributionTotal, totalContributionAmount: $totalContributionAmount)';
}


}

/// @nodoc
abstract mixin class $MyContributionSummaryCopyWith<$Res>  {
  factory $MyContributionSummaryCopyWith(MyContributionSummary value, $Res Function(MyContributionSummary) _then) = _$MyContributionSummaryCopyWithImpl;
@useResult
$Res call({
 MyContributionUser user, ImamSalaryContributionSummary imamSalary, double projectContributionTotal, double collectionContributionTotal, double totalContributionAmount
});


$MyContributionUserCopyWith<$Res> get user;$ImamSalaryContributionSummaryCopyWith<$Res> get imamSalary;

}
/// @nodoc
class _$MyContributionSummaryCopyWithImpl<$Res>
    implements $MyContributionSummaryCopyWith<$Res> {
  _$MyContributionSummaryCopyWithImpl(this._self, this._then);

  final MyContributionSummary _self;
  final $Res Function(MyContributionSummary) _then;

/// Create a copy of MyContributionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? imamSalary = null,Object? projectContributionTotal = null,Object? collectionContributionTotal = null,Object? totalContributionAmount = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MyContributionUser,imamSalary: null == imamSalary ? _self.imamSalary : imamSalary // ignore: cast_nullable_to_non_nullable
as ImamSalaryContributionSummary,projectContributionTotal: null == projectContributionTotal ? _self.projectContributionTotal : projectContributionTotal // ignore: cast_nullable_to_non_nullable
as double,collectionContributionTotal: null == collectionContributionTotal ? _self.collectionContributionTotal : collectionContributionTotal // ignore: cast_nullable_to_non_nullable
as double,totalContributionAmount: null == totalContributionAmount ? _self.totalContributionAmount : totalContributionAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of MyContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MyContributionUserCopyWith<$Res> get user {
  
  return $MyContributionUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of MyContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImamSalaryContributionSummaryCopyWith<$Res> get imamSalary {
  
  return $ImamSalaryContributionSummaryCopyWith<$Res>(_self.imamSalary, (value) {
    return _then(_self.copyWith(imamSalary: value));
  });
}
}


/// Adds pattern-matching-related methods to [MyContributionSummary].
extension MyContributionSummaryPatterns on MyContributionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyContributionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyContributionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyContributionSummary value)  $default,){
final _that = this;
switch (_that) {
case _MyContributionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyContributionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MyContributionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MyContributionUser user,  ImamSalaryContributionSummary imamSalary,  double projectContributionTotal,  double collectionContributionTotal,  double totalContributionAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyContributionSummary() when $default != null:
return $default(_that.user,_that.imamSalary,_that.projectContributionTotal,_that.collectionContributionTotal,_that.totalContributionAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MyContributionUser user,  ImamSalaryContributionSummary imamSalary,  double projectContributionTotal,  double collectionContributionTotal,  double totalContributionAmount)  $default,) {final _that = this;
switch (_that) {
case _MyContributionSummary():
return $default(_that.user,_that.imamSalary,_that.projectContributionTotal,_that.collectionContributionTotal,_that.totalContributionAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MyContributionUser user,  ImamSalaryContributionSummary imamSalary,  double projectContributionTotal,  double collectionContributionTotal,  double totalContributionAmount)?  $default,) {final _that = this;
switch (_that) {
case _MyContributionSummary() when $default != null:
return $default(_that.user,_that.imamSalary,_that.projectContributionTotal,_that.collectionContributionTotal,_that.totalContributionAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyContributionSummary implements MyContributionSummary {
  const _MyContributionSummary({required this.user, required this.imamSalary, this.projectContributionTotal = 0, this.collectionContributionTotal = 0, this.totalContributionAmount = 0});
  factory _MyContributionSummary.fromJson(Map<String, dynamic> json) => _$MyContributionSummaryFromJson(json);

@override final  MyContributionUser user;
@override final  ImamSalaryContributionSummary imamSalary;
@override@JsonKey() final  double projectContributionTotal;
@override@JsonKey() final  double collectionContributionTotal;
@override@JsonKey() final  double totalContributionAmount;

/// Create a copy of MyContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyContributionSummaryCopyWith<_MyContributionSummary> get copyWith => __$MyContributionSummaryCopyWithImpl<_MyContributionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyContributionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyContributionSummary&&(identical(other.user, user) || other.user == user)&&(identical(other.imamSalary, imamSalary) || other.imamSalary == imamSalary)&&(identical(other.projectContributionTotal, projectContributionTotal) || other.projectContributionTotal == projectContributionTotal)&&(identical(other.collectionContributionTotal, collectionContributionTotal) || other.collectionContributionTotal == collectionContributionTotal)&&(identical(other.totalContributionAmount, totalContributionAmount) || other.totalContributionAmount == totalContributionAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,imamSalary,projectContributionTotal,collectionContributionTotal,totalContributionAmount);

@override
String toString() {
  return 'MyContributionSummary(user: $user, imamSalary: $imamSalary, projectContributionTotal: $projectContributionTotal, collectionContributionTotal: $collectionContributionTotal, totalContributionAmount: $totalContributionAmount)';
}


}

/// @nodoc
abstract mixin class _$MyContributionSummaryCopyWith<$Res> implements $MyContributionSummaryCopyWith<$Res> {
  factory _$MyContributionSummaryCopyWith(_MyContributionSummary value, $Res Function(_MyContributionSummary) _then) = __$MyContributionSummaryCopyWithImpl;
@override @useResult
$Res call({
 MyContributionUser user, ImamSalaryContributionSummary imamSalary, double projectContributionTotal, double collectionContributionTotal, double totalContributionAmount
});


@override $MyContributionUserCopyWith<$Res> get user;@override $ImamSalaryContributionSummaryCopyWith<$Res> get imamSalary;

}
/// @nodoc
class __$MyContributionSummaryCopyWithImpl<$Res>
    implements _$MyContributionSummaryCopyWith<$Res> {
  __$MyContributionSummaryCopyWithImpl(this._self, this._then);

  final _MyContributionSummary _self;
  final $Res Function(_MyContributionSummary) _then;

/// Create a copy of MyContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? imamSalary = null,Object? projectContributionTotal = null,Object? collectionContributionTotal = null,Object? totalContributionAmount = null,}) {
  return _then(_MyContributionSummary(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as MyContributionUser,imamSalary: null == imamSalary ? _self.imamSalary : imamSalary // ignore: cast_nullable_to_non_nullable
as ImamSalaryContributionSummary,projectContributionTotal: null == projectContributionTotal ? _self.projectContributionTotal : projectContributionTotal // ignore: cast_nullable_to_non_nullable
as double,collectionContributionTotal: null == collectionContributionTotal ? _self.collectionContributionTotal : collectionContributionTotal // ignore: cast_nullable_to_non_nullable
as double,totalContributionAmount: null == totalContributionAmount ? _self.totalContributionAmount : totalContributionAmount // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of MyContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MyContributionUserCopyWith<$Res> get user {
  
  return $MyContributionUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of MyContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImamSalaryContributionSummaryCopyWith<$Res> get imamSalary {
  
  return $ImamSalaryContributionSummaryCopyWith<$Res>(_self.imamSalary, (value) {
    return _then(_self.copyWith(imamSalary: value));
  });
}
}


/// @nodoc
mixin _$MyContributionUser {

 String get id; String get fullName; String? get phone; bool get isFamilyHead;
/// Create a copy of MyContributionUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyContributionUserCopyWith<MyContributionUser> get copyWith => _$MyContributionUserCopyWithImpl<MyContributionUser>(this as MyContributionUser, _$identity);

  /// Serializes this MyContributionUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyContributionUser&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isFamilyHead, isFamilyHead) || other.isFamilyHead == isFamilyHead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,isFamilyHead);

@override
String toString() {
  return 'MyContributionUser(id: $id, fullName: $fullName, phone: $phone, isFamilyHead: $isFamilyHead)';
}


}

/// @nodoc
abstract mixin class $MyContributionUserCopyWith<$Res>  {
  factory $MyContributionUserCopyWith(MyContributionUser value, $Res Function(MyContributionUser) _then) = _$MyContributionUserCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? phone, bool isFamilyHead
});




}
/// @nodoc
class _$MyContributionUserCopyWithImpl<$Res>
    implements $MyContributionUserCopyWith<$Res> {
  _$MyContributionUserCopyWithImpl(this._self, this._then);

  final MyContributionUser _self;
  final $Res Function(MyContributionUser) _then;

/// Create a copy of MyContributionUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phone = freezed,Object? isFamilyHead = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isFamilyHead: null == isFamilyHead ? _self.isFamilyHead : isFamilyHead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MyContributionUser].
extension MyContributionUserPatterns on MyContributionUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyContributionUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyContributionUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyContributionUser value)  $default,){
final _that = this;
switch (_that) {
case _MyContributionUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyContributionUser value)?  $default,){
final _that = this;
switch (_that) {
case _MyContributionUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? phone,  bool isFamilyHead)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyContributionUser() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.isFamilyHead);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? phone,  bool isFamilyHead)  $default,) {final _that = this;
switch (_that) {
case _MyContributionUser():
return $default(_that.id,_that.fullName,_that.phone,_that.isFamilyHead);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? phone,  bool isFamilyHead)?  $default,) {final _that = this;
switch (_that) {
case _MyContributionUser() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.isFamilyHead);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyContributionUser implements MyContributionUser {
  const _MyContributionUser({required this.id, this.fullName = '', this.phone, this.isFamilyHead = false});
  factory _MyContributionUser.fromJson(Map<String, dynamic> json) => _$MyContributionUserFromJson(json);

@override final  String id;
@override@JsonKey() final  String fullName;
@override final  String? phone;
@override@JsonKey() final  bool isFamilyHead;

/// Create a copy of MyContributionUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyContributionUserCopyWith<_MyContributionUser> get copyWith => __$MyContributionUserCopyWithImpl<_MyContributionUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyContributionUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyContributionUser&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isFamilyHead, isFamilyHead) || other.isFamilyHead == isFamilyHead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,isFamilyHead);

@override
String toString() {
  return 'MyContributionUser(id: $id, fullName: $fullName, phone: $phone, isFamilyHead: $isFamilyHead)';
}


}

/// @nodoc
abstract mixin class _$MyContributionUserCopyWith<$Res> implements $MyContributionUserCopyWith<$Res> {
  factory _$MyContributionUserCopyWith(_MyContributionUser value, $Res Function(_MyContributionUser) _then) = __$MyContributionUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? phone, bool isFamilyHead
});




}
/// @nodoc
class __$MyContributionUserCopyWithImpl<$Res>
    implements _$MyContributionUserCopyWith<$Res> {
  __$MyContributionUserCopyWithImpl(this._self, this._then);

  final _MyContributionUser _self;
  final $Res Function(_MyContributionUser) _then;

/// Create a copy of MyContributionUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phone = freezed,Object? isFamilyHead = null,}) {
  return _then(_MyContributionUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isFamilyHead: null == isFamilyHead ? _self.isFamilyHead : isFamilyHead // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ImamSalaryContributionSummary {

 int get monthsShown; double get totalExpected; double get totalPaid; double get totalDue; int get paidMonths; int get partialMonths; int get unpaidMonths;/// This month's salary for this person (India time), or null when the
/// committee has not opened this month yet.
 MySalaryThisMonth? get currentMonth;
/// Create a copy of ImamSalaryContributionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImamSalaryContributionSummaryCopyWith<ImamSalaryContributionSummary> get copyWith => _$ImamSalaryContributionSummaryCopyWithImpl<ImamSalaryContributionSummary>(this as ImamSalaryContributionSummary, _$identity);

  /// Serializes this ImamSalaryContributionSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImamSalaryContributionSummary&&(identical(other.monthsShown, monthsShown) || other.monthsShown == monthsShown)&&(identical(other.totalExpected, totalExpected) || other.totalExpected == totalExpected)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.totalDue, totalDue) || other.totalDue == totalDue)&&(identical(other.paidMonths, paidMonths) || other.paidMonths == paidMonths)&&(identical(other.partialMonths, partialMonths) || other.partialMonths == partialMonths)&&(identical(other.unpaidMonths, unpaidMonths) || other.unpaidMonths == unpaidMonths)&&(identical(other.currentMonth, currentMonth) || other.currentMonth == currentMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,monthsShown,totalExpected,totalPaid,totalDue,paidMonths,partialMonths,unpaidMonths,currentMonth);

@override
String toString() {
  return 'ImamSalaryContributionSummary(monthsShown: $monthsShown, totalExpected: $totalExpected, totalPaid: $totalPaid, totalDue: $totalDue, paidMonths: $paidMonths, partialMonths: $partialMonths, unpaidMonths: $unpaidMonths, currentMonth: $currentMonth)';
}


}

/// @nodoc
abstract mixin class $ImamSalaryContributionSummaryCopyWith<$Res>  {
  factory $ImamSalaryContributionSummaryCopyWith(ImamSalaryContributionSummary value, $Res Function(ImamSalaryContributionSummary) _then) = _$ImamSalaryContributionSummaryCopyWithImpl;
@useResult
$Res call({
 int monthsShown, double totalExpected, double totalPaid, double totalDue, int paidMonths, int partialMonths, int unpaidMonths, MySalaryThisMonth? currentMonth
});


$MySalaryThisMonthCopyWith<$Res>? get currentMonth;

}
/// @nodoc
class _$ImamSalaryContributionSummaryCopyWithImpl<$Res>
    implements $ImamSalaryContributionSummaryCopyWith<$Res> {
  _$ImamSalaryContributionSummaryCopyWithImpl(this._self, this._then);

  final ImamSalaryContributionSummary _self;
  final $Res Function(ImamSalaryContributionSummary) _then;

/// Create a copy of ImamSalaryContributionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthsShown = null,Object? totalExpected = null,Object? totalPaid = null,Object? totalDue = null,Object? paidMonths = null,Object? partialMonths = null,Object? unpaidMonths = null,Object? currentMonth = freezed,}) {
  return _then(_self.copyWith(
monthsShown: null == monthsShown ? _self.monthsShown : monthsShown // ignore: cast_nullable_to_non_nullable
as int,totalExpected: null == totalExpected ? _self.totalExpected : totalExpected // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,totalDue: null == totalDue ? _self.totalDue : totalDue // ignore: cast_nullable_to_non_nullable
as double,paidMonths: null == paidMonths ? _self.paidMonths : paidMonths // ignore: cast_nullable_to_non_nullable
as int,partialMonths: null == partialMonths ? _self.partialMonths : partialMonths // ignore: cast_nullable_to_non_nullable
as int,unpaidMonths: null == unpaidMonths ? _self.unpaidMonths : unpaidMonths // ignore: cast_nullable_to_non_nullable
as int,currentMonth: freezed == currentMonth ? _self.currentMonth : currentMonth // ignore: cast_nullable_to_non_nullable
as MySalaryThisMonth?,
  ));
}
/// Create a copy of ImamSalaryContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MySalaryThisMonthCopyWith<$Res>? get currentMonth {
    if (_self.currentMonth == null) {
    return null;
  }

  return $MySalaryThisMonthCopyWith<$Res>(_self.currentMonth!, (value) {
    return _then(_self.copyWith(currentMonth: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImamSalaryContributionSummary].
extension ImamSalaryContributionSummaryPatterns on ImamSalaryContributionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImamSalaryContributionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImamSalaryContributionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImamSalaryContributionSummary value)  $default,){
final _that = this;
switch (_that) {
case _ImamSalaryContributionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImamSalaryContributionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ImamSalaryContributionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int monthsShown,  double totalExpected,  double totalPaid,  double totalDue,  int paidMonths,  int partialMonths,  int unpaidMonths,  MySalaryThisMonth? currentMonth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImamSalaryContributionSummary() when $default != null:
return $default(_that.monthsShown,_that.totalExpected,_that.totalPaid,_that.totalDue,_that.paidMonths,_that.partialMonths,_that.unpaidMonths,_that.currentMonth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int monthsShown,  double totalExpected,  double totalPaid,  double totalDue,  int paidMonths,  int partialMonths,  int unpaidMonths,  MySalaryThisMonth? currentMonth)  $default,) {final _that = this;
switch (_that) {
case _ImamSalaryContributionSummary():
return $default(_that.monthsShown,_that.totalExpected,_that.totalPaid,_that.totalDue,_that.paidMonths,_that.partialMonths,_that.unpaidMonths,_that.currentMonth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int monthsShown,  double totalExpected,  double totalPaid,  double totalDue,  int paidMonths,  int partialMonths,  int unpaidMonths,  MySalaryThisMonth? currentMonth)?  $default,) {final _that = this;
switch (_that) {
case _ImamSalaryContributionSummary() when $default != null:
return $default(_that.monthsShown,_that.totalExpected,_that.totalPaid,_that.totalDue,_that.paidMonths,_that.partialMonths,_that.unpaidMonths,_that.currentMonth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImamSalaryContributionSummary implements ImamSalaryContributionSummary {
  const _ImamSalaryContributionSummary({this.monthsShown = 0, this.totalExpected = 0, this.totalPaid = 0, this.totalDue = 0, this.paidMonths = 0, this.partialMonths = 0, this.unpaidMonths = 0, this.currentMonth});
  factory _ImamSalaryContributionSummary.fromJson(Map<String, dynamic> json) => _$ImamSalaryContributionSummaryFromJson(json);

@override@JsonKey() final  int monthsShown;
@override@JsonKey() final  double totalExpected;
@override@JsonKey() final  double totalPaid;
@override@JsonKey() final  double totalDue;
@override@JsonKey() final  int paidMonths;
@override@JsonKey() final  int partialMonths;
@override@JsonKey() final  int unpaidMonths;
/// This month's salary for this person (India time), or null when the
/// committee has not opened this month yet.
@override final  MySalaryThisMonth? currentMonth;

/// Create a copy of ImamSalaryContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImamSalaryContributionSummaryCopyWith<_ImamSalaryContributionSummary> get copyWith => __$ImamSalaryContributionSummaryCopyWithImpl<_ImamSalaryContributionSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImamSalaryContributionSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImamSalaryContributionSummary&&(identical(other.monthsShown, monthsShown) || other.monthsShown == monthsShown)&&(identical(other.totalExpected, totalExpected) || other.totalExpected == totalExpected)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.totalDue, totalDue) || other.totalDue == totalDue)&&(identical(other.paidMonths, paidMonths) || other.paidMonths == paidMonths)&&(identical(other.partialMonths, partialMonths) || other.partialMonths == partialMonths)&&(identical(other.unpaidMonths, unpaidMonths) || other.unpaidMonths == unpaidMonths)&&(identical(other.currentMonth, currentMonth) || other.currentMonth == currentMonth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,monthsShown,totalExpected,totalPaid,totalDue,paidMonths,partialMonths,unpaidMonths,currentMonth);

@override
String toString() {
  return 'ImamSalaryContributionSummary(monthsShown: $monthsShown, totalExpected: $totalExpected, totalPaid: $totalPaid, totalDue: $totalDue, paidMonths: $paidMonths, partialMonths: $partialMonths, unpaidMonths: $unpaidMonths, currentMonth: $currentMonth)';
}


}

/// @nodoc
abstract mixin class _$ImamSalaryContributionSummaryCopyWith<$Res> implements $ImamSalaryContributionSummaryCopyWith<$Res> {
  factory _$ImamSalaryContributionSummaryCopyWith(_ImamSalaryContributionSummary value, $Res Function(_ImamSalaryContributionSummary) _then) = __$ImamSalaryContributionSummaryCopyWithImpl;
@override @useResult
$Res call({
 int monthsShown, double totalExpected, double totalPaid, double totalDue, int paidMonths, int partialMonths, int unpaidMonths, MySalaryThisMonth? currentMonth
});


@override $MySalaryThisMonthCopyWith<$Res>? get currentMonth;

}
/// @nodoc
class __$ImamSalaryContributionSummaryCopyWithImpl<$Res>
    implements _$ImamSalaryContributionSummaryCopyWith<$Res> {
  __$ImamSalaryContributionSummaryCopyWithImpl(this._self, this._then);

  final _ImamSalaryContributionSummary _self;
  final $Res Function(_ImamSalaryContributionSummary) _then;

/// Create a copy of ImamSalaryContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthsShown = null,Object? totalExpected = null,Object? totalPaid = null,Object? totalDue = null,Object? paidMonths = null,Object? partialMonths = null,Object? unpaidMonths = null,Object? currentMonth = freezed,}) {
  return _then(_ImamSalaryContributionSummary(
monthsShown: null == monthsShown ? _self.monthsShown : monthsShown // ignore: cast_nullable_to_non_nullable
as int,totalExpected: null == totalExpected ? _self.totalExpected : totalExpected // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,totalDue: null == totalDue ? _self.totalDue : totalDue // ignore: cast_nullable_to_non_nullable
as double,paidMonths: null == paidMonths ? _self.paidMonths : paidMonths // ignore: cast_nullable_to_non_nullable
as int,partialMonths: null == partialMonths ? _self.partialMonths : partialMonths // ignore: cast_nullable_to_non_nullable
as int,unpaidMonths: null == unpaidMonths ? _self.unpaidMonths : unpaidMonths // ignore: cast_nullable_to_non_nullable
as int,currentMonth: freezed == currentMonth ? _self.currentMonth : currentMonth // ignore: cast_nullable_to_non_nullable
as MySalaryThisMonth?,
  ));
}

/// Create a copy of ImamSalaryContributionSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MySalaryThisMonthCopyWith<$Res>? get currentMonth {
    if (_self.currentMonth == null) {
    return null;
  }

  return $MySalaryThisMonthCopyWith<$Res>(_self.currentMonth!, (value) {
    return _then(_self.copyWith(currentMonth: value));
  });
}
}


/// @nodoc
mixin _$MySalaryThisMonth {

 int get month; int get year; double get expectedAmount; double get paidAmount; double get dueAmount; String get status;
/// Create a copy of MySalaryThisMonth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MySalaryThisMonthCopyWith<MySalaryThisMonth> get copyWith => _$MySalaryThisMonthCopyWithImpl<MySalaryThisMonth>(this as MySalaryThisMonth, _$identity);

  /// Serializes this MySalaryThisMonth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MySalaryThisMonth&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueAmount, dueAmount) || other.dueAmount == dueAmount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,expectedAmount,paidAmount,dueAmount,status);

@override
String toString() {
  return 'MySalaryThisMonth(month: $month, year: $year, expectedAmount: $expectedAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, status: $status)';
}


}

/// @nodoc
abstract mixin class $MySalaryThisMonthCopyWith<$Res>  {
  factory $MySalaryThisMonthCopyWith(MySalaryThisMonth value, $Res Function(MySalaryThisMonth) _then) = _$MySalaryThisMonthCopyWithImpl;
@useResult
$Res call({
 int month, int year, double expectedAmount, double paidAmount, double dueAmount, String status
});




}
/// @nodoc
class _$MySalaryThisMonthCopyWithImpl<$Res>
    implements $MySalaryThisMonthCopyWith<$Res> {
  _$MySalaryThisMonthCopyWithImpl(this._self, this._then);

  final MySalaryThisMonth _self;
  final $Res Function(MySalaryThisMonth) _then;

/// Create a copy of MySalaryThisMonth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? year = null,Object? expectedAmount = null,Object? paidAmount = null,Object? dueAmount = null,Object? status = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,dueAmount: null == dueAmount ? _self.dueAmount : dueAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MySalaryThisMonth].
extension MySalaryThisMonthPatterns on MySalaryThisMonth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MySalaryThisMonth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MySalaryThisMonth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MySalaryThisMonth value)  $default,){
final _that = this;
switch (_that) {
case _MySalaryThisMonth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MySalaryThisMonth value)?  $default,){
final _that = this;
switch (_that) {
case _MySalaryThisMonth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int month,  int year,  double expectedAmount,  double paidAmount,  double dueAmount,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MySalaryThisMonth() when $default != null:
return $default(_that.month,_that.year,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int month,  int year,  double expectedAmount,  double paidAmount,  double dueAmount,  String status)  $default,) {final _that = this;
switch (_that) {
case _MySalaryThisMonth():
return $default(_that.month,_that.year,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int month,  int year,  double expectedAmount,  double paidAmount,  double dueAmount,  String status)?  $default,) {final _that = this;
switch (_that) {
case _MySalaryThisMonth() when $default != null:
return $default(_that.month,_that.year,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MySalaryThisMonth implements MySalaryThisMonth {
  const _MySalaryThisMonth({required this.month, required this.year, this.expectedAmount = 0, this.paidAmount = 0, this.dueAmount = 0, this.status = 'UNPAID'});
  factory _MySalaryThisMonth.fromJson(Map<String, dynamic> json) => _$MySalaryThisMonthFromJson(json);

@override final  int month;
@override final  int year;
@override@JsonKey() final  double expectedAmount;
@override@JsonKey() final  double paidAmount;
@override@JsonKey() final  double dueAmount;
@override@JsonKey() final  String status;

/// Create a copy of MySalaryThisMonth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MySalaryThisMonthCopyWith<_MySalaryThisMonth> get copyWith => __$MySalaryThisMonthCopyWithImpl<_MySalaryThisMonth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MySalaryThisMonthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MySalaryThisMonth&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueAmount, dueAmount) || other.dueAmount == dueAmount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,expectedAmount,paidAmount,dueAmount,status);

@override
String toString() {
  return 'MySalaryThisMonth(month: $month, year: $year, expectedAmount: $expectedAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MySalaryThisMonthCopyWith<$Res> implements $MySalaryThisMonthCopyWith<$Res> {
  factory _$MySalaryThisMonthCopyWith(_MySalaryThisMonth value, $Res Function(_MySalaryThisMonth) _then) = __$MySalaryThisMonthCopyWithImpl;
@override @useResult
$Res call({
 int month, int year, double expectedAmount, double paidAmount, double dueAmount, String status
});




}
/// @nodoc
class __$MySalaryThisMonthCopyWithImpl<$Res>
    implements _$MySalaryThisMonthCopyWith<$Res> {
  __$MySalaryThisMonthCopyWithImpl(this._self, this._then);

  final _MySalaryThisMonth _self;
  final $Res Function(_MySalaryThisMonth) _then;

/// Create a copy of MySalaryThisMonth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? year = null,Object? expectedAmount = null,Object? paidAmount = null,Object? dueAmount = null,Object? status = null,}) {
  return _then(_MySalaryThisMonth(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,dueAmount: null == dueAmount ? _self.dueAmount : dueAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
