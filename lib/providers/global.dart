class Global {
  String playbackId = "";
  Global() {}
  void set(String id) {
    playbackId = id;
  }

  String get() {
    return playbackId;
  }

  void clear() {
    playbackId = "";
  }
}
