// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_project_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateProjectRequest {

 String? get title; String? get description; double? get targetAmount; double? get collectedAmount; double? get spentAmount; String? get status;/// `yyyy-MM-dd`.
 String? get startDate;/// `yyyy-MM-dd`.
 String? get endDate;
/// Create a copy of UpdateProjectRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProjectRequestCopyWith<UpdateProjectRequest> get copyWith => _$UpdateProjectRequestCopyWithImpl<UpdateProjectRequest>(this as UpdateProjectRequest, _$identity);

  /// Serializes this UpdateProjectRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProjectRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.collectedAmount, collectedAmount) || other.collectedAmount == collectedAmount)&&(identical(other.spentAmount, spentAmount) || other.spentAmount == spentAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,targetAmount,collectedAmount,spentAmount,status,startDate,endDate);

@override
String toString() {
  return 'UpdateProjectRequest(title: $title, description: $description, targetAmount: $targetAmount, collectedAmount: $collectedAmount, spentAmount: $spentAmount, status: $status, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $UpdateProjectRequestCopyWith<$Res>  {
  factory $UpdateProjectRequestCopyWith(UpdateProjectRequest value, $Res Function(UpdateProjectRequest) _then) = _$UpdateProjectRequestCopyWithImpl;
@useResult
$Res call({
 String? title, String? description, double? targetAmount, double? collectedAmount, double? spentAmount, String? status, String? startDate, String? endDate
});




}
/// @nodoc
class _$UpdateProjectRequestCopyWithImpl<$Res>
    implements $UpdateProjectRequestCopyWith<$Res> {
  _$UpdateProjectRequestCopyWithImpl(this._self, this._then);

  final UpdateProjectRequest _self;
  final $Res Function(UpdateProjectRequest) _then;

/// Create a copy of UpdateProjectRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? description = freezed,Object? targetAmount = freezed,Object? collectedAmount = freezed,Object? spentAmount = freezed,Object? status = freezed,Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double?,collectedAmount: freezed == collectedAmount ? _self.collectedAmount : collectedAmount // ignore: cast_nullable_to_non_nullable
as double?,spentAmount: freezed == spentAmount ? _self.spentAmount : spentAmount // ignore: cast_nullable_to_non_nullable
as double?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateProjectRequest].
extension UpdateProjectRequestPatterns on UpdateProjectRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProjectRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProjectRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProjectRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProjectRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProjectRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProjectRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? description,  double? targetAmount,  double? collectedAmount,  double? spentAmount,  String? status,  String? startDate,  String? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProjectRequest() when $default != null:
return $default(_that.title,_that.description,_that.targetAmount,_that.collectedAmount,_that.spentAmount,_that.status,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? description,  double? targetAmount,  double? collectedAmount,  double? spentAmount,  String? status,  String? startDate,  String? endDate)  $default,) {final _that = this;
switch (_that) {
case _UpdateProjectRequest():
return $default(_that.title,_that.description,_that.targetAmount,_that.collectedAmount,_that.spentAmount,_that.status,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? description,  double? targetAmount,  double? collectedAmount,  double? spentAmount,  String? status,  String? startDate,  String? endDate)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProjectRequest() when $default != null:
return $default(_that.title,_that.description,_that.targetAmount,_that.collectedAmount,_that.spentAmount,_that.status,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(includeIfNull: false)
class _UpdateProjectRequest implements UpdateProjectRequest {
  const _UpdateProjectRequest({this.title, this.description, this.targetAmount, this.collectedAmount, this.spentAmount, this.status, this.startDate, this.endDate});
  factory _UpdateProjectRequest.fromJson(Map<String, dynamic> json) => _$UpdateProjectRequestFromJson(json);

@override final  String? title;
@override final  String? description;
@override final  double? targetAmount;
@override final  double? collectedAmount;
@override final  double? spentAmount;
@override final  String? status;
/// `yyyy-MM-dd`.
@override final  String? startDate;
/// `yyyy-MM-dd`.
@override final  String? endDate;

/// Create a copy of UpdateProjectRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProjectRequestCopyWith<_UpdateProjectRequest> get copyWith => __$UpdateProjectRequestCopyWithImpl<_UpdateProjectRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProjectRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProjectRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.collectedAmount, collectedAmount) || other.collectedAmount == collectedAmount)&&(identical(other.spentAmount, spentAmount) || other.spentAmount == spentAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,targetAmount,collectedAmount,spentAmount,status,startDate,endDate);

@override
String toString() {
  return 'UpdateProjectRequest(title: $title, description: $description, targetAmount: $targetAmount, collectedAmount: $collectedAmount, spentAmount: $spentAmount, status: $status, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$UpdateProjectRequestCopyWith<$Res> implements $UpdateProjectRequestCopyWith<$Res> {
  factory _$UpdateProjectRequestCopyWith(_UpdateProjectRequest value, $Res Function(_UpdateProjectRequest) _then) = __$UpdateProjectRequestCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? description, double? targetAmount, double? collectedAmount, double? spentAmount, String? status, String? startDate, String? endDate
});




}
/// @nodoc
class __$UpdateProjectRequestCopyWithImpl<$Res>
    implements _$UpdateProjectRequestCopyWith<$Res> {
  __$UpdateProjectRequestCopyWithImpl(this._self, this._then);

  final _UpdateProjectRequest _self;
  final $Res Function(_UpdateProjectRequest) _then;

/// Create a copy of UpdateProjectRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? description = freezed,Object? targetAmount = freezed,Object? collectedAmount = freezed,Object? spentAmount = freezed,Object? status = freezed,Object? startDate = freezed,Object? endDate = freezed,}) {
  return _then(_UpdateProjectRequest(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetAmount: freezed == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double?,collectedAmount: freezed == collectedAmount ? _self.collectedAmount : collectedAmount // ignore: cast_nullable_to_non_nullable
as double?,spentAmount: freezed == spentAmount ? _self.spentAmount : spentAmount // ignore: cast_nullable_to_non_nullable
as double?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
