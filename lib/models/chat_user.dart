import 'package:location/location.dart';

class ChatUser {
  final String uid;
  final String name;
  final String email;
  final String imageURL;
  final String playbackId;
  final String streamKey;
  late DateTime lastActive;
  late String? lat;
  late String? long;

  ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageURL,
    required this.playbackId,
    required this.streamKey,
    required this.lastActive,
    required this.lat,
    required this.long,
  });

  factory ChatUser.fromJSON(Map<String, dynamic> _json) {
    return ChatUser(
      uid: _json["uid"],
      name: _json["name"],
      email: _json["email"],
      imageURL: _json["image"],
      playbackId: _json["playbackId"],
      streamKey: _json["streamKey"],
      lastActive: _json["last_active"].toDate(),
      lat: _json["lat"],
      long: _json["long"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "last_active": lastActive,
      "image": imageURL,
      "payloadId": playbackId,
      "streamKey": streamKey,
      "lat": lat,
      "long": long,
    };
  }

  String lastDayActive() {
    return "${lastActive.month}/${lastActive.day}/${lastActive.year}";
  }

  bool wasRecentlyActive() {
    return DateTime.now().difference(lastActive).inHours < 2;
  }
}
