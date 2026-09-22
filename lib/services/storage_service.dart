import 'package:hive_flutter/hive_flutter.dart';
import '../models/session_result.dart';

class StorageService {
  static const String _sessionBoxName = 'sessions';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SessionResultAdapter());
    await Hive.openBox<SessionResult>(_sessionBoxName);
  }

  static Box<SessionResult> get _box =>
      Hive.box<SessionResult>(_sessionBoxName);

  static Future<void> saveSession(SessionResult session) async {
    await _box.put(session.id, session);
  }

  static List<SessionResult> getAllSessions() {
    final sessions = _box.values.toList();
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  static Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }

  static Future<void> clearAllSessions() async {
    await _box.clear();
  }

  static int get sessionCount => _box.length;
}
