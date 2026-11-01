import 'package:json_annotation/json_annotation.dart';

part 'expense_models.g.dart';

@JsonSerializable()
class ExpenseCategoryModel {
  final int id;
  final String name;
  final String? color;
  final int expenseCount;
  final double totalSpent;
  final DateTime? createdAt;

  const ExpenseCategoryModel({
    required this.id,
    required this.name,
    this.color,
    this.expenseCount = 0,
    this.totalSpent = 0.0,
    this.createdAt,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseCategoryModelToJson(this);
}

@JsonSerializable()
class ExpenseCategoryRequest {
  final String name;
  final String? color;

  const ExpenseCategoryRequest({
    required this.name,
    this.color,
  });

  factory ExpenseCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseCategoryRequestToJson(this);
}

@JsonSerializable()
class ExpenseModel {
  final int id;
  final String title;
  final double amount;
  final DateTime expenseDate;
  final int categoryId;
  final String categoryName;
  final String? categoryColor;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.expenseDate,
    required this.categoryId,
    required this.categoryName,
    this.categoryColor,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);
}

@JsonSerializable()
class ExpenseRequest {
  final String title;
  final double amount;
  final String expenseDate; // YYYY-MM-DD
  final int? categoryId;

  const ExpenseRequest({
    required this.title,
    required this.amount,
    required this.expenseDate,
    this.categoryId,
  });

  factory ExpenseRequest.fromJson(Map<String, dynamic> json) =>
      _$ExpenseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseRequestToJson(this);
}

@JsonSerializable()
class CategoryBreakdown {
  final int categoryId;
  final String categoryName;
  final String? categoryColor;
  final double totalAmount;
  final int expenseCount;
  final double percentage;

  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    this.categoryColor,
    required this.totalAmount,
    required this.expenseCount,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) =>
      _$CategoryBreakdownFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryBreakdownToJson(this);
}

@JsonSerializable()
class ExpenseSummaryModel {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final int totalExpensesCount;
  final List<CategoryBreakdown> byCategory;

  const ExpenseSummaryModel({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.totalExpensesCount,
    required this.byCategory,
  });

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseSummaryModelToJson(this);
}

