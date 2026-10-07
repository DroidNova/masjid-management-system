// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_contribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CollectionContribution {

 String get id; String get collectionType; String get contributorName; String? get contributorPhone; double get amount; String get paymentMode; DateTime? get paidAt; String get collectedByName; String? get note;
/// Create a copy of CollectionContribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionContributionCopyWith<CollectionContribution> get copyWith => _$CollectionContributionCopyWithImpl<CollectionContribution>(this as CollectionContribution, _$identity);

  /// Serializes this CollectionContribution to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.contributorName, contributorName) || other.contributorName == contributorName)&&(identical(other.contributorPhone, contributorPhone) || other.contributorPhone == contributorPhone)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.collectedByName, collectedByName) || other.collectedByName == collectedByName)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,collectionType,contributorName,contributorPhone,amount,paymentMode,paidAt,collectedByName,note);

@override
String toString() {
  return 'CollectionContribution(id: $id, collectionType: $collectionType, contributorName: $contributorName, contributorPhone: $contributorPhone, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, collectedByName: $collectedByName, note: $note)';
}


}

/// @nodoc
abstract mixin class $CollectionContributionCopyWith<$Res>  {
  factory $CollectionContributionCopyWith(CollectionContribution value, $Res Function(CollectionContribution) _then) = _$CollectionContributionCopyWithImpl;
@useResult
$Res call({
 String id, String collectionType, String contributorName, String? contributorPhone, double amount, String paymentMode, DateTime? paidAt, String collectedByName, String? note
});




}
/// @nodoc
class _$CollectionContributionCopyWithImpl<$Res>
    implements $CollectionContributionCopyWith<$Res> {
  _$CollectionContributionCopyWithImpl(this._self, this._then);

  final CollectionContribution _self;
  final $Res Function(CollectionContribution) _then;

/// Create a copy of CollectionContribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? collectionType = null,Object? contributorName = null,Object? contributorPhone = freezed,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? collectedByName = null,Object? note = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,collectionType: null == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String,contributorName: null == contributorName ? _self.contributorName : contributorName // ignore: cast_nullable_to_non_nullable
as String,contributorPhone: freezed == contributorPhone ? _self.contributorPhone : contributorPhone // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,collectedByName: null == collectedByName ? _self.collectedByName : collectedByName // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionContribution].
extension CollectionContributionPatterns on CollectionContribution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionContribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionContribution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionContribution value)  $default,){
final _that = this;
switch (_that) {
case _CollectionContribution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionContribution value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionContribution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String collectionType,  String contributorName,  String? contributorPhone,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionContribution() when $default != null:
return $default(_that.id,_that.collectionType,_that.contributorName,_that.contributorPhone,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String collectionType,  String contributorName,  String? contributorPhone,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CollectionContribution():
return $default(_that.id,_that.collectionType,_that.contributorName,_that.contributorPhone,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String collectionType,  String contributorName,  String? contributorPhone,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CollectionContribution() when $default != null:
return $default(_that.id,_that.collectionType,_that.contributorName,_that.contributorPhone,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionContribution implements CollectionContribution {
  const _CollectionContribution({required this.id, this.collectionType = '', this.contributorName = '', this.contributorPhone, this.amount = 0, this.paymentMode = '', this.paidAt, this.collectedByName = '', this.note});
  factory _CollectionContribution.fromJson(Map<String, dynamic> json) => _$CollectionContributionFromJson(json);

@override final  String id;
@override@JsonKey() final  String collectionType;
@override@JsonKey() final  String contributorName;
@override final  String? contributorPhone;
@override@JsonKey() final  double amount;
@override@JsonKey() final  String paymentMode;
@override final  DateTime? paidAt;
@override@JsonKey() final  String collectedByName;
@override final  String? note;

/// Create a copy of CollectionContribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionContributionCopyWith<_CollectionContribution> get copyWith => __$CollectionContributionCopyWithImpl<_CollectionContribution>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionContributionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.contributorName, contributorName) || other.contributorName == contributorName)&&(identical(other.contributorPhone, contributorPhone) || other.contributorPhone == contributorPhone)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.collectedByName, collectedByName) || other.collectedByName == collectedByName)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,collectionType,contributorName,contributorPhone,amount,paymentMode,paidAt,collectedByName,note);

@override
String toString() {
  return 'CollectionContribution(id: $id, collectionType: $collectionType, contributorName: $contributorName, contributorPhone: $contributorPhone, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, collectedByName: $collectedByName, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CollectionContributionCopyWith<$Res> implements $CollectionContributionCopyWith<$Res> {
  factory _$CollectionContributionCopyWith(_CollectionContribution value, $Res Function(_CollectionContribution) _then) = __$CollectionContributionCopyWithImpl;
@override @useResult
$Res call({
 String id, String collectionType, String contributorName, String? contributorPhone, double amount, String paymentMode, DateTime? paidAt, String collectedByName, String? note
});




}
/// @nodoc
class __$CollectionContributionCopyWithImpl<$Res>
    implements _$CollectionContributionCopyWith<$Res> {
  __$CollectionContributionCopyWithImpl(this._self, this._then);

  final _CollectionContribution _self;
  final $Res Function(_CollectionContribution) _then;

/// Create a copy of CollectionContribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? collectionType = null,Object? contributorName = null,Object? contributorPhone = freezed,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? collectedByName = null,Object? note = freezed,}) {
  return _then(_CollectionContribution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,collectionType: null == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String,contributorName: null == contributorName ? _self.contributorName : contributorName // ignore: cast_nullable_to_non_nullable
as String,contributorPhone: freezed == contributorPhone ? _self.contributorPhone : contributorPhone // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,collectedByName: null == collectedByName ? _self.collectedByName : collectedByName // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
