// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_dashboard_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminDashboardSummary {

 int get totalUsers; int get activeUsers; int get inactiveUsers; int get suspendedUsers; int get totalMasjids; int get approvedMasjids; int get pendingMasjids; int get suspendedMasjids; int get pendingRequests; int get approvedRequests; int get rejectedRequests;
/// Create a copy of AdminDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminDashboardSummaryCopyWith<AdminDashboardSummary> get copyWith => _$AdminDashboardSummaryCopyWithImpl<AdminDashboardSummary>(this as AdminDashboardSummary, _$identity);

  /// Serializes this AdminDashboardSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminDashboardSummary&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.inactiveUsers, inactiveUsers) || other.inactiveUsers == inactiveUsers)&&(identical(other.suspendedUsers, suspendedUsers) || other.suspendedUsers == suspendedUsers)&&(identical(other.totalMasjids, totalMasjids) || other.totalMasjids == totalMasjids)&&(identical(other.approvedMasjids, approvedMasjids) || other.approvedMasjids == approvedMasjids)&&(identical(other.pendingMasjids, pendingMasjids) || other.pendingMasjids == pendingMasjids)&&(identical(other.suspendedMasjids, suspendedMasjids) || other.suspendedMasjids == suspendedMasjids)&&(identical(other.pendingRequests, pendingRequests) || other.pendingRequests == pendingRequests)&&(identical(other.approvedRequests, approvedRequests) || other.approvedRequests == approvedRequests)&&(identical(other.rejectedRequests, rejectedRequests) || other.rejectedRequests == rejectedRequests));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,activeUsers,inactiveUsers,suspendedUsers,totalMasjids,approvedMasjids,pendingMasjids,suspendedMasjids,pendingRequests,approvedRequests,rejectedRequests);

@override
String toString() {
  return 'AdminDashboardSummary(totalUsers: $totalUsers, activeUsers: $activeUsers, inactiveUsers: $inactiveUsers, suspendedUsers: $suspendedUsers, totalMasjids: $totalMasjids, approvedMasjids: $approvedMasjids, pendingMasjids: $pendingMasjids, suspendedMasjids: $suspendedMasjids, pendingRequests: $pendingRequests, approvedRequests: $approvedRequests, rejectedRequests: $rejectedRequests)';
}


}

