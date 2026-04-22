import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../database/database_helper.dart';
import '../models/strava_models.dart';
import '../models/usage_log.dart';

class StravaService {
  static final instance = StravaService._();
  StravaService._();

  /// Broadcast for the UI: true while a Strava sync is in progress.
  static final isSyncing = ValueNotifier<bool>(false);

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Hardcoded app credentials ─────────────────────────────────────────────
  // Replace with your actual values from https://www.strava.com/settings/api
  static const _kOwnClientId     = '223075';
  static const _kOwnClientSecret = 'c1279b7bb29910647f6198dfa77352a5c48775ec';

  // Storage keys
  static const _kAccessToken  = 'strava_access_token';
  static const _kRefreshToken = 'strava_refresh_token';
  static const _kExpiresAt    = 'strava_expires_at';

  // API constants
  static const _tokenUrl = 'https://www.strava.com/oauth/token';
  static const _apiBase  = 'https://www.strava.com/api/v3';

  // ── Redirect URI / callback scheme ─────────────────────────────────────────
  //
  // Android/iOS  →  FlutterWebAuth2 + custom URL scheme
  //   redirect_uri  = geartracker://strava-callback
  //   Strava "Authorization Callback Domain" = strava-callback
  //
  // Web (Chrome)  →  same-tab redirect; GoRouter handles /strava-callback
  //   redirect_uri  = http://localhost:PORT/strava-callback  (built at runtime)
  //   Strava "Authorization Callback Domain" = localhost
  //
  // ⚠  Strava allows only ONE callback domain per app, so you must change the
  //    setting depending on which platform you are testing on.
  static const _mobileCallbackScheme = 'geartracker';
  static const _mobileRedirectUri    = 'geartracker://strava-callback';

  /// Web redirect URI – includes the current dev-server port automatically.
  static String get _webRedirectUri => '${Uri.base.origin}/strava-callback';

  // ── Credentials ────────────────────────────────────────────────────────────

  // Credentials are now hardcoded as constants above.
  // saveCredentials / clientId / clientSecret kept only for migration cleanup.
  Future<void> saveCredentials({required String clientId, required String clientSecret}) async {
    // no-op: credentials are compiled in as constants
  }

  Future<String?> get clientId     async => _kOwnClientId;
  Future<String?> get clientSecret async => _kOwnClientSecret;

  Future<bool> hasCredentials() async => true;

  // ── Connection ────────────────────────────────────────────────────────────

  Future<bool> get isConnected async =>
      (await _storage.read(key: _kAccessToken)) != null;

  // ── OAuth entry point ─────────────────────────────────────────────────────

  /// Starts the Strava OAuth2 flow.
  ///
  /// • **Android/iOS**: opens a Chrome Custom Tab via FlutterWebAuth2, waits
  ///   for the `geartracker://` deep-link callback and exchanges the code.
  ///   Returns **null** on success or a Czech error string on failure.
  ///
  /// • **Web**: redirects the whole browser tab to Strava (same-tab flow).
  ///   Returns **null** immediately — the actual result is handled by the
  ///   `/strava-callback` GoRouter route once Strava redirects back.
  Future<String?> connect(BuildContext context) async {
    if (kIsWeb) {
      return _connectWeb(_kOwnClientId);
    } else {
      return _connectMobile(_kOwnClientId, _kOwnClientSecret);
    }
  }

  // ── Web flow ───────────────────────────────────────────────────────────────

  Future<String?> _connectWeb(String cId) async {
    final authUri = Uri.https('www.strava.com', '/oauth/authorize', {
      'client_id':       cId,
      'response_type':   'code',
      'redirect_uri':    _webRedirectUri,
      'approval_prompt': 'auto',
      'scope':           'activity:read_all',
    });

    final launched = await launchUrl(
      authUri,
      webOnlyWindowName: '_self', // same-tab redirect
    );
    if (!launched) return 'Nepodařilo se otevřít Strava přihlašovací stránku.';
    // Page is navigating away → Future effectively abandoned; that's fine.
    return null;
  }

