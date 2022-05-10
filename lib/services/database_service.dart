import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:pizarro_app/models/chat_message.dart';
import 'package:pizarro_app/models/gps_data.dart';
import 'package:pizarro_app/models/stream_key.dart';
import 'package:pizarro_app/services/mux_service.dart';
import 'package:pizarro_app/services/sqlite.dart';

const String DEFAULT_PROFILE_IMAGE = "https://i.pravatar.cc/150?img=65";
const String USER_COLLECTION = "Users";
const String CHAT_COLLECTION = "Chats";
const String MESSAGE_COLLECTION = "messages";
const String MUX_COLLECTION = "Mux";
const String GPS_COLLECTION = "GPS";

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService() {}

  Future<void> createUser(String _uid, String _email, String _name,
      String _imageURL, MuxService _mux) async {
    String? token = await getMuxToken();
    StreamKey? streamKey = await _mux.createLiveStream(token);
    try {
      await _db.collection(USER_COLLECTION).doc(_uid).set(
        {
          "name": _name,
          "email": _email,
          "image": _imageURL,
          "playbackId": streamKey?.streamKey ?? "",
          "streamKey": streamKey?.playbackId ?? "",
          "broadcaster": true,
          "last_active": DateTime.now().toUtc(),
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<String?> getMuxToken() async {
    return _db
        .collection(MUX_COLLECTION)
        .doc("K4Px75Ub003siKJmyeqN")
        .get()
        .then((doc) {
      if (doc.exists) {
        return 'Basic ' + doc.data()!["basic"];
      } else {
        return null;
      }
    });
  }

  Future<QuerySnapshot> getUsers({String? name}) {
    Query _query = _db.collection(USER_COLLECTION);
    if (name != null) {
      _query = _query
          .where("name", isGreaterThanOrEqualTo: name)
          .where("name", isLessThanOrEqualTo: name + "z");
    }

    return _query.get();
  }

  Future<DocumentSnapshot> getUser(String _uid) async {
    return _db.collection(USER_COLLECTION).doc(_uid).get();
  }

  Future<List?> getUserFromStreamKey(String _playbackId) async {
    return _db
        .collection(USER_COLLECTION)
        .where("streamKey", isEqualTo: _playbackId)
        .get()
        .then((query) {
      if (query.docs.isNotEmpty) {
        return [
          query.docs[0].id,
          query.docs[0].data()["image"],
          query.docs[0].data()["name"]
        ];
      } else {
        return null;
      }
    });
  }

  Future<String?> getUserStreamKey(String _uid) async {
    return _db.collection(USER_COLLECTION).doc(_uid).get().then((doc) {
      if (doc.exists) {
        return doc.data()!["streamKey"];
      } else {
        return null;
      }
    });
  }

  Future<String?> getUserPlaybackId(String _uid) async {
    return _db.collection(USER_COLLECTION).doc(_uid).get().then((doc) {
      if (doc.exists) {
        return doc.data()!["playbackId"];
      } else {
        return null;
      }
    });
  }

  Stream<QuerySnapshot> getChatsForUser(String _uid) {
    return _db
        .collection(CHAT_COLLECTION)
        .where('members', arrayContains: _uid)
        .snapshots();
  }

  Future<QuerySnapshot> getLastMessageForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGE_COLLECTION)
        .orderBy("sent_time", descending: true)
        .limit(1)
        .get();
  }

  Stream<QuerySnapshot> streamMessagesForChat(String _chatID) {
    return _db
        .collection(CHAT_COLLECTION)
        .doc(_chatID)
        .collection(MESSAGE_COLLECTION)
        .orderBy("sent_time", descending: false)
        .snapshots();
  }

  Future<void> addMessageToChat(String _chatID, ChatMessage _message) async {
    try {
      await _db
          .collection(CHAT_COLLECTION)
          .doc(_chatID)
          .collection(MESSAGE_COLLECTION)
          .add(
            _message.toJson(),
          );
    } catch (e) {
      print(e);
    }
  }

  Future<int> addTrackToUser(String _uid, List<GpsData> _data) async {
    /// Initialize sq-lite
    final db = SqliteDB();
    //TODO: read database GPS data
    print(await db.countTable());
    return 1;
    //TODO: send data to firebase
    // try {
    //   return await _db
    //       .collection(USER_COLLECTION)
    //       .doc(_uid)
    //       .collection(GPS_COLLECTION)
    //       .add({"data": jsonEncode(_data)});
    // } catch (e) {
    //   print(e);
    // }
  }

  Future<QuerySnapshot> getTrackOfUser(String _uid) async {
    return await _db
        .collection(USER_COLLECTION)
        .doc(_uid)
        .collection(GPS_COLLECTION)
        .get();
  }

  Future<void> updateUserProfileImage(String _uid, String imageURL) async {
    try {
      _db.collection(USER_COLLECTION).doc(_uid).update(
        {
          "image": imageURL,
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateChatData(
      String _chatID, Map<String, dynamic> _data) async {
    try {
      _db.collection(CHAT_COLLECTION).doc(_chatID).update(_data);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUserLastSeenTime(String _uid) async {
    try {
      _db.collection(USER_COLLECTION).doc(_uid).update({
        "last_active": DateTime.now().toUtc(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteChat(String _chatID) async {
    try {
      _db.collection(CHAT_COLLECTION).doc(_chatID).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentReference?> createChat(Map<String, dynamic> _data) async {
    try {
      return await _db.collection(CHAT_COLLECTION).add(_data);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
