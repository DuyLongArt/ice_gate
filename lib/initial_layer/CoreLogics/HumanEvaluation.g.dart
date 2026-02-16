// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HumanEvaluation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HumanBodyMetrics _$HumanBodyMetricsFromJson(Map<String, dynamic> json) =>
    _HumanBodyMetrics(
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      activityLevel: json['activityLevel'] as String,
      goal: json['goal'] as String?,
    );

Map<String, dynamic> _$HumanBodyMetricsToJson(_HumanBodyMetrics instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'height': instance.height,
      'age': instance.age,
      'gender': instance.gender,
      'activityLevel': instance.activityLevel,
      'goal': instance.goal,
    };

_BloodTestMetrics _$BloodTestMetricsFromJson(Map<String, dynamic> json) =>
    _BloodTestMetrics(
      glucose: (json['glucose'] as num?)?.toDouble(),
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
      hdl: (json['hdl'] as num?)?.toDouble(),
      ldl: (json['ldl'] as num?)?.toDouble(),
      triglycerides: (json['triglycerides'] as num?)?.toDouble(),
      hemoglobin: (json['hemoglobin'] as num?)?.toDouble(),
      whiteBloodCells: (json['whiteBloodCells'] as num?)?.toDouble(),
      platelets: (json['platelets'] as num?)?.toDouble(),
      bloodType: json['bloodType'] as String?,
    );

Map<String, dynamic> _$BloodTestMetricsToJson(_BloodTestMetrics instance) =>
    <String, dynamic>{
      'glucose': instance.glucose,
      'cholesterol': instance.cholesterol,
      'hdl': instance.hdl,
      'ldl': instance.ldl,
      'triglycerides': instance.triglycerides,
      'hemoglobin': instance.hemoglobin,
      'whiteBloodCells': instance.whiteBloodCells,
      'platelets': instance.platelets,
      'bloodType': instance.bloodType,
    };

_HumanInputValues _$HumanInputValuesFromJson(Map<String, dynamic> json) =>
    _HumanInputValues(
      humanBodyMetrics: HumanBodyMetrics.fromJson(
        json['humanBodyMetrics'] as Map<String, dynamic>,
      ),
      bloodTestMetrics: BloodTestMetrics.fromJson(
        json['bloodTestMetrics'] as Map<String, dynamic>,
      ),
      caloriesProtocol: TargetCaloriesProtocol.fromJson(
        json['caloriesProtocol'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$HumanInputValuesToJson(_HumanInputValues instance) =>
    <String, dynamic>{
      'humanBodyMetrics': instance.humanBodyMetrics,
      'bloodTestMetrics': instance.bloodTestMetrics,
      'caloriesProtocol': instance.caloriesProtocol,
    };

_HumanTargetValues _$HumanTargetValuesFromJson(Map<String, dynamic> json) =>
    _HumanTargetValues(
      humanBodyMetrics: HumanBodyMetrics.fromJson(
        json['humanBodyMetrics'] as Map<String, dynamic>,
      ),
      bloodTestMetrics: BloodTestMetrics.fromJson(
        json['bloodTestMetrics'] as Map<String, dynamic>,
      ),
      caloriesProtocol: TargetCaloriesProtocol.fromJson(
        json['caloriesProtocol'] as Map<String, dynamic>,
      ),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmr: (json['bmr'] as num?)?.toDouble(),
      tdee: (json['tdee'] as num?)?.toDouble(),
      healthStatus: json['healthStatus'] as String?,
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$HumanTargetValuesToJson(_HumanTargetValues instance) =>
    <String, dynamic>{
      'humanBodyMetrics': instance.humanBodyMetrics,
      'bloodTestMetrics': instance.bloodTestMetrics,
      'caloriesProtocol': instance.caloriesProtocol,
      'bmi': instance.bmi,
      'bmr': instance.bmr,
      'tdee': instance.tdee,
      'healthStatus': instance.healthStatus,
      'recommendations': instance.recommendations,
    };