  /// Called by [StravaCallbackScreen] on web after Strava redirects back with
  /// `?code=…`. Exchanges the code and stores the tokens.
  ///
  /// Returns **null** on success, a Czech error string on failure.
  Future<String?> completeWebOAuth(String code) async {
    return _exchangeCode(
      code: code,
      clientId: _kOwnClientId,
      clientSecret: _kOwnClientSecret,
    );
  }

  // ── Mobile flow ────────────────────────────────────────────────────────────

  Future<String?> _connectMobile(String cId, String cSecret) async {
    final authUri = Uri.https('www.strava.com', '/oauth/authorize', {
      'client_id':       cId,
      'response_type':   'code',
      'redirect_uri':    _mobileRedirectUri,
      'approval_prompt': 'auto',
      'scope':           'activity:read_all',
    });

    String resultUrl;
    try {
      resultUrl = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: _mobileCallbackScheme,
      );
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') return null; // user dismissed – silent
      return 'Chyba OAuth okna: ${e.message ?? e.code}';
    } catch (e) {
      return 'Nepodařilo se otevřít přihlašovací okno: $e';
    }

    final callbackUri = Uri.tryParse(resultUrl);
    if (callbackUri == null) {
      return 'Nepodařilo se zpracovat callback URL: $resultUrl';
    }

    final oauthError = callbackUri.queryParameters['error'];
    if (oauthError != null) return 'Strava odmítla přístup: $oauthError';

