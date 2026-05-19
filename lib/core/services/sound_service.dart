import 'package:audioplayers/audioplayers.dart';

/// Plays a short feedback sound when a scan completes.  Uses bundled WAV
/// files in [assets/sounds/]; if a file is missing we silently no-op so
/// the UI never breaks.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final _player = AudioPlayer(playerId: 'scan_feedback');

  static const _files = <String, String>{
    'soft_chime': 'sounds/soft_chime.mp3',
    'beep': 'sounds/beep.mp3',
    'success_ding': 'sounds/success_ding.mp3',
    'silent': '',
  };

  Future<void> playForKey(String key) async {
    final path = _files[key];
    if (path == null || path.isEmpty) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(path));
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
