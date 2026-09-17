// Exportations et définitions globales pour satisfaire l'analyseur statique

// 1. Exceptions personnalisées
class TaskCliException implements Exception {
  final String message;
  const TaskCliException(this.message);
  @override
  String toString() => message;
}

class TaskNotFoundException extends TaskCliException {
  const TaskNotFoundException(String id) : super('Tâche introuvable avec l\'id : $id');
}

class InvalidTaskException extends TaskCliException {
  const InvalidTaskException(super.message);
}

class StorageException extends TaskCliException {
  const StorageException(super.message);
}

// 2. Énumération des priorités
enum Priority { low, medium, high }

// 3. Classe abstraite et héritage (Task -> StandardTask / UrgentTask)
abstract class Task {
  final String id;
  final String title;
  final Priority priority;
  final bool isCompleted;
  final DateTime? dueDate;

  const Task({
    required this.id,
    required this.title,
    this.priority = Priority.medium,
    this.isCompleted = false,
    this.dueDate,
  });

  String get type;
  bool get requiresImmediateAttention => priority == Priority.high;

  factory Task.create({
    required String id,
    required String title,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) {
    if (priority == Priority.high) {
      return UrgentTask(id: id, title: title, dueDate: dueDate);
    }
    return StandardTask(id: id, title: title, priority: priority, dueDate: dueDate);
  }

  Task copyWith({
    String? id,
    String? title,
    Priority? priority,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    final newPriority = priority ?? this.priority;
    return Task.create(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: newPriority,
      dueDate: dueDate ?? this.dueDate,
    )..isCompletedFlag = isCompleted ?? this.isCompleted;
  }
  
  // Setter interne pour les copies
  set isCompletedFlag(bool value);
}

class StandardTask extends Task {
  bool _isCompleted;

  StandardTask({
    required super.id,
    required super.title,
    super.priority = Priority.medium,
    bool isCompleted = false,
    super.dueDate,
  }) : _isCompleted = isCompleted;

  @override
  bool get isCompleted => _isCompleted;

  @override
  set isCompletedFlag(bool value) => _isCompleted = value;

  @override
  String get type => 'standard';
}

class UrgentTask extends Task {
  bool _isCompleted;

  UrgentTask({
    required super.id,
    required super.title,
    bool isCompleted = false,
    super.dueDate,
  }) : super(priority: Priority.high), _isCompleted = isCompleted;

  @override
  bool get isCompleted => _isCompleted;

  @override
  set isCompletedFlag(bool value) => _isCompleted = value;

  @override
  String get type => 'urgent';

  String get warningLabel => 'Urgent';
}

// 4. Interface et type Générique <T>
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
}

abstract class TaskRepository implements Repository<Task> {}