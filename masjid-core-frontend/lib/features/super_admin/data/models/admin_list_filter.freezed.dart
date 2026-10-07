// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_list_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdminListFilter {

 String get search; String? get status;/// Users list only.
 String? get role;
/// Create a copy of AdminListFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminListFilterCopyWith<AdminListFilter> get copyWith => _$AdminListFilterCopyWithImpl<AdminListFilter>(this as AdminListFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminListFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,search,status,role);

@override
String toString() {
  return 'AdminListFilter(search: $search, status: $status, role: $role)';
}


}

/// @nodoc
abstract mixin class $AdminListFilterCopyWith<$Res>  {
  factory $AdminListFilterCopyWith(AdminListFilter value, $Res Function(AdminListFilter) _then) = _$AdminListFilterCopyWithImpl;
@useResult
$Res call({
 String search, String? status, String? role
});




}
/// @nodoc
class _$AdminListFilterCopyWithImpl<$Res>
    implements $AdminListFilterCopyWith<$Res> {
  _$AdminListFilterCopyWithImpl(this._self, this._then);

  final AdminListFilter _self;
  final $Res Function(AdminListFilter) _then;

/// Create a copy of AdminListFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? status = freezed,Object? role = freezed,}) {
  return _then(_self.copyWith(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminListFilter].
extension AdminListFilterPatterns on AdminListFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminListFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminListFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminListFilter value)  $default,){
final _that = this;
switch (_that) {
case _AdminListFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminListFilter value)?  $default,){
final _that = this;
switch (_that) {
case _AdminListFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  String? status,  String? role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminListFilter() when $default != null:
return $default(_that.search,_that.status,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  String? status,  String? role)  $default,) {final _that = this;
switch (_that) {
case _AdminListFilter():
return $default(_that.search,_that.status,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  String? status,  String? role)?  $default,) {final _that = this;
switch (_that) {
case _AdminListFilter() when $default != null:
return $default(_that.search,_that.status,_that.role);case _:
  return null;

}
}

}

/// @nodoc


class _AdminListFilter implements AdminListFilter {
  const _AdminListFilter({this.search = '', this.status, this.role});
  

@override@JsonKey() final  String search;
@override final  String? status;
/// Users list only.
@override final  String? role;

/// Create a copy of AdminListFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminListFilterCopyWith<_AdminListFilter> get copyWith => __$AdminListFilterCopyWithImpl<_AdminListFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminListFilter&&(identical(other.search, search) || other.search == search)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode => Object.hash(runtimeType,search,status,role);

@override
String toString() {
  return 'AdminListFilter(search: $search, status: $status, role: $role)';
}


}

/// @nodoc
abstract mixin class _$AdminListFilterCopyWith<$Res> implements $AdminListFilterCopyWith<$Res> {
  factory _$AdminListFilterCopyWith(_AdminListFilter value, $Res Function(_AdminListFilter) _then) = __$AdminListFilterCopyWithImpl;
@override @useResult
$Res call({
 String search, String? status, String? role
});




}
/// @nodoc
class __$AdminListFilterCopyWithImpl<$Res>
    implements _$AdminListFilterCopyWith<$Res> {
  __$AdminListFilterCopyWithImpl(this._self, this._then);

  final _AdminListFilter _self;
  final $Res Function(_AdminListFilter) _then;

/// Create a copy of AdminListFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? status = freezed,Object? role = freezed,}) {
  return _then(_AdminListFilter(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
