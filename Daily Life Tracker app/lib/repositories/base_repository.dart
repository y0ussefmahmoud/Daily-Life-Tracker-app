// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Base exception class for repository-level errors.
/// Provides standardized error handling across all repositories.
class RepositoryException implements Exception {
  final String message;
  final dynamic originalError;

  RepositoryException(this.message, [this.originalError]);

  @override
  String toString() => 'RepositoryException: $message';
}

/// Base repository interface defining generic CRUD operations.
/// All domain-specific repositories should extend or implement this interface.
abstract class BaseRepository<T> {
  /// Fetches a single entity by its ID.
  /// 
  /// Parameters:
  /// - id: Unique identifier of the entity
  /// 
  /// Returns the entity if found, null otherwise.
  /// 
  /// Throws [RepositoryException] if the operation fails.
  Future<T?> getById(String id);

  /// Fetches all entities for the current user.
  /// 
  /// Returns a list of all entities.
  /// 
  /// Throws [RepositoryException] if the operation fails.
  Future<List<T>> getAll();

  /// Creates a new entity.
  /// 
  /// Parameters:
  /// - entity: The entity to create
  /// 
  /// Returns the created entity with generated ID.
  /// 
  /// Throws [RepositoryException] if the operation fails.
  Future<T> create(T entity);

  /// Updates an existing entity.
  /// 
  /// Parameters:
  /// - entity: The entity with updated values
  /// 
  /// Returns the updated entity.
  /// 
  /// Throws [RepositoryException] if the operation fails.
  Future<T> update(T entity);

  /// Deletes an entity by its ID.
  /// 
  /// Parameters:
  /// - id: Unique identifier of the entity to delete
  /// 
  /// Throws [RepositoryException] if the operation fails.
  Future<void> delete(String id);

  /// Executes a repository operation with standardized error handling.
  /// 
  /// Parameters:
  /// - operation: The async operation to execute
  /// - errorMessage: Custom error message prefix
  /// 
  /// Returns the result of the operation.
  /// 
  /// Throws [RepositoryException] wrapping any caught errors.
  Future<R> executeWithErrorHandling<R>(
    Future<R> Function() operation,
    String errorMessage,
  ) async {
    try {
      return await operation();
    } catch (e) {
      debugPrint('$errorMessage: $e');
      throw RepositoryException(errorMessage, e);
    }
  }
}
