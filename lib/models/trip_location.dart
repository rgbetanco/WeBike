import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

// DONT USE THIS CLASS
class TripLocation {
  final String senderID;
  final LocationData location;
  final DateTime sentTime;

  TripLocation(
      {required this.senderID, required this.sentTime, required this.location});

  factory TripLocation.fromJSON(Map<String, dynamic> _json) {
    return TripLocation(
      senderID: _json["sender_id"],
      location: _json["location"],
      sentTime: _json["sent_time"].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sender_id": senderID,
      "location": location,
      "sent_time": Timestamp.fromDate(sentTime),
    };
  }
}
