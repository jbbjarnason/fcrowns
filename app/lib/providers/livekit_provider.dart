import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

import '../services/api_service.dart';

/// Manages LiveKit audio/video for the game room
class LiveKitProvider extends ChangeNotifier {
  Room? _room;
  LocalParticipant? _localParticipant;
  bool _audioEnabled = true;
  bool _videoEnabled = false;
  String? _activePlayerId;
  String? _error;
  bool _disposed = false;

  // Getters
  Room? get room => _room;
  bool get isConnected => _room?.connectionState == ConnectionState.connected;
  bool get audioEnabled => _audioEnabled;
  bool get videoEnabled => _videoEnabled;
  String? get activePlayerId => _activePlayerId;
  String? get error => _error;

  // Get remote participants
  List<RemoteParticipant> get remoteParticipants =>
      _room?.remoteParticipants.values.toList() ?? [];

  // Get the active player's video track (if publishing)
  VideoTrack? get activePlayerVideoTrack {
    if (_activePlayerId == null || _room == null) return null;

    // Check if active player is local
    if (_localParticipant?.identity == _activePlayerId) {
      final track = _localParticipant?.videoTrackPublications.firstOrNull;
      return track?.track as VideoTrack?;
    }

    // Check remote participants
    final participant = _room!.remoteParticipants[_activePlayerId];
    if (participant != null) {
      final track = participant.videoTrackPublications.firstOrNull;
      return track?.track as VideoTrack?;
    }

    return null;
  }

  /// Connect to the LiveKit room for a game
  Future<void> connect({
    required ApiService api,
    required String gameId,
  }) async {
    try {
      _error = null;

      // Get LiveKit token from server
      final data = await api.getLivekitToken(gameId);

      if (data == null) {
        _error = 'Failed to get LiveKit token';
        notifyListeners();
        return;
      }

      final url = data['url'] as String;
      final token = data['token'] as String;

      // Create room with options
      _room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: AudioPublishOptions(
            dtx: true,
          ),
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: true,
          ),
        ),
      );

      // Set up event listeners
      _room!.addListener(_onRoomEvent);

      // Connect
      await _room!.connect(url, token);

      _localParticipant = _room!.localParticipant;

      // Enable microphone by default
      await _localParticipant?.setMicrophoneEnabled(true);
      _audioEnabled = true;

      notifyListeners();
    } catch (e) {
      _error = 'Failed to connect to LiveKit: $e';
      notifyListeners();
    }
  }

  /// Disconnect from the room
  Future<void> disconnect() async {
    if (_disposed) return;
    await _room?.disconnect();
    _room?.removeListener(_onRoomEvent);
    _room = null;
    _localParticipant = null;
    _activePlayerId = null;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _room?.disconnect();
    _room?.removeListener(_onRoomEvent);
    super.dispose();
  }

  /// Toggle microphone
  Future<void> toggleAudio() async {
    if (_localParticipant == null) return;

    _audioEnabled = !_audioEnabled;
    await _localParticipant!.setMicrophoneEnabled(_audioEnabled);
    notifyListeners();
  }

  /// Set the active player (who should publish video)
  Future<void> setActivePlayer(String playerId) async {
    if (_activePlayerId == playerId) return;

    _activePlayerId = playerId;

    // Only publish video if we are the active player
    if (_localParticipant?.identity == playerId) {
      if (!_videoEnabled) {
        _videoEnabled = true;
        await _localParticipant?.setCameraEnabled(true);
      }
    } else {
      // Stop our video if we're not the active player
      if (_videoEnabled) {
        _videoEnabled = false;
        await _localParticipant?.setCameraEnabled(false);
      }
    }

    notifyListeners();
  }

  /// Mute audio
  Future<void> muteAudio() async {
    _audioEnabled = false;
    await _localParticipant?.setMicrophoneEnabled(false);
    notifyListeners();
  }

  /// Unmute audio
  Future<void> unmuteAudio() async {
    _audioEnabled = true;
    await _localParticipant?.setMicrophoneEnabled(true);
    notifyListeners();
  }

  void _onRoomEvent() {
    // Room state changed
    if (!_disposed) notifyListeners();
  }
}
