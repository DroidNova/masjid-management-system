// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'imam_salary_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImamSalaryMonth {

 String get id; int get month; int get year; double get amountPerHead; double get totalExpected; double get totalCollected; double get totalDue; int get paidCount; int get partialCount; int get unpaidCount; String get status; String? get note;
/// Create a copy of ImamSalaryMonth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImamSalaryMonthCopyWith<ImamSalaryMonth> get copyWith => _$ImamSalaryMonthCopyWithImpl<ImamSalaryMonth>(this as ImamSalaryMonth, _$identity);

  /// Serializes this ImamSalaryMonth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImamSalaryMonth&&(identical(other.id, id) || other.id == id)&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.amountPerHead, amountPerHead) || other.amountPerHead == amountPerHead)&&(identical(other.totalExpected, totalExpected) || other.totalExpected == totalExpected)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.totalDue, totalDue) || other.totalDue == totalDue)&&(identical(other.paidCount, paidCount) || other.paidCount == paidCount)&&(identical(other.partialCount, partialCount) || other.partialCount == partialCount)&&(identical(other.unpaidCount, unpaidCount) || other.unpaidCount == unpaidCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,month,year,amountPerHead,totalExpected,totalCollected,totalDue,paidCount,partialCount,unpaidCount,status,note);

@override
String toString() {
  return 'ImamSalaryMonth(id: $id, month: $month, year: $year, amountPerHead: $amountPerHead, totalExpected: $totalExpected, totalCollected: $totalCollected, totalDue: $totalDue, paidCount: $paidCount, partialCount: $partialCount, unpaidCount: $unpaidCount, status: $status, note: $note)';
}


}

