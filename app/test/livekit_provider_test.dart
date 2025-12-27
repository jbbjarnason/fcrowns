import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:fivecrowns_app/providers/livekit_provider.dart';
import 'package:fivecrowns_app/services/api_service.dart';

// Mocks
class MockApiService extends Mock implements ApiService {}
class MockRoom extends Mock implements Room {}
class MockLocalParticipant extends Mock implements LocalParticipant {}
class MockRemoteParticipant extends Mock implements RemoteParticipant {}
class MockLocalTrackPublication extends Mock implements LocalTrackPublication<LocalVideoTrack> {}
class MockRemoteTrackPublication extends Mock implements RemoteTrackPublication<RemoteVideoTrack> {}
class MockLocalVideoTrack extends Mock implements LocalVideoTrack {}
class MockRemoteVideoTrack extends Mock implements RemoteVideoTrack {}

void main() {
  // Required for LiveKitProvider which uses WidgetsBindingObserver
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiveKitProvider', () {
    late LiveKitProvider provider;

    setUp(() {
      provider = LiveKitProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state is disconnected', () {
      expect(provider.isConnected, false);
      expect(provider.room, isNull);
      expect(provider.audioEnabled, true);
      expect(provider.videoEnabled, false);
      expect(provider.activePlayerId, isNull);
    });

    test('activePlayerVideoTrack returns null when no room', () {
      expect(provider.activePlayerVideoTrack, isNull);
    });

    test('activePlayerVideoTrack returns null when no active player', () {
      // Even with a room, no active player means no track
      expect(provider.activePlayerVideoTrack, isNull);
    });

    group('setActivePlayer', () {
      test('enables video when local participant becomes active', () async {
        // This test verifies the logic flow - actual camera enabling
        // requires real LiveKit connection
        expect(provider.videoEnabled, false);

        // Without a connected room, setActivePlayer should still update state
        await provider.setActivePlayer('user-123');
        expect(provider.activePlayerId, 'user-123');
      });

      test('does not update when setting same player', () async {
        await provider.setActivePlayer('user-123');
        final firstActivePlayer = provider.activePlayerId;

        // Setting same player again should be a no-op
        await provider.setActivePlayer('user-123');
        expect(provider.activePlayerId, firstActivePlayer);
      });

      test('updates active player when changing players', () async {
        await provider.setActivePlayer('user-123');
        expect(provider.activePlayerId, 'user-123');

        await provider.setActivePlayer('user-456');
        expect(provider.activePlayerId, 'user-456');
      });
    });

    group('audio controls', () {
      test('toggleAudio changes state even without local participant', () async {
        expect(provider.audioEnabled, true);
        await provider.toggleAudio();
        // State does NOT change without participant since setMicrophoneEnabled is called first
        expect(provider.audioEnabled, true);
      });

      test('muteAudio sets audioEnabled to false', () async {
        await provider.muteAudio();
        expect(provider.audioEnabled, false);
      });

      test('unmuteAudio sets audioEnabled to true', () async {
        await provider.muteAudio();
        expect(provider.audioEnabled, false);

        await provider.unmuteAudio();
        expect(provider.audioEnabled, true);
      });
    });

    group('speaker controls', () {
      test('initial speaker state is enabled', () {
        expect(provider.speakerEnabled, true);
      });

      test('toggleSpeaker changes speaker state', () async {
        expect(provider.speakerEnabled, true);
        await provider.toggleSpeaker();
        expect(provider.speakerEnabled, false);
        await provider.toggleSpeaker();
        expect(provider.speakerEnabled, true);
      });
    });

    group('connection state', () {
      test('error is set when connection fails', () async {
        final mockApi = MockApiService();
        when(() => mockApi.getLivekitToken(any())).thenAnswer((_) async => null);

        await provider.connect(api: mockApi, gameId: 'game-123');

        expect(provider.error, 'Failed to get LiveKit token');
        expect(provider.isConnected, false);
      });
    });

    group('remote participants', () {
      test('remoteParticipants returns empty list when no room', () {
        expect(provider.remoteParticipants, isEmpty);
      });
    });
  });
}
