import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class FocusAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  // Internal player for actual sound playback
  final AudioPlayer _player = AudioPlayer();

  // Back-reference to the block to sync state
  dynamic _focusBlock;
  set focusBlock(dynamic block) => _focusBlock = block;

  FocusAudioHandler() {
    _player.setReleaseMode(ReleaseMode.loop);

    // Notify the system that we are ready to play
    playbackState.add(
      playbackState.value.copyWith(
        controls: [MediaControl.pause, MediaControl.play, MediaControl.stop],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: false,
      ),
    );
  }

  Future<void> setSource(Source source) async {
    await _player.setSource(source);
  }

  @override
  Future<void> play() async {
    // 1. Update State FIRST to responsive UI
    playbackState.add(
      playbackState.value.copyWith(
        playing: true,
        controls: [MediaControl.pause, MediaControl.stop],
        processingState: AudioProcessingState.ready,
      ),
    );

    // 2. Try to play actual audio (if source is valid)
    try {
      await _player.resume();
    } catch (e) {
      print(
        "FocusAudioHandler: Internal player resume failed (Source might be empty): $e",
      );
      // Don't revert state; we want "silent playback" to continue for lock screen controls
    }

    // 3. Sync back to block
    try {
      _focusBlock?.startTimer(fromSystem: true);
    } catch (e) {
      print("FocusAudioHandler: Error syncing play: $e");
    }
  }

  @override
  Future<void> pause() async {
    // 1. Update State FIRST
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        controls: [MediaControl.play, MediaControl.stop],
      ),
    );

    // 2. Try to pause actual audio
    try {
      await _player.pause();
    } catch (e) {
      print("FocusAudioHandler: Internal player pause failed: $e");
    }

    // 3. Sync back to block
    try {
      _focusBlock?.pauseTimer(fromSystem: true);
    } catch (e) {
      print("FocusAudioHandler: Error syncing pause: $e");
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    await _player.dispose();
    return super.onTaskRemoved();
  }

  void updateMetadata({
    required String title,
    required String artist,
    Duration? duration,
    Duration? position,
  }) {
    print(
      "FocusAudioHandler: updateMetadata - $title, $artist, dur: $duration, pos: $position",
    );

    // Update MediaItem (Static info)
    mediaItem.add(
      MediaItem(
        id: 'focus_session',
        album: 'ICE Gate Focus',
        title: title,
        artist: artist,
        duration: duration,
        // artUri: Uri.parse(
        //   'https://images.unsplash.com/photo-1519681393798-38e36fefce15?auto=format&fit=crop&w=500&q=60',
        // ), // Zen Stones Artwork
      ),
    );

    // Update PlaybackState (Dynamic info)
    if (position != null) {
      playbackState.add(
        playbackState.value.copyWith(
          // Anchor the position to the current system time for smooth scrubbing
          updatePosition: position,
          bufferedPosition: position,
          playing: true, // Ensure it shows as playing
          processingState: AudioProcessingState.ready,
          speed: 1.0,
          queueIndex: 0,
        ),
      );
    }
  }
}
