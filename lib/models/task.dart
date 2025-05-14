class Task {
  final int? id;
  final String title;
  final bool isDone;

  Task({this.id, required this.title, this.isDone = false});

  Task copyWith({int? id, String? title, bool? isDone}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'is_done': isDone ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      isDone: map['is_done'] == 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.isDone == isDone;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ isDone.hashCode;
}
