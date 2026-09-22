import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_result.dart';
import '../services/storage_service.dart';

class HistoryNotifier extends StateNotifier<List<SessionResult>> {
  HistoryNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.getAllSessions();
  }

  Future<void> saveSession(SessionResult session) async {
    await StorageService.saveSession(session);
    _load();
  }

  Future<void> deleteSession(String id) async {
    await StorageService.deleteSession(id);
    _load();
  }

  Future<void> clearAll() async {
    await StorageService.clearAllSessions();
    _load();
  }

  void refresh() {
    _load();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<SessionResult>>(
      (ref) => HistoryNotifier(),
    );
