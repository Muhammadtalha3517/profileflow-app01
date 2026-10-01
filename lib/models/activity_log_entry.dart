class ActivityLogEntry {
  final String id;
  final DateTime timestamp;
  final String actionType;
  final String title;
  final String description;
  final String? targetUrl;
  final int? count;

  const ActivityLogEntry({
    required this.id,
    required this.timestamp,
    required this.actionType,
    required this.title,
    required this.description,
    this.targetUrl,
    this.count,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'actionType': actionType,
        'title': title,
        'description': description,
        'targetUrl': targetUrl,
        'count': count,
      };

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      id: json['id'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      actionType: json['actionType'] as String? ?? 'action',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetUrl: json['targetUrl'] as String?,
      count: json['count'] as int?,
    );
  }
}
