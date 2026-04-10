/// Handles the Strava OAuth2 web callback.
///
/// Strava redirects the browser to:
///   http://localhost:PORT/strava-callback?code=XXX
///
/// GoRouter routes that URL here. This screen exchanges the code for tokens
/// and then navigates to /settings. Only used on web.
library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/strava_service.dart';
import '../theme/app_theme.dart';

class StravaCallbackScreen extends StatefulWidget {
  /// The authorisation code from Strava (?code=). May be null if GoRouter
  /// didn't capture the query param; fallback reads it from Uri.base.
  final String? code;

  /// OAuth error from Strava (?error=), e.g. "access_denied".
  final String? oauthError;

  const StravaCallbackScreen({
    super.key,
    this.code,
    this.oauthError,
  });

  @override
  State<StravaCallbackScreen> createState() => _StravaCallbackScreenState();
}

class _StravaCallbackScreenState extends State<StravaCallbackScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _processCallback();
  }

  /// Reads the auth code from widget props first; if null, reads directly
  /// from the browser URL (Uri.base) as a fallback.
  String? _resolveCode() {
    if (widget.code != null && widget.code!.isNotEmpty) return widget.code;
    if (kIsWeb) {
      // Fallback: read directly from the live browser URL
      return Uri.base.queryParameters['code'];
    }
    return null;
  }

  String? _resolveOAuthError() {
    if (widget.oauthError != null && widget.oauthError!.isNotEmpty) {
      return widget.oauthError;
    }
    if (kIsWeb) return Uri.base.queryParameters['error'];
    return null;
  }

  Future<void> _processCallback() async {
    final oauthError = _resolveOAuthError();
    final code       = _resolveCode();

    // ── Strava error (e.g. user clicked "Deny") ──────────────────────────
    if (oauthError != null) {
      if (mounted) {
        setState(() => _errorMessage =
            'Strava odmítla přístup: $oauthError');
      }
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) context.go('/settings');
      return;
    }

    // ── Missing code ─────────────────────────────────────────────────────
    if (code == null || code.isEmpty) {
      if (mounted) {
        setState(() => _errorMessage =
            'Autorizační kód chybí. Zkus přihlášení znovu.\n'
            'URL: ${kIsWeb ? Uri.base : "N/A"}');
      }
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) context.go('/settings');
      return;
    }

    // ── Exchange code for tokens ──────────────────────────────────────────
    final error = await StravaService.instance.completeWebOAuth(code);

    if (!mounted) return;

    if (error != null) {
      setState(() => _errorMessage = error);
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) context.go('/settings');
    } else {
      // Success – SettingsScreen._loadStravaState() will detect the token
      context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    const stravaOrange = Color(0xFFFC4C02);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: stravaOrange.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_run,
                    color: stravaOrange, size: 32),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 36),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.danger),
                ),
                const SizedBox(height: 16),
                Text(
                  'Přesměrovávám zpět do nastavení…',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                ),
              ] else ...[
                const CircularProgressIndicator(color: stravaOrange),
                const SizedBox(height: 20),
                const Text(
                  'Dokončuji přihlášení ke Stravě…',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vyměňuji autorizační kód za přístupový token.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
