import '../repositories/base_repository.dart';

/// Data model representing a task entity.
class TaskEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final String category;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.category = 'general',
    this.priority = 'medium',
    required this.createdAt,
    required this.updatedAt,
  });

  TaskEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    String? category,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Repository for managing tasks with safe fallback for legacy users.
/// Provides non-destructive queries with backward compatibility.
class TaskRepository extends BaseRepository<TaskEntity> {
  /// Fetches a task by ID with safe fallback for missing columns.
  @override
  Future<TaskEntity?> getById(String id) async {
    return executeWithErrorHandling(
      () => _fetchTaskById(id),
      'Failed to fetch task by ID',
    );
  }

  /// Fetches all tasks for the current user.
  @override
  Future<List<TaskEntity>> getAll() async {
    return executeWithErrorHandling(
      () => _fetchAllTasks(),
      'Failed to fetch all tasks',
    );
  }

  /// Creates a new task with safe defaults for new columns.
  @override
  Future<TaskEntity> create(TaskEntity entity) async {
    return executeWithErrorHandling(
      () => _createTask(entity),
      'Failed to create task',
    );
  }

  /// Updates an existing task.
  @override
  Future<TaskEntity> update(TaskEntity entity) async {
    return executeWithErrorHandling(
      () => _updateTask(entity),
      'Failed to update task',
    );
  }

  /// Deletes a task by ID.
  @override
  Future<void> delete(String id) async {
    return executeWithErrorHandling(
      () => _deleteTask(id),
      'Failed to delete task',
    );
  }

  /// Fetches completed tasks only.
  Future<List<TaskEntity>> getCompletedTasks() async {
    return executeWithErrorHandling(
      () => _fetchCompletedTasks(),
      'Failed to fetch completed tasks',
    );
  }

  /// Fetches pending tasks only.
  Future<List<TaskEntity>> getPendingTasks() async {
    return executeWithErrorHandling(
      () => _fetchPendingTasks(),
      'Failed to fetch pending tasks',
    );
  }

  /// Fetches tasks by category.
  Future<List<TaskEntity>> getTasksByCategory(String category) async {
    return executeWithErrorHandling(
      () => _fetchTasksByCategory(category),
      'Failed to fetch tasks by category',
    );
  }

  /// Fetches tasks by priority level.
  Future<List<TaskEntity>> getTasksByPriority(String priority) async {
    return executeWithErrorHandling(
      () => _fetchTasksByPriority(priority),
      'Failed to fetch tasks by priority',
    );
  }

  /// Implementation methods (to be connected to actual data source)
  Future<TaskEntity?> _fetchTaskById(String id) async {
    // TODO: Implement actual database query with safe fallbacks
    return null;
  }

  Future<List<TaskEntity>> _fetchAllTasks() async {
    // TODO: Implement actual database query
    return [];
  }

  Future<TaskEntity> _createTask(TaskEntity entity) async {
    // TODO: Implement actual database insert with safe defaults
    return entity;
  }

  Future<TaskEntity> _updateTask(TaskEntity entity) async {
    // TODO: Implement actual database update
    return entity;
  }

  Future<void> _deleteTask(String id) async {
    // TODO: Implement actual database delete
  }

  Future<List<TaskEntity>> _fetchCompletedTasks() async {
    // TODO: Implement query with is_completed = true
    return [];
  }

  Future<List<TaskEntity>> _fetchPendingTasks() async {
    // TODO: Implement query with is_completed = false
    return [];
  }

  Future<List<TaskEntity>> _fetchTasksByCategory(String category) async {
    // TODO: Implement query with category filter
    return [];
  }

  Future<List<TaskEntity>> _fetchTasksByPriority(String priority) async {
    // TODO: Implement query with priority filter
    return [];
  }
}
