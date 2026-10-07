// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CollectionEntryModel {

 String get id; String get type; double get amount; String? get title; String? get description; DateTime? get collectedAt;/// ACTIVE or CANCELLED.
 String get status; DateTime? get createdAt;
/// Create a copy of CollectionEntryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionEntryModelCopyWith<CollectionEntryModel> get copyWith => _$CollectionEntryModelCopyWithImpl<CollectionEntryModel>(this as CollectionEntryModel, _$identity);

  /// Serializes this CollectionEntryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionEntryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.collectedAt, collectedAt) || other.collectedAt == collectedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,title,description,collectedAt,status,createdAt);

@override
String toString() {
  return 'CollectionEntryModel(id: $id, type: $type, amount: $amount, title: $title, description: $description, collectedAt: $collectedAt, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $CollectionEntryModelCopyWith<$Res>  {
  factory $CollectionEntryModelCopyWith(CollectionEntryModel value, $Res Function(CollectionEntryModel) _then) = _$CollectionEntryModelCopyWithImpl;
@useResult
$Res call({
 String id, String type, double amount, String? title, String? description, DateTime? collectedAt, String status, DateTime? createdAt
});




}
/// @nodoc
class _$CollectionEntryModelCopyWithImpl<$Res>
    implements $CollectionEntryModelCopyWith<$Res> {
  _$CollectionEntryModelCopyWithImpl(this._self, this._then);

  final CollectionEntryModel _self;
  final $Res Function(CollectionEntryModel) _then;

/// Create a copy of CollectionEntryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? title = freezed,Object? description = freezed,Object? collectedAt = freezed,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,collectedAt: freezed == collectedAt ? _self.collectedAt : collectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionEntryModel].
extension CollectionEntryModelPatterns on CollectionEntryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionEntryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionEntryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionEntryModel value)  $default,){
final _that = this;
switch (_that) {
case _CollectionEntryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionEntryModel value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionEntryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  double amount,  String? title,  String? description,  DateTime? collectedAt,  String status,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionEntryModel() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.title,_that.description,_that.collectedAt,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  double amount,  String? title,  String? description,  DateTime? collectedAt,  String status,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _CollectionEntryModel():
return $default(_that.id,_that.type,_that.amount,_that.title,_that.description,_that.collectedAt,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  double amount,  String? title,  String? description,  DateTime? collectedAt,  String status,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CollectionEntryModel() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.title,_that.description,_that.collectedAt,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionEntryModel extends CollectionEntryModel {
  const _CollectionEntryModel({required this.id, required this.type, required this.amount, this.title, this.description, this.collectedAt, this.status = 'ACTIVE', this.createdAt}): super._();
  factory _CollectionEntryModel.fromJson(Map<String, dynamic> json) => _$CollectionEntryModelFromJson(json);

@override final  String id;
@override final  String type;
@override final  double amount;
@override final  String? title;
@override final  String? description;
@override final  DateTime? collectedAt;
/// ACTIVE or CANCELLED.
@override@JsonKey() final  String status;
@override final  DateTime? createdAt;

/// Create a copy of CollectionEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionEntryModelCopyWith<_CollectionEntryModel> get copyWith => __$CollectionEntryModelCopyWithImpl<_CollectionEntryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionEntryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionEntryModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.collectedAt, collectedAt) || other.collectedAt == collectedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,title,description,collectedAt,status,createdAt);

@override
String toString() {
  return 'CollectionEntryModel(id: $id, type: $type, amount: $amount, title: $title, description: $description, collectedAt: $collectedAt, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CollectionEntryModelCopyWith<$Res> implements $CollectionEntryModelCopyWith<$Res> {
  factory _$CollectionEntryModelCopyWith(_CollectionEntryModel value, $Res Function(_CollectionEntryModel) _then) = __$CollectionEntryModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, double amount, String? title, String? description, DateTime? collectedAt, String status, DateTime? createdAt
});




}
/// @nodoc
class __$CollectionEntryModelCopyWithImpl<$Res>
    implements _$CollectionEntryModelCopyWith<$Res> {
  __$CollectionEntryModelCopyWithImpl(this._self, this._then);

  final _CollectionEntryModel _self;
  final $Res Function(_CollectionEntryModel) _then;

/// Create a copy of CollectionEntryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? title = freezed,Object? description = freezed,Object? collectedAt = freezed,Object? status = null,Object? createdAt = freezed,}) {
  return _then(_CollectionEntryModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,collectedAt: freezed == collectedAt ? _self.collectedAt : collectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
