// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_contribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectContribution {

 String get id; String get projectId; String get contributorName; String? get contributorPhone; double get amount; String get paymentMode; DateTime? get paidAt; String get collectedByName; String? get note; ContributionProject? get project;
/// Create a copy of ProjectContribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectContributionCopyWith<ProjectContribution> get copyWith => _$ProjectContributionCopyWithImpl<ProjectContribution>(this as ProjectContribution, _$identity);

  /// Serializes this ProjectContribution to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.contributorName, contributorName) || other.contributorName == contributorName)&&(identical(other.contributorPhone, contributorPhone) || other.contributorPhone == contributorPhone)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.collectedByName, collectedByName) || other.collectedByName == collectedByName)&&(identical(other.note, note) || other.note == note)&&(identical(other.project, project) || other.project == project));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,contributorName,contributorPhone,amount,paymentMode,paidAt,collectedByName,note,project);

@override
String toString() {
  return 'ProjectContribution(id: $id, projectId: $projectId, contributorName: $contributorName, contributorPhone: $contributorPhone, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, collectedByName: $collectedByName, note: $note, project: $project)';
}


}

/// @nodoc
abstract mixin class $ProjectContributionCopyWith<$Res>  {
  factory $ProjectContributionCopyWith(ProjectContribution value, $Res Function(ProjectContribution) _then) = _$ProjectContributionCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String contributorName, String? contributorPhone, double amount, String paymentMode, DateTime? paidAt, String collectedByName, String? note, ContributionProject? project
});


$ContributionProjectCopyWith<$Res>? get project;

}
/// @nodoc
class _$ProjectContributionCopyWithImpl<$Res>
    implements $ProjectContributionCopyWith<$Res> {
  _$ProjectContributionCopyWithImpl(this._self, this._then);

  final ProjectContribution _self;
  final $Res Function(ProjectContribution) _then;

/// Create a copy of ProjectContribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? contributorName = null,Object? contributorPhone = freezed,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? collectedByName = null,Object? note = freezed,Object? project = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,contributorName: null == contributorName ? _self.contributorName : contributorName // ignore: cast_nullable_to_non_nullable
as String,contributorPhone: freezed == contributorPhone ? _self.contributorPhone : contributorPhone // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,collectedByName: null == collectedByName ? _self.collectedByName : collectedByName // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as ContributionProject?,
  ));
}
/// Create a copy of ProjectContribution
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContributionProjectCopyWith<$Res>? get project {
    if (_self.project == null) {
    return null;
  }

  return $ContributionProjectCopyWith<$Res>(_self.project!, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProjectContribution].
extension ProjectContributionPatterns on ProjectContribution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectContribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectContribution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectContribution value)  $default,){
final _that = this;
switch (_that) {
case _ProjectContribution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectContribution value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectContribution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String contributorName,  String? contributorPhone,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note,  ContributionProject? project)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectContribution() when $default != null:
return $default(_that.id,_that.projectId,_that.contributorName,_that.contributorPhone,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note,_that.project);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String contributorName,  String? contributorPhone,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note,  ContributionProject? project)  $default,) {final _that = this;
switch (_that) {
case _ProjectContribution():
return $default(_that.id,_that.projectId,_that.contributorName,_that.contributorPhone,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note,_that.project);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String contributorName,  String? contributorPhone,  double amount,  String paymentMode,  DateTime? paidAt,  String collectedByName,  String? note,  ContributionProject? project)?  $default,) {final _that = this;
switch (_that) {
case _ProjectContribution() when $default != null:
return $default(_that.id,_that.projectId,_that.contributorName,_that.contributorPhone,_that.amount,_that.paymentMode,_that.paidAt,_that.collectedByName,_that.note,_that.project);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectContribution extends ProjectContribution {
  const _ProjectContribution({required this.id, this.projectId = '', this.contributorName = '', this.contributorPhone, this.amount = 0, this.paymentMode = '', this.paidAt, this.collectedByName = '', this.note, this.project}): super._();
  factory _ProjectContribution.fromJson(Map<String, dynamic> json) => _$ProjectContributionFromJson(json);

@override final  String id;
@override@JsonKey() final  String projectId;
@override@JsonKey() final  String contributorName;
@override final  String? contributorPhone;
@override@JsonKey() final  double amount;
@override@JsonKey() final  String paymentMode;
@override final  DateTime? paidAt;
@override@JsonKey() final  String collectedByName;
@override final  String? note;
@override final  ContributionProject? project;

/// Create a copy of ProjectContribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectContributionCopyWith<_ProjectContribution> get copyWith => __$ProjectContributionCopyWithImpl<_ProjectContribution>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectContributionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.contributorName, contributorName) || other.contributorName == contributorName)&&(identical(other.contributorPhone, contributorPhone) || other.contributorPhone == contributorPhone)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.collectedByName, collectedByName) || other.collectedByName == collectedByName)&&(identical(other.note, note) || other.note == note)&&(identical(other.project, project) || other.project == project));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,contributorName,contributorPhone,amount,paymentMode,paidAt,collectedByName,note,project);

@override
String toString() {
  return 'ProjectContribution(id: $id, projectId: $projectId, contributorName: $contributorName, contributorPhone: $contributorPhone, amount: $amount, paymentMode: $paymentMode, paidAt: $paidAt, collectedByName: $collectedByName, note: $note, project: $project)';
}


}

/// @nodoc
abstract mixin class _$ProjectContributionCopyWith<$Res> implements $ProjectContributionCopyWith<$Res> {
  factory _$ProjectContributionCopyWith(_ProjectContribution value, $Res Function(_ProjectContribution) _then) = __$ProjectContributionCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String contributorName, String? contributorPhone, double amount, String paymentMode, DateTime? paidAt, String collectedByName, String? note, ContributionProject? project
});


@override $ContributionProjectCopyWith<$Res>? get project;

}
/// @nodoc
class __$ProjectContributionCopyWithImpl<$Res>
    implements _$ProjectContributionCopyWith<$Res> {
  __$ProjectContributionCopyWithImpl(this._self, this._then);

  final _ProjectContribution _self;
  final $Res Function(_ProjectContribution) _then;

/// Create a copy of ProjectContribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? contributorName = null,Object? contributorPhone = freezed,Object? amount = null,Object? paymentMode = null,Object? paidAt = freezed,Object? collectedByName = null,Object? note = freezed,Object? project = freezed,}) {
  return _then(_ProjectContribution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,contributorName: null == contributorName ? _self.contributorName : contributorName // ignore: cast_nullable_to_non_nullable
as String,contributorPhone: freezed == contributorPhone ? _self.contributorPhone : contributorPhone // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,collectedByName: null == collectedByName ? _self.collectedByName : collectedByName // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,project: freezed == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as ContributionProject?,
  ));
}

