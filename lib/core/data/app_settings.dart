import 'app_database.dart';

/// Setting keys + helpers built on top of [AppDatabase.settings].
class SettingsKeys {
  SettingsKeys._();
  static const activeClassIds = 'active_class_ids';
  static const clockIn = 'clock_in_time';
  static const clockOut = 'clock_out_time';
  static const lastCheckOut = 'last_check_out_time';
  static const deviceName = 'device_name';
  static const soundOnScan = 'sound_on_scan';
}

class AppSettings {
  AppSettings({
    required this.activeClassIds,
    required this.clockIn,
    required this.clockOut,
    required this.lastCheckOut,
    required this.deviceName,
    required this.soundOnScan,
  });

  /// Class IDs that this terminal will recognise (empty = all).
  final List<int> activeClassIds;

  /// Time-of-day strings in HH:mm 24-hour format.
  final String clockIn;
  final String clockOut;

  /// After this time, students who never checked-out are marked absent
  /// and the day's record is not saved to reports.
  final String lastCheckOut;

  final String deviceName;
  final String soundOnScan;

  static const defaults = <String, String>{
    SettingsKeys.activeClassIds: '',
    SettingsKeys.clockIn: '07:00',
    SettingsKeys.clockOut: '15:30',
    SettingsKeys.lastCheckOut: '18:00',
    SettingsKeys.deviceName: 'Terminal 1',
    SettingsKeys.soundOnScan: 'soft_chime',
  };

  AppSettings copyWith({
    List<int>? activeClassIds,
    String? clockIn,
    String? clockOut,
    String? lastCheckOut,
    String? deviceName,
    String? soundOnScan,
  }) {
    return AppSettings(
      activeClassIds: activeClassIds ?? this.activeClassIds,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      lastCheckOut: lastCheckOut ?? this.lastCheckOut,
      deviceName: deviceName ?? this.deviceName,
      soundOnScan: soundOnScan ?? this.soundOnScan,
    );
  }

  Map<String, String> toMap() => {
        SettingsKeys.activeClassIds: activeClassIds.join(','),
        SettingsKeys.clockIn: clockIn,
        SettingsKeys.clockOut: clockOut,
        SettingsKeys.lastCheckOut: lastCheckOut,
        SettingsKeys.deviceName: deviceName,
        SettingsKeys.soundOnScan: soundOnScan,
      };
}

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  Future<AppSettings> load() async {
    final raw = await AppDatabase.instance.loadSettings();
    final ids = raw
        .get(SettingsKeys.activeClassIds,
            AppSettings.defaults[SettingsKeys.activeClassIds]!)
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
    return AppSettings(
      activeClassIds: ids,
      clockIn:
          raw.get(SettingsKeys.clockIn, AppSettings.defaults[SettingsKeys.clockIn]!),
      clockOut: raw.get(
          SettingsKeys.clockOut, AppSettings.defaults[SettingsKeys.clockOut]!),
      lastCheckOut: raw.get(SettingsKeys.lastCheckOut,
          AppSettings.defaults[SettingsKeys.lastCheckOut]!),
      deviceName: raw.get(SettingsKeys.deviceName,
          AppSettings.defaults[SettingsKeys.deviceName]!),
      soundOnScan: raw.get(SettingsKeys.soundOnScan,
          AppSettings.defaults[SettingsKeys.soundOnScan]!),
    );
  }

  Future<void> save(AppSettings s) async {
    await AppDatabase.instance.setSettings(s.toMap());
  }

  Future<void> ensureDefaults() async {
    final current = await AppDatabase.instance.loadSettings();
    final missing = <String, String>{};
    AppSettings.defaults.forEach((k, v) {
      if (current[k] == null) missing[k] = v;
    });
    if (missing.isNotEmpty) {
      await AppDatabase.instance.setSettings(missing);
    }
  }
}

/// Sound options offered in Settings → Sound on scan.
const kSoundOptions = <String, String>{
  'soft_chime': 'Soft chime',
  'beep': 'Beep',
  'success_ding': 'Success ding',
  'silent': 'Silent',
};
