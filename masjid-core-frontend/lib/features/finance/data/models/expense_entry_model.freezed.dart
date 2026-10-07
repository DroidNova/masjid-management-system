// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExpenseEntryModel {

 String get id; String get type; double get amount; String? get title; String? get description; DateTime? get spentAt;/// ACTIVE or CANCELLED.
 String get status; DateTime? get createdAt;
/// Create a copy of ExpenseEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseEntryModelCopyWith<ExpenseEntryModel> get copyWith => _$ExpenseEntryModelCopyWithImpl<ExpenseEntryModel>(this as ExpenseEntryModel, _$identity);

  /// Serializes this ExpenseEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseEntryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.spentAt, spentAt) || other.spentAt == spentAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,title,description,spentAt,status,createdAt);

@override
String toString() {
  return 'ExpenseEntryModel(id: $id, type: $type, amount: $amount, title: $title, description: $description, spentAt: $spentAt, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ExpenseEntryModelCopyWith<$Res>  {
  factory $ExpenseEntryModelCopyWith(ExpenseEntryModel value, $Res Function(ExpenseEntryModel) _then) = _$ExpenseEntryModelCopyWithImpl;
@useResult
$Res call({
 String id, String type, double amount, String? title, String? description, DateTime? spentAt, String status, DateTime? createdAt
});




}
/// @nodoc
class _$ExpenseEntryModelCopyWithImpl<$Res>
    implements $ExpenseEntryModelCopyWith<$Res> {
  _$ExpenseEntryModelCopyWithImpl(this._self, this._then);

  final ExpenseEntryModel _self;
  final $Res Function(ExpenseEntryModel) _then;

/// Create a copy of ExpenseEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? title = freezed,Object? description = freezed,Object? spentAt = freezed,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,spentAt: freezed == spentAt ? _self.spentAt : spentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseEntryModel].
extension ExpenseEntryModelPatterns on ExpenseEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  double amount,  String? title,  String? description,  DateTime? spentAt,  String status,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseEntryModel() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.title,_that.description,_that.spentAt,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  double amount,  String? title,  String? description,  DateTime? spentAt,  String status,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ExpenseEntryModel():
return $default(_that.id,_that.type,_that.amount,_that.title,_that.description,_that.spentAt,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  double amount,  String? title,  String? description,  DateTime? spentAt,  String status,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseEntryModel() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.title,_that.description,_that.spentAt,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpenseEntryModel extends ExpenseEntryModel {
  const _ExpenseEntryModel({required this.id, required this.type, required this.amount, this.title, this.description, this.spentAt, this.status = 'ACTIVE', this.createdAt}): super._();
  factory _ExpenseEntryModel.fromJson(Map<String, dynamic> json) => _$ExpenseEntryModelFromJson(json);

@override final  String id;
@override final  String type;
@override final  double amount;
@override final  String? title;
@override final  String? description;
@override final  DateTime? spentAt;
/// ACTIVE or CANCELLED.
@override@JsonKey() final  String status;
@override final  DateTime? createdAt;

/// Create a copy of ExpenseEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseEntryModelCopyWith<_ExpenseEntryModel> get copyWith => __$ExpenseEntryModelCopyWithImpl<_ExpenseEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseEntryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.spentAt, spentAt) || other.spentAt == spentAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,title,description,spentAt,status,createdAt);

@override
String toString() {
  return 'ExpenseEntryModel(id: $id, type: $type, amount: $amount, title: $title, description: $description, spentAt: $spentAt, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ExpenseEntryModelCopyWith<$Res> implements $ExpenseEntryModelCopyWith<$Res> {
  factory _$ExpenseEntryModelCopyWith(_ExpenseEntryModel value, $Res Function(_ExpenseEntryModel) _then) = __$ExpenseEntryModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, double amount, String? title, String? description, DateTime? spentAt, String status, DateTime? createdAt
});




}
/// @nodoc
class __$ExpenseEntryModelCopyWithImpl<$Res>
    implements _$ExpenseEntryModelCopyWith<$Res> {
  __$ExpenseEntryModelCopyWithImpl(this._self, this._then);

  final _ExpenseEntryModel _self;
  final $Res Function(_ExpenseEntryModel) _then;

/// Create a copy of ExpenseEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? title = freezed,Object? description = freezed,Object? spentAt = freezed,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_ExpenseEntryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,spentAt: freezed == spentAt ? _self.spentAt : spentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
