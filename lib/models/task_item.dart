enum TaskStatus {
  idle,
  active,
  paused,
  completed,
}

class TaskItem {
  final String id;
  final String title;
  final String targetUrl;
  final TaskStatus status;
  final List<String> profileSectionsUsed;
  final int detectedFieldsCount;
  final int filledFieldsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;

  const TaskItem({
    required this.id,
    required this.title,
    this.targetUrl = '',
    this.status = TaskStatus.idle,
    this.profileSectionsUsed = const [],
    this.detectedFieldsCount = 0,
    this.filledFieldsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.notes = '',
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? targetUrl,
    TaskStatus? status,
    List<String>? profileSectionsUsed,
    int? detectedFieldsCount,
    int? filledFieldsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      targetUrl: targetUrl ?? this.targetUrl,
      status: status ?? this.status,
      profileSectionsUsed: profileSectionsUsed ?? this.profileSectionsUsed,
      detectedFieldsCount: detectedFieldsCount ?? this.detectedFieldsCount,
      filledFieldsCount: filledFieldsCount ?? this.filledFieldsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetUrl': targetUrl,
        'status': status.name,
        'profileSectionsUsed': profileSectionsUsed,
        'detectedFieldsCount': detectedFieldsCount,
        'filledFieldsCount': filledFieldsCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'notes': notes,
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      targetUrl: json['targetUrl'] as String? ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.idle,
      ),
      profileSectionsUsed: (json['profileSectionsUsed'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      detectedFieldsCount: json['detectedFieldsCount'] as int? ?? 0,
      filledFieldsCount: json['filledFieldsCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      notes: json['notes'] as String? ?? '',
    );
  }
}
