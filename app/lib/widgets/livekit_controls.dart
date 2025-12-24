import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Audio controls and active player video feed
class LiveKitControls extends ConsumerWidget {
  final String gameId;
  final String? activePlayerId;

  const LiveKitControls({
    super.key,
    required this.gameId,
    this.activePlayerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livekit = ref.watch(liveKitProvider);

    // Update active player when it changes
    if (activePlayerId != null && activePlayerId != livekit.activePlayerId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(liveKitProvider).setActivePlayer(activePlayerId!);
      });
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mic toggle button
        _AudioButton(isEnabled: livekit.audioEnabled),
        const SizedBox(width: 4),
        // Speaker toggle button
        _SpeakerButton(isEnabled: livekit.speakerEnabled),
        const SizedBox(width: 8),
        // Connection status indicator
        _ConnectionIndicator(isConnected: livekit.isConnected),
      ],
    );
  }
}

class _AudioButton extends ConsumerStatefulWidget {
  final bool isEnabled;

  const _AudioButton({required this.isEnabled});

  @override
  ConsumerState<_AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends ConsumerState<_AudioButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AudioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEnabled != widget.isEnabled) {
      // Animate on state change
      _animController.forward().then((_) => _animController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isEnabled
              ? AppTheme.success.withValues(alpha: 0.15)
              : AppTheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: Icon(
            widget.isEnabled ? Icons.mic : Icons.mic_off,
            color: widget.isEnabled ? AppTheme.success : AppTheme.error,
          ),
          onPressed: () {
            _animController.forward().then((_) => _animController.reverse());
            ref.read(liveKitProvider).toggleAudio();
          },
          tooltip: widget.isEnabled ? 'Mute microphone' : 'Unmute microphone',
        ),
      ),
    );
  }
}

class _SpeakerButton extends ConsumerWidget {
  final bool isEnabled;

  const _SpeakerButton({required this.isEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: isEnabled
            ? AppTheme.success.withValues(alpha: 0.15)
            : AppTheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          isEnabled ? Icons.volume_up : Icons.volume_off,
          color: isEnabled ? AppTheme.success : AppTheme.error,
        ),
        onPressed: () => ref.read(liveKitProvider).toggleSpeaker(),
        tooltip: isEnabled ? 'Mute speakers' : 'Unmute speakers',
      ),
    );
  }
}

class _ConnectionIndicator extends StatelessWidget {
  final bool isConnected;

  const _ConnectionIndicator({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isConnected ? AppTheme.success : AppTheme.error,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Video widget for active player
class ActivePlayerVideo extends ConsumerWidget {
  const ActivePlayerVideo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livekit = ref.watch(liveKitProvider);
    final videoTrack = livekit.activePlayerVideoTrack;

    debugPrint('[ActivePlayerVideo] videoTrack: $videoTrack, activePlayer: ${livekit.activePlayerId}, connected: ${livekit.isConnected}');

    if (videoTrack == null) {
      return Container(
        width: 140,
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              color: Theme.of(context).disabledColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No video',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Container(
      width: 140,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: VideoTrackRenderer(
          videoTrack,
          fit: VideoViewFit.cover,
        ),
      ),
    );
  }
}

/// Floating participant avatars with audio indicators
class ParticipantAudioIndicators extends ConsumerWidget {
  final List<Map<String, dynamic>> players;
  final String? currentPlayerId;

  const ParticipantAudioIndicators({
    super.key,
    required this.players,
    this.currentPlayerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livekit = ref.watch(liveKitProvider);
    final room = livekit.room;

    if (room == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      children: players.map((player) {
        final playerId = player['id'] as String;
        final isCurrentTurn = playerId == currentPlayerId;

        // Find participant's audio state
        bool isSpeaking = false;
        bool isMuted = true;

        if (room.localParticipant?.identity == playerId) {
          isMuted = !livekit.audioEnabled;
          isSpeaking = room.localParticipant?.isSpeaking ?? false;
        } else {
          final remote = room.remoteParticipants[playerId];
          if (remote != null) {
            isMuted = remote.audioTrackPublications.isEmpty ||
                !(remote.audioTrackPublications.first.subscribed);
            isSpeaking = remote.isSpeaking;
          }
        }

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrentTurn
                ? AppTheme.primary.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSpeaking
                  ? AppTheme.success
                  : isCurrentTurn
                      ? AppTheme.primary
                      : Theme.of(context).dividerColor,
              width: isSpeaking ? 3 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  'P${player['seat'] + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isCurrentTurn ? AppTheme.primary : null,
                  ),
                ),
              ),
              if (isMuted)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.mic_off,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
