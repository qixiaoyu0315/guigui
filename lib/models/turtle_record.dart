class TurtleRecord {
  final String id;
  final String turtleId; // 所属乌龟的ID
  final DateTime date;
  final String title;
  final String description;
  final double? weight; // 体重 (克)
  final double? length; // 体长 (厘米)
  final double? width; // 体宽 (厘米)
  final String? photoPath; // 照片路径
  final String? notes; // 备注

  TurtleRecord({
    required this.id,
    required this.turtleId,
    required this.date,
    required this.title,
    required this.description,
    this.weight,
    this.length,
    this.width,
    this.photoPath,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'turtleId': turtleId,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'weight': weight,
      'length': length,
      'width': width,
      'photoPath': photoPath,
      'notes': notes,
    };
  }

  factory TurtleRecord.fromJson(Map<String, dynamic> json) {
    return TurtleRecord(
      id: json['id'],
      turtleId: json['turtleId'] ?? '', // 兼容旧数据
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'],
      weight: json['weight']?.toDouble(),
      length: json['length']?.toDouble(),
      width: json['width']?.toDouble(),
      photoPath: json['photoPath'],
      notes: json['notes'],
    );
  }
}
