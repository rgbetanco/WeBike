class GpsData {
  GpsData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.speedAccuracy,
    required this.heading,
    required this.accuracy,
    required this.timestamp,
  });

  double latitude;
  double longitude;
  double altitude;
  double speed;
  double speedAccuracy;
  double heading;
  double accuracy;
  DateTime timestamp;

  factory GpsData.fromJson(Map<String, dynamic> json) => GpsData(
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        altitude: json["altitude"].toDouble(),
        speed: json["speed"].toDouble(),
        speedAccuracy: json["speedAccuracy"].toDouble(),
        heading: json["heading"].toDouble(),
        accuracy: json["accuracy"].toDouble(),
        timestamp: DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "altitude": altitude,
        "speed": speed,
        "speedAccuracy": speedAccuracy,
        "heading": heading,
        "accuracy": accuracy,
        "timestamp": timestamp.toIso8601String(),
      };
}
