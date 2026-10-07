// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finance_entry_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FinanceEntryFilter {

 String? get type;/// ACTIVE or CANCELLED; null shows both.
 String? get status; String? get search; DateTime? get fromDate; DateTime? get toDate;
/// Create a copy of FinanceEntryFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinanceEntryFilterCopyWith<FinanceEntryFilter> get copyWith => _$FinanceEntryFilterCopyWithImpl<FinanceEntryFilter>(this as FinanceEntryFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinanceEntryFilter&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.search, search) || other.search == search)&&(identical(other.fromDate, fromDate) || other.fromDate == fromDate)&&(identical(other.toDate, toDate) || other.toDate == toDate));
}


@override
int get hashCode => Object.hash(runtimeType,type,status,search,fromDate,toDate);

@override
String toString() {
  return 'FinanceEntryFilter(type: $type, status: $status, search: $search, fromDate: $fromDate, toDate: $toDate)';
}


}

/// @nodoc
abstract mixin class $FinanceEntryFilterCopyWith<$Res>  {
  factory $FinanceEntryFilterCopyWith(FinanceEntryFilter value, $Res Function(FinanceEntryFilter) _then) = _$FinanceEntryFilterCopyWithImpl;
@useResult
$Res call({
 String? type, String? status, String? search, DateTime? fromDate, DateTime? toDate
});




}
/// @nodoc
class _$FinanceEntryFilterCopyWithImpl<$Res>
    implements $FinanceEntryFilterCopyWith<$Res> {
  _$FinanceEntryFilterCopyWithImpl(this._self, this._then);

  final FinanceEntryFilter _self;
  final $Res Function(FinanceEntryFilter) _then;

/// Create a copy of FinanceEntryFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? status = freezed,Object? search = freezed,Object? fromDate = freezed,Object? toDate = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,fromDate: freezed == fromDate ? _self.fromDate : fromDate // ignore: cast_nullable_to_non_nullable
as DateTime?,toDate: freezed == toDate ? _self.toDate : toDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FinanceEntryFilter].
extension FinanceEntryFilterPatterns on FinanceEntryFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinanceEntryFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinanceEntryFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinanceEntryFilter value)  $default,){
final _that = this;
switch (_that) {
case _FinanceEntryFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinanceEntryFilter value)?  $default,){
final _that = this;
switch (_that) {
case _FinanceEntryFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  String? status,  String? search,  DateTime? fromDate,  DateTime? toDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinanceEntryFilter() when $default != null:
return $default(_that.type,_that.status,_that.search,_that.fromDate,_that.toDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  String? status,  String? search,  DateTime? fromDate,  DateTime? toDate)  $default,) {final _that = this;
switch (_that) {
case _FinanceEntryFilter():
return $default(_that.type,_that.status,_that.search,_that.fromDate,_that.toDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  String? status,  String? search,  DateTime? fromDate,  DateTime? toDate)?  $default,) {final _that = this;
switch (_that) {
case _FinanceEntryFilter() when $default != null:
return $default(_that.type,_that.status,_that.search,_that.fromDate,_that.toDate);case _:
  return null;

}
}

}

/// @nodoc


class _FinanceEntryFilter extends FinanceEntryFilter {
  const _FinanceEntryFilter({this.type, this.status, this.search, this.fromDate, this.toDate}): super._();
  

@override final  String? type;
/// ACTIVE or CANCELLED; null shows both.
@override final  String? status;
@override final  String? search;
@override final  DateTime? fromDate;
@override final  DateTime? toDate;

/// Create a copy of FinanceEntryFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinanceEntryFilterCopyWith<_FinanceEntryFilter> get copyWith => __$FinanceEntryFilterCopyWithImpl<_FinanceEntryFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinanceEntryFilter&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.search, search) || other.search == search)&&(identical(other.fromDate, fromDate) || other.fromDate == fromDate)&&(identical(other.toDate, toDate) || other.toDate == toDate));
}


@override
int get hashCode => Object.hash(runtimeType,type,status,search,fromDate,toDate);

@override
String toString() {
  return 'FinanceEntryFilter(type: $type, status: $status, search: $search, fromDate: $fromDate, toDate: $toDate)';
}


}

/// @nodoc
abstract mixin class _$FinanceEntryFilterCopyWith<$Res> implements $FinanceEntryFilterCopyWith<$Res> {
  factory _$FinanceEntryFilterCopyWith(_FinanceEntryFilter value, $Res Function(_FinanceEntryFilter) _then) = __$FinanceEntryFilterCopyWithImpl;
@override @useResult
$Res call({
 String? type, String? status, String? search, DateTime? fromDate, DateTime? toDate
});




}
/// @nodoc
class __$FinanceEntryFilterCopyWithImpl<$Res>
    implements _$FinanceEntryFilterCopyWith<$Res> {
  __$FinanceEntryFilterCopyWithImpl(this._self, this._then);

  final _FinanceEntryFilter _self;
  final $Res Function(_FinanceEntryFilter) _then;

/// Create a copy of FinanceEntryFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? status = freezed,Object? search = freezed,Object? fromDate = freezed,Object? toDate = freezed,}) {
  return _then(_FinanceEntryFilter(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,fromDate: freezed == fromDate ? _self.fromDate : fromDate // ignore: cast_nullable_to_non_nullable
as DateTime?,toDate: freezed == toDate ? _self.toDate : toDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
