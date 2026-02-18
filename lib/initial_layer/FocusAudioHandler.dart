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
    await _player.resume();
    playbackState.add(
      playbackState.value.copyWith(
        playing: true,
        controls: [MediaControl.pause, MediaControl.stop],
        processingState: AudioProcessingState.ready,
      ),
    );
    // Explicitly sync back to the block
    try {
      _focusBlock?.startTimer(fromSystem: true);
    } catch (e) {
      print("FocusAudioHandler: Error syncing play: $e");
    }
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    playbackState.add(
      playbackState.value.copyWith(
        playing: false,
        controls: [MediaControl.play, MediaControl.stop],
      ),
    );
    // Explicitly sync back to the block
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
    print("FocusAudioHandler: updateMetadata - $title, $artist");
    mediaItem.add(
      MediaItem(
        id: 'focus_session',
        album: 'ICE Gate Focus',
        title: title,
        artist: artist,
        duration: duration,
      ),
    );
    if (position != null) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    }
  }
}