/// @nodoc
abstract mixin class $AdminDashboardSummaryCopyWith<$Res>  {
  factory $AdminDashboardSummaryCopyWith(AdminDashboardSummary value, $Res Function(AdminDashboardSummary) _then) = _$AdminDashboardSummaryCopyWithImpl;
@useResult
$Res call({
 int totalUsers, int activeUsers, int inactiveUsers, int suspendedUsers, int totalMasjids, int approvedMasjids, int pendingMasjids, int suspendedMasjids, int pendingRequests, int approvedRequests, int rejectedRequests
});




}
/// @nodoc
class _$AdminDashboardSummaryCopyWithImpl<$Res>
    implements $AdminDashboardSummaryCopyWith<$Res> {
  _$AdminDashboardSummaryCopyWithImpl(this._self, this._then);

  final AdminDashboardSummary _self;
  final $Res Function(AdminDashboardSummary) _then;

/// Create a copy of AdminDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUsers = null,Object? activeUsers = null,Object? inactiveUsers = null,Object? suspendedUsers = null,Object? totalMasjids = null,Object? approvedMasjids = null,Object? pendingMasjids = null,Object? suspendedMasjids = null,Object? pendingRequests = null,Object? approvedRequests = null,Object? rejectedRequests = null,}) {
  return _then(_self.copyWith(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,activeUsers: null == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int,inactiveUsers: null == inactiveUsers ? _self.inactiveUsers : inactiveUsers // ignore: cast_nullable_to_non_nullable
as int,suspendedUsers: null == suspendedUsers ? _self.suspendedUsers : suspendedUsers // ignore: cast_nullable_to_non_nullable
as int,totalMasjids: null == totalMasjids ? _self.totalMasjids : totalMasjids // ignore: cast_nullable_to_non_nullable
as int,approvedMasjids: null == approvedMasjids ? _self.approvedMasjids : approvedMasjids // ignore: cast_nullable_to_non_nullable
as int,pendingMasjids: null == pendingMasjids ? _self.pendingMasjids : pendingMasjids // ignore: cast_nullable_to_non_nullable
as int,suspendedMasjids: null == suspendedMasjids ? _self.suspendedMasjids : suspendedMasjids // ignore: cast_nullable_to_non_nullable
as int,pendingRequests: null == pendingRequests ? _self.pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as int,approvedRequests: null == approvedRequests ? _self.approvedRequests : approvedRequests // ignore: cast_nullable_to_non_nullable
as int,rejectedRequests: null == rejectedRequests ? _self.rejectedRequests : rejectedRequests // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminDashboardSummary].
extension AdminDashboardSummaryPatterns on AdminDashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminDashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminDashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminDashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _AdminDashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminDashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AdminDashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalUsers,  int activeUsers,  int inactiveUsers,  int suspendedUsers,  int totalMasjids,  int approvedMasjids,  int pendingMasjids,  int suspendedMasjids,  int pendingRequests,  int approvedRequests,  int rejectedRequests)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminDashboardSummary() when $default != null:
return $default(_that.totalUsers,_that.activeUsers,_that.inactiveUsers,_that.suspendedUsers,_that.totalMasjids,_that.approvedMasjids,_that.pendingMasjids,_that.suspendedMasjids,_that.pendingRequests,_that.approvedRequests,_that.rejectedRequests);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalUsers,  int activeUsers,  int inactiveUsers,  int suspendedUsers,  int totalMasjids,  int approvedMasjids,  int pendingMasjids,  int suspendedMasjids,  int pendingRequests,  int approvedRequests,  int rejectedRequests)  $default,) {final _that = this;
switch (_that) {
case _AdminDashboardSummary():
return $default(_that.totalUsers,_that.activeUsers,_that.inactiveUsers,_that.suspendedUsers,_that.totalMasjids,_that.approvedMasjids,_that.pendingMasjids,_that.suspendedMasjids,_that.pendingRequests,_that.approvedRequests,_that.rejectedRequests);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalUsers,  int activeUsers,  int inactiveUsers,  int suspendedUsers,  int totalMasjids,  int approvedMasjids,  int pendingMasjids,  int suspendedMasjids,  int pendingRequests,  int approvedRequests,  int rejectedRequests)?  $default,) {final _that = this;
switch (_that) {
case _AdminDashboardSummary() when $default != null:
return $default(_that.totalUsers,_that.activeUsers,_that.inactiveUsers,_that.suspendedUsers,_that.totalMasjids,_that.approvedMasjids,_that.pendingMasjids,_that.suspendedMasjids,_that.pendingRequests,_that.approvedRequests,_that.rejectedRequests);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminDashboardSummary implements AdminDashboardSummary {
  const _AdminDashboardSummary({this.totalUsers = 0, this.activeUsers = 0, this.inactiveUsers = 0, this.suspendedUsers = 0, this.totalMasjids = 0, this.approvedMasjids = 0, this.pendingMasjids = 0, this.suspendedMasjids = 0, this.pendingRequests = 0, this.approvedRequests = 0, this.rejectedRequests = 0});
  factory _AdminDashboardSummary.fromJson(Map<String, dynamic> json) => _$AdminDashboardSummaryFromJson(json);

@override@JsonKey() final  int totalUsers;
@override@JsonKey() final  int activeUsers;
@override@JsonKey() final  int inactiveUsers;
@override@JsonKey() final  int suspendedUsers;
@override@JsonKey() final  int totalMasjids;
@override@JsonKey() final  int approvedMasjids;
@override@JsonKey() final  int pendingMasjids;
@override@JsonKey() final  int suspendedMasjids;
@override@JsonKey() final  int pendingRequests;
@override@JsonKey() final  int approvedRequests;
@override@JsonKey() final  int rejectedRequests;

/// Create a copy of AdminDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminDashboardSummaryCopyWith<_AdminDashboardSummary> get copyWith => __$AdminDashboardSummaryCopyWithImpl<_AdminDashboardSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminDashboardSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminDashboardSummary&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.inactiveUsers, inactiveUsers) || other.inactiveUsers == inactiveUsers)&&(identical(other.suspendedUsers, suspendedUsers) || other.suspendedUsers == suspendedUsers)&&(identical(other.totalMasjids, totalMasjids) || other.totalMasjids == totalMasjids)&&(identical(other.approvedMasjids, approvedMasjids) || other.approvedMasjids == approvedMasjids)&&(identical(other.pendingMasjids, pendingMasjids) || other.pendingMasjids == pendingMasjids)&&(identical(other.suspendedMasjids, suspendedMasjids) || other.suspendedMasjids == suspendedMasjids)&&(identical(other.pendingRequests, pendingRequests) || other.pendingRequests == pendingRequests)&&(identical(other.approvedRequests, approvedRequests) || other.approvedRequests == approvedRequests)&&(identical(other.rejectedRequests, rejectedRequests) || other.rejectedRequests == rejectedRequests));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,activeUsers,inactiveUsers,suspendedUsers,totalMasjids,approvedMasjids,pendingMasjids,suspendedMasjids,pendingRequests,approvedRequests,rejectedRequests);

@override
String toString() {
  return 'AdminDashboardSummary(totalUsers: $totalUsers, activeUsers: $activeUsers, inactiveUsers: $inactiveUsers, suspendedUsers: $suspendedUsers, totalMasjids: $totalMasjids, approvedMasjids: $approvedMasjids, pendingMasjids: $pendingMasjids, suspendedMasjids: $suspendedMasjids, pendingRequests: $pendingRequests, approvedRequests: $approvedRequests, rejectedRequests: $rejectedRequests)';
}


}

/// @nodoc
abstract mixin class _$AdminDashboardSummaryCopyWith<$Res> implements $AdminDashboardSummaryCopyWith<$Res> {
  factory _$AdminDashboardSummaryCopyWith(_AdminDashboardSummary value, $Res Function(_AdminDashboardSummary) _then) = __$AdminDashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalUsers, int activeUsers, int inactiveUsers, int suspendedUsers, int totalMasjids, int approvedMasjids, int pendingMasjids, int suspendedMasjids, int pendingRequests, int approvedRequests, int rejectedRequests
});




}
/// @nodoc
class __$AdminDashboardSummaryCopyWithImpl<$Res>
    implements _$AdminDashboardSummaryCopyWith<$Res> {
  __$AdminDashboardSummaryCopyWithImpl(this._self, this._then);

  final _AdminDashboardSummary _self;
  final $Res Function(_AdminDashboardSummary) _then;

/// Create a copy of AdminDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUsers = null,Object? activeUsers = null,Object? inactiveUsers = null,Object? suspendedUsers = null,Object? totalMasjids = null,Object? approvedMasjids = null,Object? pendingMasjids = null,Object? suspendedMasjids = null,Object? pendingRequests = null,Object? approvedRequests = null,Object? rejectedRequests = null,}) {
  return _then(_AdminDashboardSummary(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,activeUsers: null == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int,inactiveUsers: null == inactiveUsers ? _self.inactiveUsers : inactiveUsers // ignore: cast_nullable_to_non_nullable
as int,suspendedUsers: null == suspendedUsers ? _self.suspendedUsers : suspendedUsers // ignore: cast_nullable_to_non_nullable
as int,totalMasjids: null == totalMasjids ? _self.totalMasjids : totalMasjids // ignore: cast_nullable_to_non_nullable
as int,approvedMasjids: null == approvedMasjids ? _self.approvedMasjids : approvedMasjids // ignore: cast_nullable_to_non_nullable
as int,pendingMasjids: null == pendingMasjids ? _self.pendingMasjids : pendingMasjids // ignore: cast_nullable_to_non_nullable
as int,suspendedMasjids: null == suspendedMasjids ? _self.suspendedMasjids : suspendedMasjids // ignore: cast_nullable_to_non_nullable
as int,pendingRequests: null == pendingRequests ? _self.pendingRequests : pendingRequests // ignore: cast_nullable_to_non_nullable
as int,approvedRequests: null == approvedRequests ? _self.approvedRequests : approvedRequests // ignore: cast_nullable_to_non_nullable
as int,rejectedRequests: null == rejectedRequests ? _self.rejectedRequests : rejectedRequests // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
