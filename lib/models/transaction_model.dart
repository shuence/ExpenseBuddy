import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  expense,
  income,
}

enum SyncStatus {
  synced,
  pending,
  failed,
}

class TransactionModel extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final String userId;
  final String currency;
  final TransactionType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Sync-related fields
  final SyncStatus syncStatus;
  final int syncAttempts;
  final DateTime? lastSyncAttempt;
  final String? syncError;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    required this.userId,
    required this.currency,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.syncAttempts = 0,
    this.lastSyncAttempt,
    this.syncError,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: json['amount'] as double,
      category: json['category'] as String,
      date: _parseDateTime(json['date']),
      description: json['description'] as String?,
      userId: json['userId'] as String,
      currency: json['currency'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.expense,
      ),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString() == 'SyncStatus.${json['syncStatus'] ?? 'pending'}',
        orElse: () => SyncStatus.pending,
      ),
      syncAttempts: json['syncAttempts'] as int? ?? 0,
      lastSyncAttempt: json['lastSyncAttempt'] != null 
          ? _parseDateTime(json['lastSyncAttempt']) 
          : null,
      syncError: json['syncError'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'userId': userId,
      'currency': currency,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'syncStatus': syncStatus.toString().split('.').last,
      'syncAttempts': syncAttempts,
      'lastSyncAttempt': lastSyncAttempt?.toIso8601String(),
      'syncError': syncError,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    String? userId,
    String? currency,
    TransactionType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    int? syncAttempts,
    DateTime? lastSyncAttempt,
    String? syncError,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    amount,
    category,
    date,
    description,
    userId,
    currency,
    type,
    createdAt,
    updatedAt,
    syncStatus,
    syncAttempts,
    lastSyncAttempt,
    syncError,
  ];

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue is DateTime) {
      return dateValue;
    } else if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        // If parsing fails, return current time
        return DateTime.now();
      }
    } else if (dateValue is int) {
      // Handle timestamp in milliseconds
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else if (dateValue is Timestamp) {
      // Handle Firestore Timestamp objects
      return dateValue.toDate();
    } else {
      // Fallback to current time
      return DateTime.now();
    }
  }
}