    final code = callbackUri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      return 'Autorizační kód chybí v callback URL: $resultUrl';
    }

    return _exchangeCode(code: code, clientId: cId, clientSecret: cSecret);
  }

  // ── Token exchange ─────────────────────────────────────────────────────────

  /// Exchanges an authorisation code for tokens.
  /// Returns **null** on success, a Czech error string on failure.
  Future<String?> _exchangeCode({
    required String code,
    required String clientId,
    required String clientSecret,
  }) async {
    http.Response resp;
    try {
      resp = await http
          .post(
            Uri.parse(_tokenUrl),
            body: {
              'client_id':     clientId,
              'client_secret': clientSecret,
              'code':          code,
              'grant_type':    'authorization_code',
            },
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      return 'Síťová chyba při výměně tokenu: $e';
    }

    if (resp.statusCode != 200) {
      String detail = resp.body;
      try {
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        detail  = j['message'] as String? ?? resp.body;
      } catch (_) {}
      return 'Token exchange selhal (HTTP ${resp.statusCode}): $detail';
    }

    Map<String, dynamic> json;
    try {
      json = jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      return 'Nepodařilo se zpracovat odpověď serveru: $e';
    }

    if (!json.containsKey('access_token')) {
      return 'Server nevrátil access_token: ${resp.body}';
    }

    await _storeTokens(json);
    return null; // success
  }

  Future<void> disconnect() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kExpiresAt);
  }

  // ── Token management ──────────────────────────────────────────────────────

  Future<void> _storeTokens(Map<String, dynamic> json) async {
    await _storage.write(key: _kAccessToken,  value: json['access_token']  as String);
    await _storage.write(key: _kRefreshToken, value: json['refresh_token'] as String);
    await _storage.write(key: _kExpiresAt,    value: (json['expires_at'] as int).toString());
  }

  Future<String?> _validToken() async {
    final expiresAtStr = await _storage.read(key: _kExpiresAt);
    if (expiresAtStr == null) return null;

    final expiresAt = int.tryParse(expiresAtStr) ?? 0;
    final nowEpoch  = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (nowEpoch >= expiresAt - 300) {
      final ok = await _refreshAccessToken();
      if (!ok) return null;
    }
    return _storage.read(key: _kAccessToken);
  }

  Future<bool> _refreshAccessToken() async {
    final refresh  = await _storage.read(key: _kRefreshToken);
    if (refresh == null) return false;
    const cId     = _kOwnClientId;
    const cSecret = _kOwnClientSecret;

    try {
      final resp = await http.post(
        Uri.parse(_tokenUrl),
        body: {
          'client_id':     cId,
          'client_secret': cSecret,
          'refresh_token': refresh,
          'grant_type':    'refresh_token',
        },
      );
      if (resp.statusCode == 200) {
        await _storeTokens(jsonDecode(resp.body) as Map<String, dynamic>);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Athlete ───────────────────────────────────────────────────────────────

  Future<StravaAthlete?> getAthlete() async {
    final token = await _validToken()
        .timeout(const Duration(seconds: 8), onTimeout: () => null);
    if (token == null) return null;
    try {
      final resp = await http
          .get(
            Uri.parse('$_apiBase/athlete'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        return StravaAthlete.fromJson(
            jsonDecode(resp.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  // ── Activities ────────────────────────────────────────────────────────────

  /// Fetches one page of activities after [after].
  Future<List<StravaActivity>> fetchActivities({
    required DateTime after,
    int perPage = 200,
    int page    = 1,
  }) async {
    final token = await _validToken();
    if (token == null) return [];

    try {
      final afterEpoch = after.toUtc().millisecondsSinceEpoch ~/ 1000;
      final uri = Uri.parse('$_apiBase/athlete/activities').replace(
        queryParameters: {
          'after':    afterEpoch.toString(),
          'per_page': perPage.toString(),
          'page':     page.toString(),
        },
      );
      final resp = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final list = jsonDecode(resp.body) as List<dynamic>;
        return list
            .map((j) => StravaActivity.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Fetches ALL pages of activities after [after] (stops when a page returns
  /// fewer than [perPage] items, i.e. the last page).
  Future<List<StravaActivity>> fetchAllActivities({
    required DateTime after,
    int perPage = 200,
  }) async {
    final all = <StravaActivity>[];
    int page = 1;
    while (true) {
      final batch = await fetchActivities(after: after, perPage: perPage, page: page);
      all.addAll(batch);
      if (batch.length < perPage) break; // last page
      page++;
    }
    return all;
  }

  // ── Auto-sync preference & last sync date ─────────────────────────────────

  static const _kAutoSync   = 'strava_auto_sync';
  static const _kLastSync   = 'strava_last_sync_iso';

  Future<bool> isAutoSyncEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kAutoSync) ?? false;
  }

  Future<void> setAutoSync({required bool enabled}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoSync, enabled);
  }

  Future<DateTime?> getLastSyncDate() async {
    final prefs = await SharedPreferences.getInstance();
    final iso   = prefs.getString(_kLastSync);
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  Future<void> _saveLastSyncDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastSync, DateTime.now().toIso8601String());
  }

  // ── Sync ──────────────────────────────────────────────────────────────────

  Future<StravaSyncResult> syncGear(int gearItemId) async {
    final db       = DatabaseHelper.instance;
    final settings = await db.getGearStravaSettings(gearItemId);

    if (settings == null || !settings.syncEnabled ||
        settings.activityTypes.isEmpty) {
      return const StravaSyncResult();
    }

    // ── Determine the "fetch after" date ──────────────────────────────────
    // Priority: explicit syncFrom setting → gear purchase date → 365 days ago
    // Using 1 year as default ensures historical activities are fetched on
    // first sync, not just the last 90 days.
    DateTime syncFrom;
    if (settings.syncFrom != null) {
      syncFrom = settings.syncFrom!;
    } else {
      final item = await db.getGearItemById(gearItemId);
      syncFrom = item?.purchaseDate ??
          DateTime.now().subtract(const Duration(days: 365));
    }

    // Fetch all pages (handles athletes with >200 activities)
    final activities = await fetchAllActivities(after: syncFrom);
    if (activities.isEmpty) return const StravaSyncResult();

    final existingIds = await db.getStravaActivityIds(gearItemId);
    int added = 0, skipped = 0;
    double totalKm       = 0;
    int    totalMin      = 0;
    DateTime? newestDate; // newest activity date that was actually added

    for (final act in activities) {
      if (!settings.activityTypes.contains(act.type)) continue;

      final stravaId = act.id.toString();
      if (existingIds.contains(stravaId)) { skipped++; continue; }

      await db.insertUsageLog(UsageLog(
        gearItemId:       gearItemId,
        date:             act.startDateUtc,
        durationMinutes:  act.durationMinutes,
        distanceKm:       act.distanceKm > 0 ? act.distanceKm : null,
        elevationGainM:   act.totalElevationGainM > 0
                              ? act.totalElevationGainM
                              : null,
        location:         act.name,
        source:           UsageSource.strava,
        stravaActivityId: stravaId,
      ));

      added++;
      totalKm  += act.distanceKm;
      totalMin += act.durationMinutes;

      // Strava returns activities newest-first; first added = newest
      if (newestDate == null || act.startDateUtc.isAfter(newestDate)) {
        newestDate = act.startDateUtc;
      }
    }

    return StravaSyncResult(
      added: added, skipped: skipped,
      totalKm: totalKm, totalMinutes: totalMin,
      newestActivityDate: newestDate,
    );
  }

  /// Sync all gear items that have Strava sync enabled.
  Future<Map<int, StravaSyncResult>> syncAll() async {
    isSyncing.value = true;
    try {
      final db    = DatabaseHelper.instance;
      final items = await db.getGearItemsWithStravaSync();
      final results = <int, StravaSyncResult>{};
      for (final item in items) {
        results[item.id!] = await syncGear(item.id!);
      }
      await _saveLastSyncDate();
      return results;
    } finally {
      isSyncing.value = false;
    }
  }

  /// Global sync: fetches ALL activities from the past 365 days, regardless
  /// of activity type or gear assignment.  Activities are saved to UsageLog
  /// with [gearItemId] = null (unassigned).  Already-stored activities
  /// (matched by strava_activity_id across ALL rows) are skipped.
  ///
  /// Returns the number of newly added activities.
  Future<int> syncAllActivities() async {
    isSyncing.value = true;
    try {
      final db    = DatabaseHelper.instance;
      final after = DateTime.now().subtract(const Duration(days: 365));

      // ── Paginate through all Strava pages ────────────────────────────────
      final all = <StravaActivity>[];
      int page = 1;
      while (true) {
        final batch = await fetchActivities(
            after: after, perPage: 200, page: page);
        // ignore: avoid_print
        print('[Strava] Rok zpět, stránka $page, vráceno ${batch.length} aktivit');
        all.addAll(batch);
        if (batch.length < 200) break;
        page++;
      }
      // ignore: avoid_print
      print('[Strava] Celkem staženo: ${all.length} aktivit');

      if (all.isEmpty) {
        await _saveLastSyncDate();
        return 0;
      }

      // ── Global deduplication ──────────────────────────────────────────────
      final existingIds = await db.getAllStravaActivityIds();
      int added = 0;

      for (final act in all) {
        final stravaId = act.id.toString();
        if (existingIds.contains(stravaId)) continue;

        await db.insertUsageLog(UsageLog(
          // gearItemId intentionally null — unassigned global activity
          date:            act.startDateUtc,
          durationMinutes: act.durationMinutes,
          distanceKm:      act.distanceKm > 0 ? act.distanceKm : null,
          elevationGainM:  act.totalElevationGainM > 0
                               ? act.totalElevationGainM
                               : null,
          location:         act.name,
          source:           UsageSource.strava,
          stravaActivityId: stravaId,
        ));
        added++;
        existingIds.add(stravaId); // prevent duplicate within this batch
      }

      // ignore: avoid_print
      print('[Strava] Celkem uloženo: $added nových aktivit');
      await _saveLastSyncDate();
      return added;
    } finally {
      isSyncing.value = false;
    }
  }
}
