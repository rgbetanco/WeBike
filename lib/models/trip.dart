import 'trip_location.dart';
import 'chat_user.dart';

class Trip {
  final String uid;
  String title;
  String imageURL;
  final List<ChatUser> members;
  List<TripLocation> locations;

  Trip({
    required this.uid,
    required this.title,
    required this.imageURL,
    required this.members,
    required this.locations,
  });
}