/// Create a copy of ProjectContribution
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContributionProjectCopyWith<$Res>? get project {
    if (_self.project == null) {
    return null;
  }

  return $ContributionProjectCopyWith<$Res>(_self.project!, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}


/// @nodoc
mixin _$ContributionProject {

 String? get title;
/// Create a copy of ContributionProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionProjectCopyWith<ContributionProject> get copyWith => _$ContributionProjectCopyWithImpl<ContributionProject>(this as ContributionProject, _$identity);

  /// Serializes this ContributionProject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContributionProject&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title);

@override
String toString() {
  return 'ContributionProject(title: $title)';
}


}

/// @nodoc
abstract mixin class $ContributionProjectCopyWith<$Res>  {
  factory $ContributionProjectCopyWith(ContributionProject value, $Res Function(ContributionProject) _then) = _$ContributionProjectCopyWithImpl;
@useResult
$Res call({
 String? title
});




}
/// @nodoc
class _$ContributionProjectCopyWithImpl<$Res>
    implements $ContributionProjectCopyWith<$Res> {
  _$ContributionProjectCopyWithImpl(this._self, this._then);

  final ContributionProject _self;
  final $Res Function(ContributionProject) _then;

/// Create a copy of ContributionProject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContributionProject].
extension ContributionProjectPatterns on ContributionProject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContributionProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContributionProject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContributionProject value)  $default,){
final _that = this;
switch (_that) {
case _ContributionProject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContributionProject value)?  $default,){
final _that = this;
switch (_that) {
case _ContributionProject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContributionProject() when $default != null:
return $default(_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title)  $default,) {final _that = this;
switch (_that) {
case _ContributionProject():
return $default(_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title)?  $default,) {final _that = this;
switch (_that) {
case _ContributionProject() when $default != null:
return $default(_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContributionProject implements ContributionProject {
  const _ContributionProject({this.title});
  factory _ContributionProject.fromJson(Map<String, dynamic> json) => _$ContributionProjectFromJson(json);

@override final  String? title;

/// Create a copy of ContributionProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionProjectCopyWith<_ContributionProject> get copyWith => __$ContributionProjectCopyWithImpl<_ContributionProject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContributionProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContributionProject&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title);

@override
String toString() {
  return 'ContributionProject(title: $title)';
}


}

/// @nodoc
abstract mixin class _$ContributionProjectCopyWith<$Res> implements $ContributionProjectCopyWith<$Res> {
  factory _$ContributionProjectCopyWith(_ContributionProject value, $Res Function(_ContributionProject) _then) = __$ContributionProjectCopyWithImpl;
@override @useResult
$Res call({
 String? title
});




}
/// @nodoc
class __$ContributionProjectCopyWithImpl<$Res>
    implements _$ContributionProjectCopyWith<$Res> {
  __$ContributionProjectCopyWithImpl(this._self, this._then);

  final _ContributionProject _self;
  final $Res Function(_ContributionProject) _then;

/// Create a copy of ContributionProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,}) {
  return _then(_ContributionProject(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
