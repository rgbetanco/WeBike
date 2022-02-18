class PlaybackId {
  String? userId;
  String? profilePhotoUrl;
  String? name;
  bool isActive = false;
  final String playbackId;
  PlaybackId({
    this.userId,
    this.profilePhotoUrl,
    this.name,
    required this.isActive,
    required this.playbackId,
  });
}
