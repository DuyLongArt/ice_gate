// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'HumanEvaluation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HumanBodyMetrics {

 double get weight;// in kg
 double get height;// in cm
 int get age; String get gender;// 'male' or 'female'
 String get activityLevel;// 'sedentary', 'light', 'moderate', 'active', 'very_active'
 String? get goal;
/// Create a copy of HumanBodyMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HumanBodyMetricsCopyWith<HumanBodyMetrics> get copyWith => _$HumanBodyMetricsCopyWithImpl<HumanBodyMetrics>(this as HumanBodyMetrics, _$identity);

  /// Serializes this HumanBodyMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HumanBodyMetrics&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.height, height) || other.height == height)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.goal, goal) || other.goal == goal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,height,age,gender,activityLevel,goal);

@override
String toString() {
  return 'HumanBodyMetrics(weight: $weight, height: $height, age: $age, gender: $gender, activityLevel: $activityLevel, goal: $goal)';
}


}

/// @nodoc
abstract mixin class $HumanBodyMetricsCopyWith<$Res>  {
  factory $HumanBodyMetricsCopyWith(HumanBodyMetrics value, $Res Function(HumanBodyMetrics) _then) = _$HumanBodyMetricsCopyWithImpl;
@useResult
$Res call({
 double weight, double height, int age, String gender, String activityLevel, String? goal
});




}
/// @nodoc
class _$HumanBodyMetricsCopyWithImpl<$Res>
    implements $HumanBodyMetricsCopyWith<$Res> {
  _$HumanBodyMetricsCopyWithImpl(this._self, this._then);

  final HumanBodyMetrics _self;
  final $Res Function(HumanBodyMetrics) _then;

/// Create a copy of HumanBodyMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weight = null,Object? height = null,Object? age = null,Object? gender = null,Object? activityLevel = null,Object? goal = freezed,}) {
  return _then(_self.copyWith(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as String,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HumanBodyMetrics].
extension HumanBodyMetricsPatterns on HumanBodyMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HumanBodyMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HumanBodyMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HumanBodyMetrics value)  $default,){
final _that = this;
switch (_that) {
case _HumanBodyMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HumanBodyMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _HumanBodyMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double weight,  double height,  int age,  String gender,  String activityLevel,  String? goal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HumanBodyMetrics() when $default != null:
return $default(_that.weight,_that.height,_that.age,_that.gender,_that.activityLevel,_that.goal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double weight,  double height,  int age,  String gender,  String activityLevel,  String? goal)  $default,) {final _that = this;
switch (_that) {
case _HumanBodyMetrics():
return $default(_that.weight,_that.height,_that.age,_that.gender,_that.activityLevel,_that.goal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double weight,  double height,  int age,  String gender,  String activityLevel,  String? goal)?  $default,) {final _that = this;
switch (_that) {
case _HumanBodyMetrics() when $default != null:
return $default(_that.weight,_that.height,_that.age,_that.gender,_that.activityLevel,_that.goal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HumanBodyMetrics implements HumanBodyMetrics {
  const _HumanBodyMetrics({required this.weight, required this.height, required this.age, required this.gender, required this.activityLevel, this.goal});
  factory _HumanBodyMetrics.fromJson(Map<String, dynamic> json) => _$HumanBodyMetricsFromJson(json);

@override final  double weight;
// in kg
@override final  double height;
// in cm
@override final  int age;
@override final  String gender;
// 'male' or 'female'
@override final  String activityLevel;
// 'sedentary', 'light', 'moderate', 'active', 'very_active'
@override final  String? goal;

/// Create a copy of HumanBodyMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HumanBodyMetricsCopyWith<_HumanBodyMetrics> get copyWith => __$HumanBodyMetricsCopyWithImpl<_HumanBodyMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HumanBodyMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HumanBodyMetrics&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.height, height) || other.height == height)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.goal, goal) || other.goal == goal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,height,age,gender,activityLevel,goal);

@override
String toString() {
  return 'HumanBodyMetrics(weight: $weight, height: $height, age: $age, gender: $gender, activityLevel: $activityLevel, goal: $goal)';
}


}

/// @nodoc
abstract mixin class _$HumanBodyMetricsCopyWith<$Res> implements $HumanBodyMetricsCopyWith<$Res> {
  factory _$HumanBodyMetricsCopyWith(_HumanBodyMetrics value, $Res Function(_HumanBodyMetrics) _then) = __$HumanBodyMetricsCopyWithImpl;
@override @useResult
$Res call({
 double weight, double height, int age, String gender, String activityLevel, String? goal
});




}
/// @nodoc
class __$HumanBodyMetricsCopyWithImpl<$Res>
    implements _$HumanBodyMetricsCopyWith<$Res> {
  __$HumanBodyMetricsCopyWithImpl(this._self, this._then);

  final _HumanBodyMetrics _self;
  final $Res Function(_HumanBodyMetrics) _then;

/// Create a copy of HumanBodyMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weight = null,Object? height = null,Object? age = null,Object? gender = null,Object? activityLevel = null,Object? goal = freezed,}) {
  return _then(_HumanBodyMetrics(
weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,activityLevel: null == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as String,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BloodTestMetrics {

 double? get glucose;// mg/dL
 double? get cholesterol;// mg/dL
 double? get hdl;// mg/dL (good cholesterol)
 double? get ldl;// mg/dL (bad cholesterol)
 double? get triglycerides;// mg/dL
 double? get hemoglobin;// g/dL
 double? get whiteBloodCells;// cells/mcL
 double? get platelets;// cells/mcL
 String? get bloodType;
/// Create a copy of BloodTestMetrics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BloodTestMetricsCopyWith<BloodTestMetrics> get copyWith => _$BloodTestMetricsCopyWithImpl<BloodTestMetrics>(this as BloodTestMetrics, _$identity);

  /// Serializes this BloodTestMetrics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BloodTestMetrics&&(identical(other.glucose, glucose) || other.glucose == glucose)&&(identical(other.cholesterol, cholesterol) || other.cholesterol == cholesterol)&&(identical(other.hdl, hdl) || other.hdl == hdl)&&(identical(other.ldl, ldl) || other.ldl == ldl)&&(identical(other.triglycerides, triglycerides) || other.triglycerides == triglycerides)&&(identical(other.hemoglobin, hemoglobin) || other.hemoglobin == hemoglobin)&&(identical(other.whiteBloodCells, whiteBloodCells) || other.whiteBloodCells == whiteBloodCells)&&(identical(other.platelets, platelets) || other.platelets == platelets)&&(identical(other.bloodType, bloodType) || other.bloodType == bloodType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,glucose,cholesterol,hdl,ldl,triglycerides,hemoglobin,whiteBloodCells,platelets,bloodType);

@override
String toString() {
  return 'BloodTestMetrics(glucose: $glucose, cholesterol: $cholesterol, hdl: $hdl, ldl: $ldl, triglycerides: $triglycerides, hemoglobin: $hemoglobin, whiteBloodCells: $whiteBloodCells, platelets: $platelets, bloodType: $bloodType)';
}


}

/// @nodoc
abstract mixin class $BloodTestMetricsCopyWith<$Res>  {
  factory $BloodTestMetricsCopyWith(BloodTestMetrics value, $Res Function(BloodTestMetrics) _then) = _$BloodTestMetricsCopyWithImpl;
@useResult
$Res call({
 double? glucose, double? cholesterol, double? hdl, double? ldl, double? triglycerides, double? hemoglobin, double? whiteBloodCells, double? platelets, String? bloodType
});




}
/// @nodoc
class _$BloodTestMetricsCopyWithImpl<$Res>
    implements $BloodTestMetricsCopyWith<$Res> {
  _$BloodTestMetricsCopyWithImpl(this._self, this._then);

  final BloodTestMetrics _self;
  final $Res Function(BloodTestMetrics) _then;

/// Create a copy of BloodTestMetrics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? glucose = freezed,Object? cholesterol = freezed,Object? hdl = freezed,Object? ldl = freezed,Object? triglycerides = freezed,Object? hemoglobin = freezed,Object? whiteBloodCells = freezed,Object? platelets = freezed,Object? bloodType = freezed,}) {
  return _then(_self.copyWith(
glucose: freezed == glucose ? _self.glucose : glucose // ignore: cast_nullable_to_non_nullable
as double?,cholesterol: freezed == cholesterol ? _self.cholesterol : cholesterol // ignore: cast_nullable_to_non_nullable
as double?,hdl: freezed == hdl ? _self.hdl : hdl // ignore: cast_nullable_to_non_nullable
as double?,ldl: freezed == ldl ? _self.ldl : ldl // ignore: cast_nullable_to_non_nullable
as double?,triglycerides: freezed == triglycerides ? _self.triglycerides : triglycerides // ignore: cast_nullable_to_non_nullable
as double?,hemoglobin: freezed == hemoglobin ? _self.hemoglobin : hemoglobin // ignore: cast_nullable_to_non_nullable
as double?,whiteBloodCells: freezed == whiteBloodCells ? _self.whiteBloodCells : whiteBloodCells // ignore: cast_nullable_to_non_nullable
as double?,platelets: freezed == platelets ? _self.platelets : platelets // ignore: cast_nullable_to_non_nullable
as double?,bloodType: freezed == bloodType ? _self.bloodType : bloodType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BloodTestMetrics].
extension BloodTestMetricsPatterns on BloodTestMetrics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BloodTestMetrics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BloodTestMetrics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BloodTestMetrics value)  $default,){
final _that = this;
switch (_that) {
case _BloodTestMetrics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BloodTestMetrics value)?  $default,){
final _that = this;
switch (_that) {
case _BloodTestMetrics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? glucose,  double? cholesterol,  double? hdl,  double? ldl,  double? triglycerides,  double? hemoglobin,  double? whiteBloodCells,  double? platelets,  String? bloodType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BloodTestMetrics() when $default != null:
return $default(_that.glucose,_that.cholesterol,_that.hdl,_that.ldl,_that.triglycerides,_that.hemoglobin,_that.whiteBloodCells,_that.platelets,_that.bloodType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? glucose,  double? cholesterol,  double? hdl,  double? ldl,  double? triglycerides,  double? hemoglobin,  double? whiteBloodCells,  double? platelets,  String? bloodType)  $default,) {final _that = this;
switch (_that) {
case _BloodTestMetrics():
return $default(_that.glucose,_that.cholesterol,_that.hdl,_that.ldl,_that.triglycerides,_that.hemoglobin,_that.whiteBloodCells,_that.platelets,_that.bloodType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? glucose,  double? cholesterol,  double? hdl,  double? ldl,  double? triglycerides,  double? hemoglobin,  double? whiteBloodCells,  double? platelets,  String? bloodType)?  $default,) {final _that = this;
switch (_that) {
case _BloodTestMetrics() when $default != null:
return $default(_that.glucose,_that.cholesterol,_that.hdl,_that.ldl,_that.triglycerides,_that.hemoglobin,_that.whiteBloodCells,_that.platelets,_that.bloodType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BloodTestMetrics implements BloodTestMetrics {
  const _BloodTestMetrics({this.glucose, this.cholesterol, this.hdl, this.ldl, this.triglycerides, this.hemoglobin, this.whiteBloodCells, this.platelets, this.bloodType});
  factory _BloodTestMetrics.fromJson(Map<String, dynamic> json) => _$BloodTestMetricsFromJson(json);

@override final  double? glucose;
// mg/dL
@override final  double? cholesterol;
// mg/dL
@override final  double? hdl;
// mg/dL (good cholesterol)
@override final  double? ldl;
// mg/dL (bad cholesterol)
@override final  double? triglycerides;
// mg/dL
@override final  double? hemoglobin;
// g/dL
@override final  double? whiteBloodCells;
// cells/mcL
@override final  double? platelets;
// cells/mcL
@override final  String? bloodType;

/// Create a copy of BloodTestMetrics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BloodTestMetricsCopyWith<_BloodTestMetrics> get copyWith => __$BloodTestMetricsCopyWithImpl<_BloodTestMetrics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BloodTestMetricsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BloodTestMetrics&&(identical(other.glucose, glucose) || other.glucose == glucose)&&(identical(other.cholesterol, cholesterol) || other.cholesterol == cholesterol)&&(identical(other.hdl, hdl) || other.hdl == hdl)&&(identical(other.ldl, ldl) || other.ldl == ldl)&&(identical(other.triglycerides, triglycerides) || other.triglycerides == triglycerides)&&(identical(other.hemoglobin, hemoglobin) || other.hemoglobin == hemoglobin)&&(identical(other.whiteBloodCells, whiteBloodCells) || other.whiteBloodCells == whiteBloodCells)&&(identical(other.platelets, platelets) || other.platelets == platelets)&&(identical(other.bloodType, bloodType) || other.bloodType == bloodType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,glucose,cholesterol,hdl,ldl,triglycerides,hemoglobin,whiteBloodCells,platelets,bloodType);

@override
String toString() {
  return 'BloodTestMetrics(glucose: $glucose, cholesterol: $cholesterol, hdl: $hdl, ldl: $ldl, triglycerides: $triglycerides, hemoglobin: $hemoglobin, whiteBloodCells: $whiteBloodCells, platelets: $platelets, bloodType: $bloodType)';
}


}

/// @nodoc
abstract mixin class _$BloodTestMetricsCopyWith<$Res> implements $BloodTestMetricsCopyWith<$Res> {
  factory _$BloodTestMetricsCopyWith(_BloodTestMetrics value, $Res Function(_BloodTestMetrics) _then) = __$BloodTestMetricsCopyWithImpl;
@override @useResult
$Res call({
 double? glucose, double? cholesterol, double? hdl, double? ldl, double? triglycerides, double? hemoglobin, double? whiteBloodCells, double? platelets, String? bloodType
});




}
/// @nodoc
class __$BloodTestMetricsCopyWithImpl<$Res>
    implements _$BloodTestMetricsCopyWith<$Res> {
  __$BloodTestMetricsCopyWithImpl(this._self, this._then);

  final _BloodTestMetrics _self;
  final $Res Function(_BloodTestMetrics) _then;

/// Create a copy of BloodTestMetrics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? glucose = freezed,Object? cholesterol = freezed,Object? hdl = freezed,Object? ldl = freezed,Object? triglycerides = freezed,Object? hemoglobin = freezed,Object? whiteBloodCells = freezed,Object? platelets = freezed,Object? bloodType = freezed,}) {
  return _then(_BloodTestMetrics(
glucose: freezed == glucose ? _self.glucose : glucose // ignore: cast_nullable_to_non_nullable
as double?,cholesterol: freezed == cholesterol ? _self.cholesterol : cholesterol // ignore: cast_nullable_to_non_nullable
as double?,hdl: freezed == hdl ? _self.hdl : hdl // ignore: cast_nullable_to_non_nullable
as double?,ldl: freezed == ldl ? _self.ldl : ldl // ignore: cast_nullable_to_non_nullable
as double?,triglycerides: freezed == triglycerides ? _self.triglycerides : triglycerides // ignore: cast_nullable_to_non_nullable
as double?,hemoglobin: freezed == hemoglobin ? _self.hemoglobin : hemoglobin // ignore: cast_nullable_to_non_nullable
as double?,whiteBloodCells: freezed == whiteBloodCells ? _self.whiteBloodCells : whiteBloodCells // ignore: cast_nullable_to_non_nullable
as double?,platelets: freezed == platelets ? _self.platelets : platelets // ignore: cast_nullable_to_non_nullable
as double?,bloodType: freezed == bloodType ? _self.bloodType : bloodType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$HumanInputValues {

 HumanBodyMetrics get humanBodyMetrics; BloodTestMetrics get bloodTestMetrics; TargetCaloriesProtocol get caloriesProtocol;
/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HumanInputValuesCopyWith<HumanInputValues> get copyWith => _$HumanInputValuesCopyWithImpl<HumanInputValues>(this as HumanInputValues, _$identity);

  /// Serializes this HumanInputValues to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HumanInputValues&&(identical(other.humanBodyMetrics, humanBodyMetrics) || other.humanBodyMetrics == humanBodyMetrics)&&(identical(other.bloodTestMetrics, bloodTestMetrics) || other.bloodTestMetrics == bloodTestMetrics)&&(identical(other.caloriesProtocol, caloriesProtocol) || other.caloriesProtocol == caloriesProtocol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,humanBodyMetrics,bloodTestMetrics,caloriesProtocol);

@override
String toString() {
  return 'HumanInputValues(humanBodyMetrics: $humanBodyMetrics, bloodTestMetrics: $bloodTestMetrics, caloriesProtocol: $caloriesProtocol)';
}


}

/// @nodoc
abstract mixin class $HumanInputValuesCopyWith<$Res>  {
  factory $HumanInputValuesCopyWith(HumanInputValues value, $Res Function(HumanInputValues) _then) = _$HumanInputValuesCopyWithImpl;
@useResult
$Res call({
 HumanBodyMetrics humanBodyMetrics, BloodTestMetrics bloodTestMetrics, TargetCaloriesProtocol caloriesProtocol
});


$HumanBodyMetricsCopyWith<$Res> get humanBodyMetrics;$BloodTestMetricsCopyWith<$Res> get bloodTestMetrics;$TargetCaloriesProtocolCopyWith<$Res> get caloriesProtocol;

}
/// @nodoc
class _$HumanInputValuesCopyWithImpl<$Res>
    implements $HumanInputValuesCopyWith<$Res> {
  _$HumanInputValuesCopyWithImpl(this._self, this._then);

  final HumanInputValues _self;
  final $Res Function(HumanInputValues) _then;

/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? humanBodyMetrics = null,Object? bloodTestMetrics = null,Object? caloriesProtocol = null,}) {
  return _then(_self.copyWith(
humanBodyMetrics: null == humanBodyMetrics ? _self.humanBodyMetrics : humanBodyMetrics // ignore: cast_nullable_to_non_nullable
as HumanBodyMetrics,bloodTestMetrics: null == bloodTestMetrics ? _self.bloodTestMetrics : bloodTestMetrics // ignore: cast_nullable_to_non_nullable
as BloodTestMetrics,caloriesProtocol: null == caloriesProtocol ? _self.caloriesProtocol : caloriesProtocol // ignore: cast_nullable_to_non_nullable
as TargetCaloriesProtocol,
  ));
}
/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HumanBodyMetricsCopyWith<$Res> get humanBodyMetrics {
  
  return $HumanBodyMetricsCopyWith<$Res>(_self.humanBodyMetrics, (value) {
    return _then(_self.copyWith(humanBodyMetrics: value));
  });
}/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BloodTestMetricsCopyWith<$Res> get bloodTestMetrics {
  
  return $BloodTestMetricsCopyWith<$Res>(_self.bloodTestMetrics, (value) {
    return _then(_self.copyWith(bloodTestMetrics: value));
  });
}/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetCaloriesProtocolCopyWith<$Res> get caloriesProtocol {
  
  return $TargetCaloriesProtocolCopyWith<$Res>(_self.caloriesProtocol, (value) {
    return _then(_self.copyWith(caloriesProtocol: value));
  });
}
}


/// Adds pattern-matching-related methods to [HumanInputValues].
extension HumanInputValuesPatterns on HumanInputValues {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HumanInputValues value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HumanInputValues() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HumanInputValues value)  $default,){
final _that = this;
switch (_that) {
case _HumanInputValues():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HumanInputValues value)?  $default,){
final _that = this;
switch (_that) {
case _HumanInputValues() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HumanBodyMetrics humanBodyMetrics,  BloodTestMetrics bloodTestMetrics,  TargetCaloriesProtocol caloriesProtocol)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HumanInputValues() when $default != null:
return $default(_that.humanBodyMetrics,_that.bloodTestMetrics,_that.caloriesProtocol);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HumanBodyMetrics humanBodyMetrics,  BloodTestMetrics bloodTestMetrics,  TargetCaloriesProtocol caloriesProtocol)  $default,) {final _that = this;
switch (_that) {
case _HumanInputValues():
return $default(_that.humanBodyMetrics,_that.bloodTestMetrics,_that.caloriesProtocol);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HumanBodyMetrics humanBodyMetrics,  BloodTestMetrics bloodTestMetrics,  TargetCaloriesProtocol caloriesProtocol)?  $default,) {final _that = this;
switch (_that) {
case _HumanInputValues() when $default != null:
return $default(_that.humanBodyMetrics,_that.bloodTestMetrics,_that.caloriesProtocol);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HumanInputValues implements HumanInputValues {
  const _HumanInputValues({required this.humanBodyMetrics, required this.bloodTestMetrics, required this.caloriesProtocol});
  factory _HumanInputValues.fromJson(Map<String, dynamic> json) => _$HumanInputValuesFromJson(json);

@override final  HumanBodyMetrics humanBodyMetrics;
@override final  BloodTestMetrics bloodTestMetrics;
@override final  TargetCaloriesProtocol caloriesProtocol;

/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HumanInputValuesCopyWith<_HumanInputValues> get copyWith => __$HumanInputValuesCopyWithImpl<_HumanInputValues>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HumanInputValuesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HumanInputValues&&(identical(other.humanBodyMetrics, humanBodyMetrics) || other.humanBodyMetrics == humanBodyMetrics)&&(identical(other.bloodTestMetrics, bloodTestMetrics) || other.bloodTestMetrics == bloodTestMetrics)&&(identical(other.caloriesProtocol, caloriesProtocol) || other.caloriesProtocol == caloriesProtocol));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,humanBodyMetrics,bloodTestMetrics,caloriesProtocol);

@override
String toString() {
  return 'HumanInputValues(humanBodyMetrics: $humanBodyMetrics, bloodTestMetrics: $bloodTestMetrics, caloriesProtocol: $caloriesProtocol)';
}


}

/// @nodoc
abstract mixin class _$HumanInputValuesCopyWith<$Res> implements $HumanInputValuesCopyWith<$Res> {
  factory _$HumanInputValuesCopyWith(_HumanInputValues value, $Res Function(_HumanInputValues) _then) = __$HumanInputValuesCopyWithImpl;
@override @useResult
$Res call({
 HumanBodyMetrics humanBodyMetrics, BloodTestMetrics bloodTestMetrics, TargetCaloriesProtocol caloriesProtocol
});


@override $HumanBodyMetricsCopyWith<$Res> get humanBodyMetrics;@override $BloodTestMetricsCopyWith<$Res> get bloodTestMetrics;@override $TargetCaloriesProtocolCopyWith<$Res> get caloriesProtocol;

}
/// @nodoc
class __$HumanInputValuesCopyWithImpl<$Res>
    implements _$HumanInputValuesCopyWith<$Res> {
  __$HumanInputValuesCopyWithImpl(this._self, this._then);

  final _HumanInputValues _self;
  final $Res Function(_HumanInputValues) _then;

/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? humanBodyMetrics = null,Object? bloodTestMetrics = null,Object? caloriesProtocol = null,}) {
  return _then(_HumanInputValues(
humanBodyMetrics: null == humanBodyMetrics ? _self.humanBodyMetrics : humanBodyMetrics // ignore: cast_nullable_to_non_nullable
as HumanBodyMetrics,bloodTestMetrics: null == bloodTestMetrics ? _self.bloodTestMetrics : bloodTestMetrics // ignore: cast_nullable_to_non_nullable
as BloodTestMetrics,caloriesProtocol: null == caloriesProtocol ? _self.caloriesProtocol : caloriesProtocol // ignore: cast_nullable_to_non_nullable
as TargetCaloriesProtocol,
  ));
}

/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HumanBodyMetricsCopyWith<$Res> get humanBodyMetrics {
  
  return $HumanBodyMetricsCopyWith<$Res>(_self.humanBodyMetrics, (value) {
    return _then(_self.copyWith(humanBodyMetrics: value));
  });
}/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BloodTestMetricsCopyWith<$Res> get bloodTestMetrics {
  
  return $BloodTestMetricsCopyWith<$Res>(_self.bloodTestMetrics, (value) {
    return _then(_self.copyWith(bloodTestMetrics: value));
  });
}/// Create a copy of HumanInputValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetCaloriesProtocolCopyWith<$Res> get caloriesProtocol {
  
  return $TargetCaloriesProtocolCopyWith<$Res>(_self.caloriesProtocol, (value) {
    return _then(_self.copyWith(caloriesProtocol: value));
  });
}
}


/// @nodoc
mixin _$HumanTargetValues {

 HumanBodyMetrics get humanBodyMetrics; BloodTestMetrics get bloodTestMetrics; TargetCaloriesProtocol get caloriesProtocol; double? get bmi;// Body Mass Index
 double? get bmr;// Basal Metabolic Rate
 double? get tdee;// Total Daily Energy Expenditure
 String? get healthStatus;// 'excellent', 'good', 'fair', 'poor'
 List<String>? get recommendations;
/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HumanTargetValuesCopyWith<HumanTargetValues> get copyWith => _$HumanTargetValuesCopyWithImpl<HumanTargetValues>(this as HumanTargetValues, _$identity);

  /// Serializes this HumanTargetValues to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HumanTargetValues&&(identical(other.humanBodyMetrics, humanBodyMetrics) || other.humanBodyMetrics == humanBodyMetrics)&&(identical(other.bloodTestMetrics, bloodTestMetrics) || other.bloodTestMetrics == bloodTestMetrics)&&(identical(other.caloriesProtocol, caloriesProtocol) || other.caloriesProtocol == caloriesProtocol)&&(identical(other.bmi, bmi) || other.bmi == bmi)&&(identical(other.bmr, bmr) || other.bmr == bmr)&&(identical(other.tdee, tdee) || other.tdee == tdee)&&(identical(other.healthStatus, healthStatus) || other.healthStatus == healthStatus)&&const DeepCollectionEquality().equals(other.recommendations, recommendations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,humanBodyMetrics,bloodTestMetrics,caloriesProtocol,bmi,bmr,tdee,healthStatus,const DeepCollectionEquality().hash(recommendations));

@override
String toString() {
  return 'HumanTargetValues(humanBodyMetrics: $humanBodyMetrics, bloodTestMetrics: $bloodTestMetrics, caloriesProtocol: $caloriesProtocol, bmi: $bmi, bmr: $bmr, tdee: $tdee, healthStatus: $healthStatus, recommendations: $recommendations)';
}


}

/// @nodoc
abstract mixin class $HumanTargetValuesCopyWith<$Res>  {
  factory $HumanTargetValuesCopyWith(HumanTargetValues value, $Res Function(HumanTargetValues) _then) = _$HumanTargetValuesCopyWithImpl;
@useResult
$Res call({
 HumanBodyMetrics humanBodyMetrics, BloodTestMetrics bloodTestMetrics, TargetCaloriesProtocol caloriesProtocol, double? bmi, double? bmr, double? tdee, String? healthStatus, List<String>? recommendations
});


$HumanBodyMetricsCopyWith<$Res> get humanBodyMetrics;$BloodTestMetricsCopyWith<$Res> get bloodTestMetrics;$TargetCaloriesProtocolCopyWith<$Res> get caloriesProtocol;

}
/// @nodoc
class _$HumanTargetValuesCopyWithImpl<$Res>
    implements $HumanTargetValuesCopyWith<$Res> {
  _$HumanTargetValuesCopyWithImpl(this._self, this._then);

  final HumanTargetValues _self;
  final $Res Function(HumanTargetValues) _then;

/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? humanBodyMetrics = null,Object? bloodTestMetrics = null,Object? caloriesProtocol = null,Object? bmi = freezed,Object? bmr = freezed,Object? tdee = freezed,Object? healthStatus = freezed,Object? recommendations = freezed,}) {
  return _then(_self.copyWith(
humanBodyMetrics: null == humanBodyMetrics ? _self.humanBodyMetrics : humanBodyMetrics // ignore: cast_nullable_to_non_nullable
as HumanBodyMetrics,bloodTestMetrics: null == bloodTestMetrics ? _self.bloodTestMetrics : bloodTestMetrics // ignore: cast_nullable_to_non_nullable
as BloodTestMetrics,caloriesProtocol: null == caloriesProtocol ? _self.caloriesProtocol : caloriesProtocol // ignore: cast_nullable_to_non_nullable
as TargetCaloriesProtocol,bmi: freezed == bmi ? _self.bmi : bmi // ignore: cast_nullable_to_non_nullable
as double?,bmr: freezed == bmr ? _self.bmr : bmr // ignore: cast_nullable_to_non_nullable
as double?,tdee: freezed == tdee ? _self.tdee : tdee // ignore: cast_nullable_to_non_nullable
as double?,healthStatus: freezed == healthStatus ? _self.healthStatus : healthStatus // ignore: cast_nullable_to_non_nullable
as String?,recommendations: freezed == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}
/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HumanBodyMetricsCopyWith<$Res> get humanBodyMetrics {
  
  return $HumanBodyMetricsCopyWith<$Res>(_self.humanBodyMetrics, (value) {
    return _then(_self.copyWith(humanBodyMetrics: value));
  });
}/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BloodTestMetricsCopyWith<$Res> get bloodTestMetrics {
  
  return $BloodTestMetricsCopyWith<$Res>(_self.bloodTestMetrics, (value) {
    return _then(_self.copyWith(bloodTestMetrics: value));
  });
}/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetCaloriesProtocolCopyWith<$Res> get caloriesProtocol {
  
  return $TargetCaloriesProtocolCopyWith<$Res>(_self.caloriesProtocol, (value) {
    return _then(_self.copyWith(caloriesProtocol: value));
  });
}
}


/// Adds pattern-matching-related methods to [HumanTargetValues].
extension HumanTargetValuesPatterns on HumanTargetValues {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HumanTargetValues value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HumanTargetValues() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HumanTargetValues value)  $default,){
final _that = this;
switch (_that) {
case _HumanTargetValues():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HumanTargetValues value)?  $default,){
final _that = this;
switch (_that) {
case _HumanTargetValues() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HumanBodyMetrics humanBodyMetrics,  BloodTestMetrics bloodTestMetrics,  TargetCaloriesProtocol caloriesProtocol,  double? bmi,  double? bmr,  double? tdee,  String? healthStatus,  List<String>? recommendations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HumanTargetValues() when $default != null:
return $default(_that.humanBodyMetrics,_that.bloodTestMetrics,_that.caloriesProtocol,_that.bmi,_that.bmr,_that.tdee,_that.healthStatus,_that.recommendations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HumanBodyMetrics humanBodyMetrics,  BloodTestMetrics bloodTestMetrics,  TargetCaloriesProtocol caloriesProtocol,  double? bmi,  double? bmr,  double? tdee,  String? healthStatus,  List<String>? recommendations)  $default,) {final _that = this;
switch (_that) {
case _HumanTargetValues():
return $default(_that.humanBodyMetrics,_that.bloodTestMetrics,_that.caloriesProtocol,_that.bmi,_that.bmr,_that.tdee,_that.healthStatus,_that.recommendations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HumanBodyMetrics humanBodyMetrics,  BloodTestMetrics bloodTestMetrics,  TargetCaloriesProtocol caloriesProtocol,  double? bmi,  double? bmr,  double? tdee,  String? healthStatus,  List<String>? recommendations)?  $default,) {final _that = this;
switch (_that) {
case _HumanTargetValues() when $default != null:
return $default(_that.humanBodyMetrics,_that.bloodTestMetrics,_that.caloriesProtocol,_that.bmi,_that.bmr,_that.tdee,_that.healthStatus,_that.recommendations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HumanTargetValues implements HumanTargetValues {
  const _HumanTargetValues({required this.humanBodyMetrics, required this.bloodTestMetrics, required this.caloriesProtocol, this.bmi, this.bmr, this.tdee, this.healthStatus, final  List<String>? recommendations}): _recommendations = recommendations;
  factory _HumanTargetValues.fromJson(Map<String, dynamic> json) => _$HumanTargetValuesFromJson(json);

@override final  HumanBodyMetrics humanBodyMetrics;
@override final  BloodTestMetrics bloodTestMetrics;
@override final  TargetCaloriesProtocol caloriesProtocol;
@override final  double? bmi;
// Body Mass Index
@override final  double? bmr;
// Basal Metabolic Rate
@override final  double? tdee;
// Total Daily Energy Expenditure
@override final  String? healthStatus;
// 'excellent', 'good', 'fair', 'poor'
 final  List<String>? _recommendations;
// 'excellent', 'good', 'fair', 'poor'
@override List<String>? get recommendations {
  final value = _recommendations;
  if (value == null) return null;
  if (_recommendations is EqualUnmodifiableListView) return _recommendations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HumanTargetValuesCopyWith<_HumanTargetValues> get copyWith => __$HumanTargetValuesCopyWithImpl<_HumanTargetValues>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HumanTargetValuesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HumanTargetValues&&(identical(other.humanBodyMetrics, humanBodyMetrics) || other.humanBodyMetrics == humanBodyMetrics)&&(identical(other.bloodTestMetrics, bloodTestMetrics) || other.bloodTestMetrics == bloodTestMetrics)&&(identical(other.caloriesProtocol, caloriesProtocol) || other.caloriesProtocol == caloriesProtocol)&&(identical(other.bmi, bmi) || other.bmi == bmi)&&(identical(other.bmr, bmr) || other.bmr == bmr)&&(identical(other.tdee, tdee) || other.tdee == tdee)&&(identical(other.healthStatus, healthStatus) || other.healthStatus == healthStatus)&&const DeepCollectionEquality().equals(other._recommendations, _recommendations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,humanBodyMetrics,bloodTestMetrics,caloriesProtocol,bmi,bmr,tdee,healthStatus,const DeepCollectionEquality().hash(_recommendations));

@override
String toString() {
  return 'HumanTargetValues(humanBodyMetrics: $humanBodyMetrics, bloodTestMetrics: $bloodTestMetrics, caloriesProtocol: $caloriesProtocol, bmi: $bmi, bmr: $bmr, tdee: $tdee, healthStatus: $healthStatus, recommendations: $recommendations)';
}


}

/// @nodoc
abstract mixin class _$HumanTargetValuesCopyWith<$Res> implements $HumanTargetValuesCopyWith<$Res> {
  factory _$HumanTargetValuesCopyWith(_HumanTargetValues value, $Res Function(_HumanTargetValues) _then) = __$HumanTargetValuesCopyWithImpl;
@override @useResult
$Res call({
 HumanBodyMetrics humanBodyMetrics, BloodTestMetrics bloodTestMetrics, TargetCaloriesProtocol caloriesProtocol, double? bmi, double? bmr, double? tdee, String? healthStatus, List<String>? recommendations
});


@override $HumanBodyMetricsCopyWith<$Res> get humanBodyMetrics;@override $BloodTestMetricsCopyWith<$Res> get bloodTestMetrics;@override $TargetCaloriesProtocolCopyWith<$Res> get caloriesProtocol;

}
/// @nodoc
class __$HumanTargetValuesCopyWithImpl<$Res>
    implements _$HumanTargetValuesCopyWith<$Res> {
  __$HumanTargetValuesCopyWithImpl(this._self, this._then);

  final _HumanTargetValues _self;
  final $Res Function(_HumanTargetValues) _then;

/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? humanBodyMetrics = null,Object? bloodTestMetrics = null,Object? caloriesProtocol = null,Object? bmi = freezed,Object? bmr = freezed,Object? tdee = freezed,Object? healthStatus = freezed,Object? recommendations = freezed,}) {
  return _then(_HumanTargetValues(
humanBodyMetrics: null == humanBodyMetrics ? _self.humanBodyMetrics : humanBodyMetrics // ignore: cast_nullable_to_non_nullable
as HumanBodyMetrics,bloodTestMetrics: null == bloodTestMetrics ? _self.bloodTestMetrics : bloodTestMetrics // ignore: cast_nullable_to_non_nullable
as BloodTestMetrics,caloriesProtocol: null == caloriesProtocol ? _self.caloriesProtocol : caloriesProtocol // ignore: cast_nullable_to_non_nullable
as TargetCaloriesProtocol,bmi: freezed == bmi ? _self.bmi : bmi // ignore: cast_nullable_to_non_nullable
as double?,bmr: freezed == bmr ? _self.bmr : bmr // ignore: cast_nullable_to_non_nullable
as double?,tdee: freezed == tdee ? _self.tdee : tdee // ignore: cast_nullable_to_non_nullable
as double?,healthStatus: freezed == healthStatus ? _self.healthStatus : healthStatus // ignore: cast_nullable_to_non_nullable
as String?,recommendations: freezed == recommendations ? _self._recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HumanBodyMetricsCopyWith<$Res> get humanBodyMetrics {
  
  return $HumanBodyMetricsCopyWith<$Res>(_self.humanBodyMetrics, (value) {
    return _then(_self.copyWith(humanBodyMetrics: value));
  });
}/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BloodTestMetricsCopyWith<$Res> get bloodTestMetrics {
  
  return $BloodTestMetricsCopyWith<$Res>(_self.bloodTestMetrics, (value) {
    return _then(_self.copyWith(bloodTestMetrics: value));
  });
}/// Create a copy of HumanTargetValues
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetCaloriesProtocolCopyWith<$Res> get caloriesProtocol {
  
  return $TargetCaloriesProtocolCopyWith<$Res>(_self.caloriesProtocol, (value) {
    return _then(_self.copyWith(caloriesProtocol: value));
  });
}
}

// dart format on
