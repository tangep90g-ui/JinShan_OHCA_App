import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hsinchu_ohca_app/domain/models/ohca_session.dart';

class SessionRepository {
  static const String _keyActiveSession = 'active_ohca_session';
  static const String _keySessionHistory = 'ohca_session_history';

  Future<void> saveActiveSession(OhcaSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(session.toJson());
    await prefs.setString(_keyActiveSession, jsonStr);
  }

  Future<OhcaSession?> getActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyActiveSession);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return OhcaSession.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveSession);
  }

  Future<void> archiveSession(OhcaSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList(_keySessionHistory) ?? [];
    final jsonStr = jsonEncode(session.toJson());
    historyList.insert(0, jsonStr);
    // 限制最多保存 50 筆近期歷史案件
    if (historyList.length > 50) {
      historyList.removeRange(50, historyList.length);
    }
    await prefs.setStringList(_keySessionHistory, historyList);
    await clearActiveSession();
  }

  Future<List<OhcaSession>> getHistorySessions() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList(_keySessionHistory) ?? [];
    final List<OhcaSession> sessions = [];
    for (final item in historyList) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        sessions.add(OhcaSession.fromJson(map));
      } catch (_) {}
    }
    return sessions;
  }
}
