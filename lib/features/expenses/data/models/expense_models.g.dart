// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseCategoryModel _$ExpenseCategoryModelFromJson(Map<String, dynamic> json) =>
    ExpenseCategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      color: json['color'] as String?,
      expenseCount: (json['expenseCount'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ExpenseCategoryModelToJson(
        ExpenseCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'expenseCount': instance.expenseCount,
      'totalSpent': instance.totalSpent,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

ExpenseCategoryRequest _$ExpenseCategoryRequestFromJson(
        Map<String, dynamic> json) =>
    ExpenseCategoryRequest(
      name: json['name'] as String,
      color: json['color'] as String?,
    );

Map<String, dynamic> _$ExpenseCategoryRequestToJson(
        ExpenseCategoryRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': instance.color,
    };

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      categoryId: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      categoryColor: json['categoryColor'] as String?,
      createdBy: (json['createdBy'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'expenseDate': instance.expenseDate.toIso8601String().split('T').first,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryColor': instance.categoryColor,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

ExpenseRequest _$ExpenseRequestFromJson(Map<String, dynamic> json) =>
    ExpenseRequest(
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      expenseDate: json['expenseDate'] as String,
      categoryId: (json['categoryId'] as num).toInt(),
    );

Map<String, dynamic> _$ExpenseRequestToJson(ExpenseRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'amount': instance.amount,
      'expenseDate': instance.expenseDate,
      'categoryId': instance.categoryId,
    };

CategoryBreakdown _$CategoryBreakdownFromJson(Map<String, dynamic> json) =>
    CategoryBreakdown(
      categoryId: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      categoryColor: json['categoryColor'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      expenseCount: (json['expenseCount'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$CategoryBreakdownToJson(CategoryBreakdown instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'categoryColor': instance.categoryColor,
      'totalAmount': instance.totalAmount,
      'expenseCount': instance.expenseCount,
      'percentage': instance.percentage,
    };

ExpenseSummaryModel _$ExpenseSummaryModelFromJson(Map<String, dynamic> json) =>
    ExpenseSummaryModel(
      period: json['period'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalExpensesCount: (json['totalExpensesCount'] as num).toInt(),
      byCategory: (json['byCategory'] as List<dynamic>)
          .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExpenseSummaryModelToJson(
        ExpenseSummaryModel instance) =>
    <String, dynamic>{
      'period': instance.period,
      'startDate': instance.startDate.toIso8601String().split('T').first,
      'endDate': instance.endDate.toIso8601String().split('T').first,
      'totalAmount': instance.totalAmount,
      'totalExpensesCount': instance.totalExpensesCount,
      'byCategory': instance.byCategory.map((e) => e.toJson()).toList(),
    };

