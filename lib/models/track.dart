class Track {
  static const String idField = '_id';
  static const String createdField = 'created';
  Track({
    this.id,
    required this.created,
  });

  String? id;
  DateTime created;

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        id: json[idField],
        created: json[createdField],
      );

  Map<String, dynamic> toJson() => {
        idField: id,
        createdField: created.toIso8601String(),
      };
}
