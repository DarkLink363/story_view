import 'package:rxdart/rxdart.dart';

enum PlaybackState { pause, play, next, previous, lock, unlock, videoFinished }

/// Controller to sync playback between animated child (story) views. This
/// helps make sure when stories are paused, the animation (gifs/slides) are
/// also paused.
/// Another reason for using the controller is to place the stories on `paused`
/// state when a media is loading.
class StoryController {
  /// Stream that broadcasts the playback state of the stories.
  final playbackNotifier = BehaviorSubject<PlaybackState>();
  final playbackSpeedNotifier = BehaviorSubject<double>.seeded(1.0);

  /// Stream for direct animation value sync from video source (0.0 to 1.0).
  /// Used by video widgets to push drift corrections to the progress bar.
  final animationNotifier = BehaviorSubject<double>();

  /// Notify listeners with a [PlaybackState.pause] state
  void pause() {
    _addPlayback(PlaybackState.pause);
  }

  /// Notify listeners with a [PlaybackState.lock] state
  void lock() {
    _addPlayback(PlaybackState.lock);
  }

  /// Notify listeners with a [PlaybackState.unlock] state
  void unlock() {
    _addPlayback(PlaybackState.unlock);
  }

  /// Notify listeners with a [PlaybackState.play] state
  void play() {
    _addPlayback(PlaybackState.play);
  }

  void next() {
    _addPlayback(PlaybackState.next);
  }

  void previous() {
    _addPlayback(PlaybackState.previous);
  }

  /// Notify that the video has finished playing. This replaces the timer-based
  /// AnimationController completion for video slides.
  void videoFinished() {
    _addPlayback(PlaybackState.videoFinished);
  }

  /// Push an animation progress value (0.0 to 1.0) for drift correction.
  /// Only values that differ significantly from the current UI value will
  /// be applied (handled in StoryViewState).
  void syncAnimation(double value) {
    if (animationNotifier.isClosed) return;
    animationNotifier.add(value);
  }

  /// Ustawia prędkość odtwarzania; po [dispose] nic nie robi.
  void setPlaybackSpeed(double value) {
    if (playbackSpeedNotifier.isClosed) return;
    playbackSpeedNotifier.add(value);
  }

  /// Gesty i timery widgetu mogą odpalić się już po [dispose] kontrolera
  /// (np. tapnięcie w trakcie zamykania stories). Dodanie zdarzenia do
  /// zamkniętego strumienia rzucało wtedy `StateError`.
  void _addPlayback(PlaybackState state) {
    if (playbackNotifier.isClosed) return;
    playbackNotifier.add(state);
  }

  /// Remember to call dispose when the story screen is disposed to close
  /// the notifier stream.
  void dispose() {
    playbackNotifier.close();
    playbackSpeedNotifier.close();
    animationNotifier.close();
  }
}
