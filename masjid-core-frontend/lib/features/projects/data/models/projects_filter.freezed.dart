// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'projects_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProjectsFilter {

/// PLANNED, ONGOING, COMPLETED or CANCELLED; null shows all.
 String? get status; String? get search;
/// Create a copy of ProjectsFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectsFilterCopyWith<ProjectsFilter> get copyWith => _$ProjectsFilterCopyWithImpl<ProjectsFilter>(this as ProjectsFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectsFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.search, search) || other.search == search));
}


@override
int get hashCode => Object.hash(runtimeType,status,search);

@override
String toString() {
  return 'ProjectsFilter(status: $status, search: $search)';
}


}

/// @nodoc
abstract mixin class $ProjectsFilterCopyWith<$Res>  {
  factory $ProjectsFilterCopyWith(ProjectsFilter value, $Res Function(ProjectsFilter) _then) = _$ProjectsFilterCopyWithImpl;
@useResult
$Res call({
 String? status, String? search
});




}
/// @nodoc
class _$ProjectsFilterCopyWithImpl<$Res>
    implements $ProjectsFilterCopyWith<$Res> {
  _$ProjectsFilterCopyWithImpl(this._self, this._then);

  final ProjectsFilter _self;
  final $Res Function(ProjectsFilter) _then;

/// Create a copy of ProjectsFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? search = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectsFilter].
extension ProjectsFilterPatterns on ProjectsFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectsFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectsFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectsFilter value)  $default,){
final _that = this;
switch (_that) {
case _ProjectsFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectsFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectsFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? status,  String? search)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectsFilter() when $default != null:
return $default(_that.status,_that.search);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? status,  String? search)  $default,) {final _that = this;
switch (_that) {
case _ProjectsFilter():
return $default(_that.status,_that.search);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? status,  String? search)?  $default,) {final _that = this;
switch (_that) {
case _ProjectsFilter() when $default != null:
return $default(_that.status,_that.search);case _:
  return null;

}
}

}

/// @nodoc


class _ProjectsFilter extends ProjectsFilter {
  const _ProjectsFilter({this.status, this.search}): super._();
  

/// PLANNED, ONGOING, COMPLETED or CANCELLED; null shows all.
@override final  String? status;
@override final  String? search;

/// Create a copy of ProjectsFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectsFilterCopyWith<_ProjectsFilter> get copyWith => __$ProjectsFilterCopyWithImpl<_ProjectsFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectsFilter&&(identical(other.status, status) || other.status == status)&&(identical(other.search, search) || other.search == search));
}


@override
int get hashCode => Object.hash(runtimeType,status,search);

@override
String toString() {
  return 'ProjectsFilter(status: $status, search: $search)';
}


}

/// @nodoc
abstract mixin class _$ProjectsFilterCopyWith<$Res> implements $ProjectsFilterCopyWith<$Res> {
  factory _$ProjectsFilterCopyWith(_ProjectsFilter value, $Res Function(_ProjectsFilter) _then) = __$ProjectsFilterCopyWithImpl;
@override @useResult
$Res call({
 String? status, String? search
});




}
/// @nodoc
class __$ProjectsFilterCopyWithImpl<$Res>
    implements _$ProjectsFilterCopyWith<$Res> {
  __$ProjectsFilterCopyWithImpl(this._self, this._then);

  final _ProjectsFilter _self;
  final $Res Function(_ProjectsFilter) _then;

/// Create a copy of ProjectsFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? search = freezed,}) {
  return _then(_ProjectsFilter(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
