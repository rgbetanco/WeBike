class Track {
  static const String idField = '_id';
  static const String createdField = 'created';
  Track({
    required this.id,
    required this.created,
  });

  int id;
  String created;

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        id: json[idField],
        created: json[createdField],
      );

  Map<String, dynamic> toJson() => {
        idField: id,
        createdField: created,
      };
}