/// @nodoc
abstract mixin class $ImamSalaryMonthCopyWith<$Res>  {
  factory $ImamSalaryMonthCopyWith(ImamSalaryMonth value, $Res Function(ImamSalaryMonth) _then) = _$ImamSalaryMonthCopyWithImpl;
@useResult
$Res call({
 String id, int month, int year, double amountPerHead, double totalExpected, double totalCollected, double totalDue, int paidCount, int partialCount, int unpaidCount, String status, String? note
});




}
/// @nodoc
class _$ImamSalaryMonthCopyWithImpl<$Res>
    implements $ImamSalaryMonthCopyWith<$Res> {
  _$ImamSalaryMonthCopyWithImpl(this._self, this._then);

  final ImamSalaryMonth _self;
  final $Res Function(ImamSalaryMonth) _then;

/// Create a copy of ImamSalaryMonth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? month = null,Object? year = null,Object? amountPerHead = null,Object? totalExpected = null,Object? totalCollected = null,Object? totalDue = null,Object? paidCount = null,Object? partialCount = null,Object? unpaidCount = null,Object? status = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,amountPerHead: null == amountPerHead ? _self.amountPerHead : amountPerHead // ignore: cast_nullable_to_non_nullable
as double,totalExpected: null == totalExpected ? _self.totalExpected : totalExpected // ignore: cast_nullable_to_non_nullable
as double,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,totalDue: null == totalDue ? _self.totalDue : totalDue // ignore: cast_nullable_to_non_nullable
as double,paidCount: null == paidCount ? _self.paidCount : paidCount // ignore: cast_nullable_to_non_nullable
as int,partialCount: null == partialCount ? _self.partialCount : partialCount // ignore: cast_nullable_to_non_nullable
as int,unpaidCount: null == unpaidCount ? _self.unpaidCount : unpaidCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImamSalaryMonth].
extension ImamSalaryMonthPatterns on ImamSalaryMonth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImamSalaryMonth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImamSalaryMonth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImamSalaryMonth value)  $default,){
final _that = this;
switch (_that) {
case _ImamSalaryMonth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImamSalaryMonth value)?  $default,){
final _that = this;
switch (_that) {
case _ImamSalaryMonth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int month,  int year,  double amountPerHead,  double totalExpected,  double totalCollected,  double totalDue,  int paidCount,  int partialCount,  int unpaidCount,  String status,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImamSalaryMonth() when $default != null:
return $default(_that.id,_that.month,_that.year,_that.amountPerHead,_that.totalExpected,_that.totalCollected,_that.totalDue,_that.paidCount,_that.partialCount,_that.unpaidCount,_that.status,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int month,  int year,  double amountPerHead,  double totalExpected,  double totalCollected,  double totalDue,  int paidCount,  int partialCount,  int unpaidCount,  String status,  String? note)  $default,) {final _that = this;
switch (_that) {
case _ImamSalaryMonth():
return $default(_that.id,_that.month,_that.year,_that.amountPerHead,_that.totalExpected,_that.totalCollected,_that.totalDue,_that.paidCount,_that.partialCount,_that.unpaidCount,_that.status,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int month,  int year,  double amountPerHead,  double totalExpected,  double totalCollected,  double totalDue,  int paidCount,  int partialCount,  int unpaidCount,  String status,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _ImamSalaryMonth() when $default != null:
return $default(_that.id,_that.month,_that.year,_that.amountPerHead,_that.totalExpected,_that.totalCollected,_that.totalDue,_that.paidCount,_that.partialCount,_that.unpaidCount,_that.status,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImamSalaryMonth implements ImamSalaryMonth {
  const _ImamSalaryMonth({required this.id, required this.month, required this.year, this.amountPerHead = 0, this.totalExpected = 0, this.totalCollected = 0, this.totalDue = 0, this.paidCount = 0, this.partialCount = 0, this.unpaidCount = 0, this.status = SalaryStatus.unpaid, this.note});
  factory _ImamSalaryMonth.fromJson(Map<String, dynamic> json) => _$ImamSalaryMonthFromJson(json);

@override final  String id;
@override final  int month;
@override final  int year;
@override@JsonKey() final  double amountPerHead;
@override@JsonKey() final  double totalExpected;
@override@JsonKey() final  double totalCollected;
@override@JsonKey() final  double totalDue;
@override@JsonKey() final  int paidCount;
@override@JsonKey() final  int partialCount;
@override@JsonKey() final  int unpaidCount;
@override@JsonKey() final  String status;
@override final  String? note;

/// Create a copy of ImamSalaryMonth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImamSalaryMonthCopyWith<_ImamSalaryMonth> get copyWith => __$ImamSalaryMonthCopyWithImpl<_ImamSalaryMonth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImamSalaryMonthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImamSalaryMonth&&(identical(other.id, id) || other.id == id)&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.amountPerHead, amountPerHead) || other.amountPerHead == amountPerHead)&&(identical(other.totalExpected, totalExpected) || other.totalExpected == totalExpected)&&(identical(other.totalCollected, totalCollected) || other.totalCollected == totalCollected)&&(identical(other.totalDue, totalDue) || other.totalDue == totalDue)&&(identical(other.paidCount, paidCount) || other.paidCount == paidCount)&&(identical(other.partialCount, partialCount) || other.partialCount == partialCount)&&(identical(other.unpaidCount, unpaidCount) || other.unpaidCount == unpaidCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,month,year,amountPerHead,totalExpected,totalCollected,totalDue,paidCount,partialCount,unpaidCount,status,note);

@override
String toString() {
  return 'ImamSalaryMonth(id: $id, month: $month, year: $year, amountPerHead: $amountPerHead, totalExpected: $totalExpected, totalCollected: $totalCollected, totalDue: $totalDue, paidCount: $paidCount, partialCount: $partialCount, unpaidCount: $unpaidCount, status: $status, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ImamSalaryMonthCopyWith<$Res> implements $ImamSalaryMonthCopyWith<$Res> {
  factory _$ImamSalaryMonthCopyWith(_ImamSalaryMonth value, $Res Function(_ImamSalaryMonth) _then) = __$ImamSalaryMonthCopyWithImpl;
@override @useResult
$Res call({
 String id, int month, int year, double amountPerHead, double totalExpected, double totalCollected, double totalDue, int paidCount, int partialCount, int unpaidCount, String status, String? note
});




}
/// @nodoc
class __$ImamSalaryMonthCopyWithImpl<$Res>
    implements _$ImamSalaryMonthCopyWith<$Res> {
  __$ImamSalaryMonthCopyWithImpl(this._self, this._then);

  final _ImamSalaryMonth _self;
  final $Res Function(_ImamSalaryMonth) _then;

/// Create a copy of ImamSalaryMonth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? month = null,Object? year = null,Object? amountPerHead = null,Object? totalExpected = null,Object? totalCollected = null,Object? totalDue = null,Object? paidCount = null,Object? partialCount = null,Object? unpaidCount = null,Object? status = null,Object? note = freezed,}) {
  return _then(_ImamSalaryMonth(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,amountPerHead: null == amountPerHead ? _self.amountPerHead : amountPerHead // ignore: cast_nullable_to_non_nullable
as double,totalExpected: null == totalExpected ? _self.totalExpected : totalExpected // ignore: cast_nullable_to_non_nullable
as double,totalCollected: null == totalCollected ? _self.totalCollected : totalCollected // ignore: cast_nullable_to_non_nullable
as double,totalDue: null == totalDue ? _self.totalDue : totalDue // ignore: cast_nullable_to_non_nullable
as double,paidCount: null == paidCount ? _self.paidCount : paidCount // ignore: cast_nullable_to_non_nullable
as int,partialCount: null == partialCount ? _self.partialCount : partialCount // ignore: cast_nullable_to_non_nullable
as int,unpaidCount: null == unpaidCount ? _self.unpaidCount : unpaidCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SalaryAssignment {

 String get id; String get memberId; String get memberName; String get memberPhone; double get expectedAmount; double get paidAmount; double get dueAmount; String get status;
/// Create a copy of SalaryAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalaryAssignmentCopyWith<SalaryAssignment> get copyWith => _$SalaryAssignmentCopyWithImpl<SalaryAssignment>(this as SalaryAssignment, _$identity);

  /// Serializes this SalaryAssignment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalaryAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberPhone, memberPhone) || other.memberPhone == memberPhone)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueAmount, dueAmount) || other.dueAmount == dueAmount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,memberPhone,expectedAmount,paidAmount,dueAmount,status);

@override
String toString() {
  return 'SalaryAssignment(id: $id, memberId: $memberId, memberName: $memberName, memberPhone: $memberPhone, expectedAmount: $expectedAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, status: $status)';
}


}

/// @nodoc
abstract mixin class $SalaryAssignmentCopyWith<$Res>  {
  factory $SalaryAssignmentCopyWith(SalaryAssignment value, $Res Function(SalaryAssignment) _then) = _$SalaryAssignmentCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String memberName, String memberPhone, double expectedAmount, double paidAmount, double dueAmount, String status
});




}
/// @nodoc
class _$SalaryAssignmentCopyWithImpl<$Res>
    implements $SalaryAssignmentCopyWith<$Res> {
  _$SalaryAssignmentCopyWithImpl(this._self, this._then);

  final SalaryAssignment _self;
  final $Res Function(SalaryAssignment) _then;

/// Create a copy of SalaryAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? memberPhone = null,Object? expectedAmount = null,Object? paidAmount = null,Object? dueAmount = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberPhone: null == memberPhone ? _self.memberPhone : memberPhone // ignore: cast_nullable_to_non_nullable
as String,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,dueAmount: null == dueAmount ? _self.dueAmount : dueAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SalaryAssignment].
extension SalaryAssignmentPatterns on SalaryAssignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalaryAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalaryAssignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalaryAssignment value)  $default,){
final _that = this;
switch (_that) {
case _SalaryAssignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalaryAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _SalaryAssignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  String memberPhone,  double expectedAmount,  double paidAmount,  double dueAmount,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalaryAssignment() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.memberPhone,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  String memberPhone,  double expectedAmount,  double paidAmount,  double dueAmount,  String status)  $default,) {final _that = this;
switch (_that) {
case _SalaryAssignment():
return $default(_that.id,_that.memberId,_that.memberName,_that.memberPhone,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String memberName,  String memberPhone,  double expectedAmount,  double paidAmount,  double dueAmount,  String status)?  $default,) {final _that = this;
switch (_that) {
case _SalaryAssignment() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.memberPhone,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalaryAssignment implements SalaryAssignment {
  const _SalaryAssignment({required this.id, this.memberId = '', this.memberName = '', this.memberPhone = '', this.expectedAmount = 0, this.paidAmount = 0, this.dueAmount = 0, this.status = SalaryStatus.unpaid});
  factory _SalaryAssignment.fromJson(Map<String, dynamic> json) => _$SalaryAssignmentFromJson(json);

@override final  String id;
@override@JsonKey() final  String memberId;
@override@JsonKey() final  String memberName;
@override@JsonKey() final  String memberPhone;
@override@JsonKey() final  double expectedAmount;
@override@JsonKey() final  double paidAmount;
@override@JsonKey() final  double dueAmount;
@override@JsonKey() final  String status;

/// Create a copy of SalaryAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalaryAssignmentCopyWith<_SalaryAssignment> get copyWith => __$SalaryAssignmentCopyWithImpl<_SalaryAssignment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalaryAssignmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalaryAssignment&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberPhone, memberPhone) || other.memberPhone == memberPhone)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueAmount, dueAmount) || other.dueAmount == dueAmount)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,memberPhone,expectedAmount,paidAmount,dueAmount,status);

@override
String toString() {
  return 'SalaryAssignment(id: $id, memberId: $memberId, memberName: $memberName, memberPhone: $memberPhone, expectedAmount: $expectedAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SalaryAssignmentCopyWith<$Res> implements $SalaryAssignmentCopyWith<$Res> {
  factory _$SalaryAssignmentCopyWith(_SalaryAssignment value, $Res Function(_SalaryAssignment) _then) = __$SalaryAssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String memberName, String memberPhone, double expectedAmount, double paidAmount, double dueAmount, String status
});




}
/// @nodoc
class __$SalaryAssignmentCopyWithImpl<$Res>
    implements _$SalaryAssignmentCopyWith<$Res> {
  __$SalaryAssignmentCopyWithImpl(this._self, this._then);

  final _SalaryAssignment _self;
  final $Res Function(_SalaryAssignment) _then;

/// Create a copy of SalaryAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? memberPhone = null,Object? expectedAmount = null,Object? paidAmount = null,Object? dueAmount = null,Object? status = null,}) {
  return _then(_SalaryAssignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberPhone: null == memberPhone ? _self.memberPhone : memberPhone // ignore: cast_nullable_to_non_nullable
as String,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,dueAmount: null == dueAmount ? _self.dueAmount : dueAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SalaryPayment {

 String get id; String get memberId; String get memberName; String get memberPhone; double get amount; String get paymentMode; DateTime? get paidAt; String get collectedByName; String? get note; int get paymentForMonth; int get paymentForYear;
/// Create a copy of SalaryPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalaryPaymentCopyWith<SalaryPayment> get copyWith => _$SalaryPaymentCopyWithImpl<SalaryPayment>(this as SalaryPayment, _$identity);

  /// Serializes this SalaryPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalaryPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberPhone, memberPhone) || other.memberPhone == memberPhone)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.collectedByName, collectedByName) || other.collectedByName == collectedByName)&&(identical(other.note, note) || other.note == note)&&(identical(other.paymentForMonth, paymentForMonth) || other.paymentForMonth == paymentForMonth)&&(identical(other.paymentForYear, paymentForYear) || other.paymentForYear == paymentForYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,memberPhone,amount,paymentMode,paidAt,collectedByName,note,paymentForMonth,paymentForYear);

@override
String toString() {
  return 'SalaryPayment(id: $id, memberId: $memberId, memberName: $memberName, memberPhone: $memberPhone, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, collectedByName: $collectedByName, note: $note, paymentForMonth: $paymentForMonth, paymentForYear: $paymentForYear)';
}


}

/// @nodoc
abstract mixin class $SalaryPaymentCopyWith<$Res>  {
  factory $SalaryPaymentCopyWith(SalaryPayment value, $Res Function(SalaryPayment) _then) = _$SalaryPaymentCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String memberName, String memberPhone, double amount, String paymentMode, DateTime? paidAt, String collectedByName, String? note, int paymentForMonth, int paymentForYear
});




}
/// @nodoc
class _$SalaryPaymentCopyWithImpl<$Res>
    implements $SalaryPaymentCopyWith<$Res> {
  _$SalaryPaymentCopyWithImpl(this._self, this._then);

  final SalaryPayment _self;
  final $Res Function(SalaryPayment) _then;

/// Create a copy of SalaryPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? memberPhone = null,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? collectedByName = null,Object? note = freezed,Object? paymentForMonth = null,Object? paymentForYear = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberPhone: null == memberPhone ? _self.memberPhone : memberPhone // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,collectedByName: null == collectedByName ? _self.collectedByName : collectedByName // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,paymentForMonth: null == paymentForMonth ? _self.paymentForMonth : paymentForMonth // ignore: cast_nullable_to_non_nullable
as int,paymentForYear: null == paymentForYear ? _self.paymentForYear : paymentForYear // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SalaryPayment].
extension SalaryPaymentPatterns on SalaryPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalaryPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalaryPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalaryPayment value)  $default,){
final _that = this;
switch (_that) {
case _SalaryPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalaryPayment value)?  $default,){
final _that = this;
switch (_that) {
case _SalaryPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  String memberPhone,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note,  int paymentForMonth,  int paymentForYear)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalaryPayment() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.memberPhone,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note,_that.paymentForMonth,_that.paymentForYear);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  String memberPhone,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note,  int paymentForMonth,  int paymentForYear)  $default,) {final _that = this;
switch (_that) {
case _SalaryPayment():
return $default(_that.id,_that.memberId,_that.memberName,_that.memberPhone,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note,_that.paymentForMonth,_that.paymentForYear);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String memberName,  String memberPhone,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note,  int paymentForMonth,  int paymentForYear)?  $default,) {final _that = this;
switch (_that) {
case _SalaryPayment() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.memberPhone,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note,_that.paymentForMonth,_that.paymentForYear);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalaryPayment implements SalaryPayment {
  const _SalaryPayment({required this.id, this.memberId = '', this.memberName = '', this.memberPhone = '', this.amount = 0, this.paymentMode = '', this.paidAt, this.collectedByName = '', this.note, this.paymentForMonth = 0, this.paymentForYear = 0});
  factory _SalaryPayment.fromJson(Map<String, dynamic> json) => _$SalaryPaymentFromJson(json);

@override final  String id;
@override@JsonKey() final  String memberId;
@override@JsonKey() final  String memberName;
@override@JsonKey() final  String memberPhone;
@override@JsonKey() final  double amount;
@override@JsonKey() final  String paymentMode;
@override final  DateTime? paidAt;
@override@JsonKey() final  String collectedByName;
@override final  String? note;
@override@JsonKey() final  int paymentForMonth;
@override@JsonKey() final  int paymentForYear;

/// Create a copy of SalaryPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalaryPaymentCopyWith<_SalaryPayment> get copyWith => __$SalaryPaymentCopyWithImpl<_SalaryPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalaryPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalaryPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberPhone, memberPhone) || other.memberPhone == memberPhone)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.collectedByName, collectedByName) || other.collectedByName == collectedByName)&&(identical(other.note, note) || other.note == note)&&(identical(other.paymentForMonth, paymentForMonth) || other.paymentForMonth == paymentForMonth)&&(identical(other.paymentForYear, paymentForYear) || other.paymentForYear == paymentForYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,memberPhone,amount,paymentMode,paidAt,collectedByName,note,paymentForMonth,paymentForYear);

@override
String toString() {
  return 'SalaryPayment(id: $id, memberId: $memberId, memberName: $memberName, memberPhone: $memberPhone, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, collectedByName: $collectedByName, note: $note, paymentForMonth: $paymentForMonth, paymentForYear: $paymentForYear)';
}


}

/// @nodoc
abstract mixin class _$SalaryPaymentCopyWith<$Res> implements $SalaryPaymentCopyWith<$Res> {
  factory _$SalaryPaymentCopyWith(_SalaryPayment value, $Res Function(_SalaryPayment) _then) = __$SalaryPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String memberName, String memberPhone, double amount, String paymentMode, DateTime? paidAt, String collectedByName, String? note, int paymentForMonth, int paymentForYear
});




}
/// @nodoc
class __$SalaryPaymentCopyWithImpl<$Res>
    implements _$SalaryPaymentCopyWith<$Res> {
  __$SalaryPaymentCopyWithImpl(this._self, this._then);

  final _SalaryPayment _self;
  final $Res Function(_SalaryPayment) _then;

/// Create a copy of SalaryPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? memberPhone = null,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? collectedByName = null,Object? note = freezed,Object? paymentForMonth = null,Object? paymentForYear = null,}) {
  return _then(_SalaryPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberPhone: null == memberPhone ? _self.memberPhone : memberPhone // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,collectedByName: null == collectedByName ? _self.collectedByName : collectedByName // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,paymentForMonth: null == paymentForMonth ? _self.paymentForMonth : paymentForMonth // ignore: cast_nullable_to_non_nullable
as int,paymentForYear: null == paymentForYear ? _self.paymentForYear : paymentForYear // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MySalaryHistoryMonth {

 int get month; int get year; double get expectedAmount; double get paidAmount; double get dueAmount; String get status; List<MySalaryHistoryPayment> get payments;
/// Create a copy of MySalaryHistoryMonth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MySalaryHistoryMonthCopyWith<MySalaryHistoryMonth> get copyWith => _$MySalaryHistoryMonthCopyWithImpl<MySalaryHistoryMonth>(this as MySalaryHistoryMonth, _$identity);

  /// Serializes this MySalaryHistoryMonth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MySalaryHistoryMonth&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueAmount, dueAmount) || other.dueAmount == dueAmount)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.payments, payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,expectedAmount,paidAmount,dueAmount,status,const DeepCollectionEquality().hash(payments));

@override
String toString() {
  return 'MySalaryHistoryMonth(month: $month, year: $year, expectedAmount: $expectedAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, status: $status, payments: $payments)';
}


}

/// @nodoc
abstract mixin class $MySalaryHistoryMonthCopyWith<$Res>  {
  factory $MySalaryHistoryMonthCopyWith(MySalaryHistoryMonth value, $Res Function(MySalaryHistoryMonth) _then) = _$MySalaryHistoryMonthCopyWithImpl;
@useResult
$Res call({
 int month, int year, double expectedAmount, double paidAmount, double dueAmount, String status, List<MySalaryHistoryPayment> payments
});




}
/// @nodoc
class _$MySalaryHistoryMonthCopyWithImpl<$Res>
    implements $MySalaryHistoryMonthCopyWith<$Res> {
  _$MySalaryHistoryMonthCopyWithImpl(this._self, this._then);

  final MySalaryHistoryMonth _self;
  final $Res Function(MySalaryHistoryMonth) _then;

/// Create a copy of MySalaryHistoryMonth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? year = null,Object? expectedAmount = null,Object? paidAmount = null,Object? dueAmount = null,Object? status = null,Object? payments = null,}) {
  return _then(_self.copyWith(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,dueAmount: null == dueAmount ? _self.dueAmount : dueAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,payments: null == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<MySalaryHistoryPayment>,
  ));
}

}


/// Adds pattern-matching-related methods to [MySalaryHistoryMonth].
extension MySalaryHistoryMonthPatterns on MySalaryHistoryMonth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MySalaryHistoryMonth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MySalaryHistoryMonth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MySalaryHistoryMonth value)  $default,){
final _that = this;
switch (_that) {
case _MySalaryHistoryMonth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MySalaryHistoryMonth value)?  $default,){
final _that = this;
switch (_that) {
case _MySalaryHistoryMonth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int month,  int year,  double expectedAmount,  double paidAmount,  double dueAmount,  String status,  List<MySalaryHistoryPayment> payments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MySalaryHistoryMonth() when $default != null:
return $default(_that.month,_that.year,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status,_that.payments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int month,  int year,  double expectedAmount,  double paidAmount,  double dueAmount,  String status,  List<MySalaryHistoryPayment> payments)  $default,) {final _that = this;
switch (_that) {
case _MySalaryHistoryMonth():
return $default(_that.month,_that.year,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status,_that.payments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int month,  int year,  double expectedAmount,  double paidAmount,  double dueAmount,  String status,  List<MySalaryHistoryPayment> payments)?  $default,) {final _that = this;
switch (_that) {
case _MySalaryHistoryMonth() when $default != null:
return $default(_that.month,_that.year,_that.expectedAmount,_that.paidAmount,_that.dueAmount,_that.status,_that.payments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MySalaryHistoryMonth implements MySalaryHistoryMonth {
  const _MySalaryHistoryMonth({required this.month, required this.year, this.expectedAmount = 0, this.paidAmount = 0, this.dueAmount = 0, this.status = SalaryStatus.unpaid, final  List<MySalaryHistoryPayment> payments = const <MySalaryHistoryPayment>[]}): _payments = payments;
  factory _MySalaryHistoryMonth.fromJson(Map<String, dynamic> json) => _$MySalaryHistoryMonthFromJson(json);

@override final  int month;
@override final  int year;
@override@JsonKey() final  double expectedAmount;
@override@JsonKey() final  double paidAmount;
@override@JsonKey() final  double dueAmount;
@override@JsonKey() final  String status;
 final  List<MySalaryHistoryPayment> _payments;
@override@JsonKey() List<MySalaryHistoryPayment> get payments {
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_payments);
}


/// Create a copy of MySalaryHistoryMonth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MySalaryHistoryMonthCopyWith<_MySalaryHistoryMonth> get copyWith => __$MySalaryHistoryMonthCopyWithImpl<_MySalaryHistoryMonth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MySalaryHistoryMonthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MySalaryHistoryMonth&&(identical(other.month, month) || other.month == month)&&(identical(other.year, year) || other.year == year)&&(identical(other.expectedAmount, expectedAmount) || other.expectedAmount == expectedAmount)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.dueAmount, dueAmount) || other.dueAmount == dueAmount)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._payments, _payments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,month,year,expectedAmount,paidAmount,dueAmount,status,const DeepCollectionEquality().hash(_payments));

@override
String toString() {
  return 'MySalaryHistoryMonth(month: $month, year: $year, expectedAmount: $expectedAmount, paidAmount: $paidAmount, dueAmount: $dueAmount, status: $status, payments: $payments)';
}


}

/// @nodoc
abstract mixin class _$MySalaryHistoryMonthCopyWith<$Res> implements $MySalaryHistoryMonthCopyWith<$Res> {
  factory _$MySalaryHistoryMonthCopyWith(_MySalaryHistoryMonth value, $Res Function(_MySalaryHistoryMonth) _then) = __$MySalaryHistoryMonthCopyWithImpl;
@override @useResult
$Res call({
 int month, int year, double expectedAmount, double paidAmount, double dueAmount, String status, List<MySalaryHistoryPayment> payments
});




}
/// @nodoc
class __$MySalaryHistoryMonthCopyWithImpl<$Res>
    implements _$MySalaryHistoryMonthCopyWith<$Res> {
  __$MySalaryHistoryMonthCopyWithImpl(this._self, this._then);

  final _MySalaryHistoryMonth _self;
  final $Res Function(_MySalaryHistoryMonth) _then;

/// Create a copy of MySalaryHistoryMonth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? year = null,Object? expectedAmount = null,Object? paidAmount = null,Object? dueAmount = null,Object? status = null,Object? payments = null,}) {
  return _then(_MySalaryHistoryMonth(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,expectedAmount: null == expectedAmount ? _self.expectedAmount : expectedAmount // ignore: cast_nullable_to_non_nullable
as double,paidAmount: null == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double,dueAmount: null == dueAmount ? _self.dueAmount : dueAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,payments: null == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<MySalaryHistoryPayment>,
  ));
}


}


/// @nodoc
mixin _$MySalaryHistoryPayment {

 String get id; double get amount; String get paymentMode; DateTime? get paidAt; String? get note;
/// Create a copy of MySalaryHistoryPayment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MySalaryHistoryPaymentCopyWith<MySalaryHistoryPayment> get copyWith => _$MySalaryHistoryPaymentCopyWithImpl<MySalaryHistoryPayment>(this as MySalaryHistoryPayment, _$identity);

  /// Serializes this MySalaryHistoryPayment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MySalaryHistoryPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,paymentMode,paidAt,note);

@override
String toString() {
  return 'MySalaryHistoryPayment(id: $id, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, note: $note)';
}


}

/// @nodoc
abstract mixin class $MySalaryHistoryPaymentCopyWith<$Res>  {
  factory $MySalaryHistoryPaymentCopyWith(MySalaryHistoryPayment value, $Res Function(MySalaryHistoryPayment) _then) = _$MySalaryHistoryPaymentCopyWithImpl;
@useResult
$Res call({
 String id, double amount, String paymentMode, DateTime? paidAt, String? note
});




}
/// @nodoc
class _$MySalaryHistoryPaymentCopyWithImpl<$Res>
    implements $MySalaryHistoryPaymentCopyWith<$Res> {
  _$MySalaryHistoryPaymentCopyWithImpl(this._self, this._then);

  final MySalaryHistoryPayment _self;
  final $Res Function(MySalaryHistoryPayment) _then;

/// Create a copy of MySalaryHistoryPayment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MySalaryHistoryPayment].
extension MySalaryHistoryPaymentPatterns on MySalaryHistoryPayment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MySalaryHistoryPayment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MySalaryHistoryPayment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MySalaryHistoryPayment value)  $default,){
final _that = this;
switch (_that) {
case _MySalaryHistoryPayment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MySalaryHistoryPayment value)?  $default,){
final _that = this;
switch (_that) {
case _MySalaryHistoryPayment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount,  String paymentMode,  DateTime? paidAt,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MySalaryHistoryPayment() when $default != null:
return $default(_that.id,_that.amount,_that.paymentMode,_that.paidAt,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount,  String paymentMode,  DateTime? paidAt,  String? note)  $default,) {final _that = this;
switch (_that) {
case _MySalaryHistoryPayment():
return $default(_that.id,_that.amount,_that.paymentMode,_that.paidAt,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount,  String paymentMode,  DateTime? paidAt,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _MySalaryHistoryPayment() when $default != null:
return $default(_that.id,_that.amount,_that.paymentMode,_that.paidAt,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MySalaryHistoryPayment implements MySalaryHistoryPayment {
  const _MySalaryHistoryPayment({required this.id, this.amount = 0, this.paymentMode = '', this.paidAt, this.note});
  factory _MySalaryHistoryPayment.fromJson(Map<String, dynamic> json) => _$MySalaryHistoryPaymentFromJson(json);

@override final  String id;
@override@JsonKey() final  double amount;
@override@JsonKey() final  String paymentMode;
@override final  DateTime? paidAt;
@override final  String? note;

/// Create a copy of MySalaryHistoryPayment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MySalaryHistoryPaymentCopyWith<_MySalaryHistoryPayment> get copyWith => __$MySalaryHistoryPaymentCopyWithImpl<_MySalaryHistoryPayment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MySalaryHistoryPaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MySalaryHistoryPayment&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,paymentMode,paidAt,note);

@override
String toString() {
  return 'MySalaryHistoryPayment(id: $id, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, note: $note)';
}


}

/// @nodoc
abstract mixin class _$MySalaryHistoryPaymentCopyWith<$Res> implements $MySalaryHistoryPaymentCopyWith<$Res> {
  factory _$MySalaryHistoryPaymentCopyWith(_MySalaryHistoryPayment value, $Res Function(_MySalaryHistoryPayment) _then) = __$MySalaryHistoryPaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount, String paymentMode, DateTime? paidAt, String? note
});




}
/// @nodoc
class __$MySalaryHistoryPaymentCopyWithImpl<$Res>
    implements _$MySalaryHistoryPaymentCopyWith<$Res> {
  __$MySalaryHistoryPaymentCopyWithImpl(this._self, this._then);

  final _MySalaryHistoryPayment _self;
  final $Res Function(_MySalaryHistoryPayment) _then;

/// Create a copy of MySalaryHistoryPayment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? note = freezed,}) {
  return _then(_MySalaryHistoryPayment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
