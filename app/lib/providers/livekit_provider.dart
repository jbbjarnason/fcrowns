import 'package:flutter/widgets.dart';
import 'package:livekit_client/livekit_client.dart' as livekit;

import '../services/api_service.dart';

/// Manages LiveKit audio/video for the game room
class LiveKitProvider extends ChangeNotifier with WidgetsBindingObserver {
  livekit.Room? _room;
  livekit.LocalParticipant? _localParticipant;
  bool _audioEnabled = true;
  bool _videoEnabled = false;
  bool _speakerEnabled = true; // Whether to hear other players
  String? _activePlayerId;
  String? _error;
  bool _disposed = false;

  // For reconnection after app lifecycle
  ApiService? _api;
  String? _gameId;
  bool _wasConnected = false;

  // Getters
  livekit.Room? get room => _room;
  bool get isConnected =>
      _room?.connectionState == livekit.ConnectionState.connected;
  bool get audioEnabled => _audioEnabled;
  bool get videoEnabled => _videoEnabled;
  bool get speakerEnabled => _speakerEnabled;
  String? get activePlayerId => _activePlayerId;
  String? get error => _error;

  // Get remote participants
  List<livekit.RemoteParticipant> get remoteParticipants =>
      _room?.remoteParticipants.values.toList() ?? [];

  // Get the active player's video track (if publishing)
  livekit.VideoTrack? get activePlayerVideoTrack {
    if (_activePlayerId == null || _room == null) {
      debugPrint('[LiveKit] activePlayerVideoTrack: no active player or room');
      return null;
    }

    // Check if active player is local
    if (_localParticipant?.identity == _activePlayerId) {
      final publications = _localParticipant?.videoTrackPublications ?? [];
      debugPrint('[LiveKit] Local participant video publications: ${publications.length}');
      for (final pub in publications) {
        debugPrint('[LiveKit] - Publication: ${pub.sid}, track: ${pub.track}, subscribed: ${pub.subscribed}');
      }
      final track = publications.firstOrNull?.track as livekit.VideoTrack?;
      debugPrint('[LiveKit] Returning local video track: $track');
      return track;
    }

    // Check remote participants
    final participant = _room!.remoteParticipants[_activePlayerId];
    if (participant != null) {
      final publications = participant.videoTrackPublications;
      debugPrint('[LiveKit] Remote participant $_activePlayerId video publications: ${publications.length}');
      final track = publications.firstOrNull?.track as livekit.VideoTrack?;
      debugPrint('[LiveKit] Returning remote video track: $track');
      return track;
    }

    debugPrint('[LiveKit] No video track found for active player: $_activePlayerId');
    return null;
  }

  LiveKitProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[LiveKit] App lifecycle state changed: $state');

    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    } else if (state == AppLifecycleState.paused) {
      _wasConnected = isConnected;
      debugPrint('[LiveKit] App paused, wasConnected: $_wasConnected');
    }
  }

  Future<void> _handleAppResumed() async {
    debugPrint('[LiveKit] App resumed, wasConnected: $_wasConnected, currentlyConnected: $isConnected');

    if (_disposed) return;

    // Give the room a moment to detect its state
    await Future.delayed(const Duration(milliseconds: 500));

    if (_disposed) return;

    // Check if we need to reconnect
    if (_wasConnected && !isConnected && _api != null && _gameId != null) {
      debugPrint('[LiveKit] Connection lost during background, attempting reconnect...');
      await reconnect();
    } else if (isConnected) {
      // Connection is still active, but video track may need re-enabling
      debugPrint('[LiveKit] Still connected, checking video state...');
      await _recoverVideoIfNeeded();
    }
  }

  Future<void> _recoverVideoIfNeeded() async {
    if (_localParticipant == null) return;

    // If we are the active player, ensure camera is enabled
    if (_activePlayerId == _localParticipant?.identity && _videoEnabled) {
      final hasVideoTrack = _localParticipant!.videoTrackPublications.isNotEmpty;
      debugPrint('[LiveKit] Video recovery check: should have video=$_videoEnabled, hasTrack=$hasVideoTrack');

      if (!hasVideoTrack) {
        debugPrint('[LiveKit] Re-enabling camera after app resume');
        await _localParticipant?.setCameraEnabled(false);
        await Future.delayed(const Duration(milliseconds: 100));
        await _localParticipant?.setCameraEnabled(true);
        notifyListeners();
      }
    }
  }

  /// Reconnect to LiveKit (used after app lifecycle or manual retry)
  Future<bool> reconnect() async {
    if (_api == null || _gameId == null) {
      debugPrint('[LiveKit] Cannot reconnect: missing api or gameId');
      return false;
    }

    // Preserve user's mute preferences before reconnecting
    final wasAudioEnabled = _audioEnabled;
    final wasSpeakerEnabled = _speakerEnabled;
    debugPrint('[LiveKit] Reconnecting... preserving audio=$wasAudioEnabled, speaker=$wasSpeakerEnabled');

    // Disconnect existing room if any
    try {
      await _room?.disconnect();
      _room?.removeListener(_onRoomEvent);
    } catch (e) {
      debugPrint('[LiveKit] Error during disconnect before reconnect: $e');
    }

    _room = null;
    _localParticipant = null;

    // Reconnect (this will enable mic by default)
    await connect(api: _api!, gameId: _gameId!);

    // Restore user's mute preferences
    if (isConnected) {
      if (!wasAudioEnabled) {
        debugPrint('[LiveKit] Restoring muted mic state');
        await muteAudio();
      }
      if (!wasSpeakerEnabled) {
        debugPrint('[LiveKit] Restoring muted speaker state');
        // Re-apply speaker mute by toggling twice (to trigger unsubscribe)
        _speakerEnabled = true; // Reset so toggle will disable
        await toggleSpeaker();
      }
    }

    return isConnected;
  }

  /// Connect to the LiveKit room for a game
  Future<void> connect({
    required ApiService api,
    required String gameId,
  }) async {
    try {
      _error = null;
      _api = api;
      _gameId = gameId;
      debugPrint('[LiveKit] Connecting to room for game: $gameId');

      // Get LiveKit token from server
      final data = await api.getLivekitToken(gameId);

      if (data == null) {
        _error = 'Failed to get LiveKit token';
        debugPrint('[LiveKit] Failed to get token from server');
        notifyListeners();
        return;
      }

      final url = data['url'] as String;
      final token = data['token'] as String;
      debugPrint('[LiveKit] Got token, connecting to: $url');

      // Create room with options
      _room = livekit.Room(
        roomOptions: livekit.RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          // Auto-subscribe to tracks - we'll manage speaker state separately
          defaultAudioCaptureOptions: const livekit.AudioCaptureOptions(
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
          ),
          defaultAudioPublishOptions: const livekit.AudioPublishOptions(
            dtx: true,
          ),
          defaultVideoPublishOptions: const livekit.VideoPublishOptions(
            simulcast: true,
          ),
        ),
      );
      debugPrint('[LiveKit] Room created with options');

      // Set up event listeners
      _room!.addListener(_onRoomEvent);

      // Connect
      await _room!.connect(url, token);

      _localParticipant = _room!.localParticipant;
      debugPrint('[LiveKit] Connected! Local participant: ${_localParticipant?.identity}');

      // Enable microphone by default
      await _localParticipant?.setMicrophoneEnabled(true);
      _audioEnabled = true;
      debugPrint('[LiveKit] Microphone enabled');

      // Check if we are the active player and should enable camera
      // (setActivePlayer may have been called before we connected)
      if (_activePlayerId != null && _localParticipant?.identity == _activePlayerId) {
        debugPrint('[LiveKit] I am the active player - enabling camera after connect');
        _videoEnabled = true;
        await _localParticipant?.setCameraEnabled(true);
        debugPrint('[LiveKit] Camera enabled, video publications: ${_localParticipant?.videoTrackPublications.length}');
      }

      notifyListeners();
    } catch (e, stack) {
      _error = 'Failed to connect to LiveKit: $e';
      debugPrint('[LiveKit] Connection error: $e');
      debugPrint('[LiveKit] Stack: $stack');
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
    WidgetsBinding.instance.removeObserver(this);
    _room?.disconnect();
    _room?.removeListener(_onRoomEvent);
    super.dispose();
  }

  /// Toggle microphone
  Future<void> toggleAudio() async {
    debugPrint('[LiveKit] toggleAudio called, current: $_audioEnabled, localParticipant: ${_localParticipant != null}');
    if (_localParticipant == null) {
      debugPrint('[LiveKit] toggleAudio: no local participant, aborting');
      return;
    }

    _audioEnabled = !_audioEnabled;
    debugPrint('[LiveKit] toggleAudio: setting mic to $_audioEnabled');
    await _localParticipant!.setMicrophoneEnabled(_audioEnabled);
    debugPrint('[LiveKit] toggleAudio: mic set, audio publications: ${_localParticipant!.audioTrackPublications.length}');
    notifyListeners();
  }

  /// Set the active player (who should publish video)
  Future<void> setActivePlayer(String playerId) async {
    debugPrint('[LiveKit] setActivePlayer: $playerId (current: $_activePlayerId, local: ${_localParticipant?.identity})');
    if (_activePlayerId == playerId) return;

    _activePlayerId = playerId;

    // Only publish video if we are the active player
    if (_localParticipant?.identity == playerId) {
      debugPrint('[LiveKit] I am the active player - enabling camera');
      if (!_videoEnabled) {
        _videoEnabled = true;
        await _localParticipant?.setCameraEnabled(true);
        debugPrint('[LiveKit] Camera enabled, video publications: ${_localParticipant?.videoTrackPublications.length}');
      }
    } else {
      // Stop our video if we're not the active player
      debugPrint('[LiveKit] Someone else is active - disabling my camera');
      if (_videoEnabled) {
        _videoEnabled = false;
        await _localParticipant?.setCameraEnabled(false);
      }
    }

    notifyListeners();
  }

  /// Mute audio
  Future<void> muteAudio() async {
    debugPrint('[LiveKit] muteAudio called');
    _audioEnabled = false;
    await _localParticipant?.setMicrophoneEnabled(false);
    debugPrint('[LiveKit] muteAudio: mic disabled');
    notifyListeners();
  }

  /// Unmute audio
  Future<void> unmuteAudio() async {
    debugPrint('[LiveKit] unmuteAudio called');
    _audioEnabled = true;
    await _localParticipant?.setMicrophoneEnabled(true);
    debugPrint('[LiveKit] unmuteAudio: mic enabled');
    notifyListeners();
  }

  /// Toggle speaker (hear other players)
  Future<void> toggleSpeaker() async {
    debugPrint('[LiveKit] toggleSpeaker called, current: $_speakerEnabled');
    _speakerEnabled = !_speakerEnabled;
    debugPrint('[LiveKit] toggleSpeaker: setting speaker to $_speakerEnabled');

    // Subscribe/unsubscribe from remote audio tracks to enable/disable hearing them
    for (final participant in _room?.remoteParticipants.values ?? <livekit.RemoteParticipant>[]) {
      debugPrint('[LiveKit] toggleSpeaker: processing participant ${participant.identity}, audio pubs: ${participant.audioTrackPublications.length}');
      for (final pub in participant.audioTrackPublications) {
        if (_speakerEnabled) {
          // Subscribe to hear audio
          await pub.subscribe();
        } else {
          // Unsubscribe to stop hearing audio
          await pub.unsubscribe();
        }
      }
    }

    debugPrint('[LiveKit] toggleSpeaker: done');
    notifyListeners();
  }

  void _onRoomEvent() {
    // Room state changed
    debugPrint('[LiveKit] Room event fired - connection: ${_room?.connectionState}, remoteParticipants: ${_room?.remoteParticipants.length}');

    // Log and manage remote participant audio tracks
    for (final participant in _room?.remoteParticipants.values ?? <livekit.RemoteParticipant>[]) {
      for (final pub in participant.audioTrackPublications) {
        debugPrint('[LiveKit] Remote audio track: ${participant.identity}, subscribed: ${pub.subscribed}, muted: ${pub.muted}, speakerEnabled: $_speakerEnabled');

        // If speaker is disabled and track is subscribed, unsubscribe
        if (!_speakerEnabled && pub.subscribed) {
          debugPrint('[LiveKit] Speaker disabled but track subscribed - unsubscribing');
          pub.unsubscribe();
        }
      }
    }

    if (!_disposed) notifyListeners();
  }
}
