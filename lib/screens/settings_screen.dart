import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/strava_models.dart';
import '../services/notification_service.dart';
import '../services/strava_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notifSvc  = NotificationService.instance;
  final _stravaSvc = StravaService.instance;
  final _db        = DatabaseHelper.instance;

  bool _notificationsEnabled = false;
  bool _notifLoading = true;

  // Strava state
  bool           _stravaConnected = false;
  bool           _stravaLoading   = true;
  StravaAthlete? _stravaAthlete;
  bool           _stravaSyncing   = false;
  int            _syncedCount     = 0;   // total activities synced from Strava
  String?        _stravaLoadError; // non-null → show inline error
  bool           _autoSync        = false;
  DateTime?      _lastSyncDate;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
    _loadStravaState();
  }

  Future<void> _loadNotificationState() async {
    final enabled = await _notifSvc.isEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
        _notifLoading = false;
      });
    }
  }

  /// Loads Strava connection state with a hard 10-second overall timeout.
  /// Always clears [_stravaLoading] in `finally`, so the spinner can't hang.
  Future<void> _loadStravaState() async {
    if (mounted) setState(() { _stravaLoading = true; _stravaLoadError = null; });

    try {
      final connected = await _stravaSvc.isConnected
          .timeout(const Duration(seconds: 10));

      StravaAthlete? athlete;
      int syncedCount = 0;

      if (connected) {
        // Run athlete fetch + count query + prefs in parallel.
        final results = await Future.wait([
          _stravaSvc
              .getAthlete()
              .timeout(const Duration(seconds: 10), onTimeout: () => null),
          _db
              .getTotalStravaActivityCount()
              .timeout(const Duration(seconds: 5), onTimeout: () => 0),
          _stravaSvc.isAutoSyncEnabled(),
          _stravaSvc.getLastSyncDate(),
        ]);
        athlete          = results[0] as StravaAthlete?;
        syncedCount      = results[1] as int;
        final autoSync   = results[2] as bool;
        final lastSync   = results[3] as DateTime?;
        if (mounted) {
          setState(() {
            _autoSync     = autoSync;
            _lastSyncDate = lastSync;
          });
        }
      }

      if (mounted) {
        setState(() {
          _stravaConnected = connected;
          _stravaAthlete   = athlete;
          _syncedCount     = syncedCount;
        });
      }
    } on TimeoutException {
      if (mounted) {
        setState(() => _stravaLoadError =
            'Nepodařilo se načíst stav Stravy, zkus to znovu.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _stravaLoadError = 'Chyba: $e');
      }
    } finally {
      if (mounted) setState(() => _stravaLoading = false);
    }
  }

  Future<void> _connectStrava() async {
    // Ensure credentials are present
    final hasCredentials = await _stravaSvc.hasCredentials();
    if (!hasCredentials && mounted) {
      final entered = await _showCredentialsDialog();
      if (!entered) return;
    }
    if (!mounted) return;
    setState(() { _stravaLoading = true; _stravaLoadError = null; });

    // connect() returns null on success, Czech error string on failure
    String? connectError;
    try {
      connectError = await _stravaSvc
          .connect(context)
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      connectError = 'Připojení vypršelo (30 s). Zkontroluj síť a zkus znovu.';
    } catch (e) {
      connectError = 'Neočekávaná chyba: $e';
    }

    if (!mounted) return;

    if (connectError != null) {
      setState(() => _stravaLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(connectError),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    if (kIsWeb) {
      // Web: connect() redirected the browser tab to Strava.
      // The /strava-callback route will handle the result — nothing more to do
      // here (the current page is being replaced).
      return;
    }

    // Android: token is already stored — load athlete profile + count
    await _loadStravaState();
  }

  Future<void> _disconnectStrava() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Odpojit Strava'),
        content: const Text(
            'Odstraní přístupové tokeny. Nalogované aktivity zůstanou.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Zrušit')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Odpojit')),
        ],
      ),
    );
    if (confirm != true) return;
    await _stravaSvc.disconnect();
    if (mounted) {
      setState(() {
        _stravaConnected = false;
        _stravaAthlete   = null;
        _syncedCount     = 0;
        _stravaLoadError = null;
      });
    }
  }

  Future<void> _syncAll() async {
    setState(() => _stravaSyncing = true);
    Map<int, StravaSyncResult> results;
    try {
      results = await _stravaSvc
          .syncAll()
          .timeout(const Duration(minutes: 2));
    } on TimeoutException {
      if (mounted) {
        setState(() => _stravaSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Synchronizace vypršela. Zkus znovu.')),
        );
      }
      return;
    }

    if (!mounted) return;

    // Refresh count after sync
    final newCount = await _db.getTotalStravaActivityCount();
    final lastSync = await _stravaSvc.getLastSyncDate();
    setState(() {
      _stravaSyncing = false;
      _syncedCount   = newCount;
      _lastSyncDate  = lastSync;
    });

    final total = results.values.fold(0, (s, r) => s + r.added);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          total > 0
              ? 'Synchronizace dokončena – přidáno $total aktivit.'
              : 'Žádné nové aktivity k synchronizaci.',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows dialog to enter Strava client_id + client_secret.
  /// Returns true if credentials were saved.
  Future<bool> _showCredentialsDialog() async {
    final idCtrl     = TextEditingController();
    final secretCtrl = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Strava API přihlašovací údaje'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Zadej Client ID a Client Secret ze svého Strava API účtu '
              '(https://www.strava.com/settings/api).',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: idCtrl,
              decoration: const InputDecoration(
                labelText: 'Client ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: secretCtrl,
              decoration: const InputDecoration(
                labelText: 'Client Secret',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Zrušit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Uložit'),
          ),
        ],
      ),
    );
    if (saved == true && idCtrl.text.isNotEmpty && secretCtrl.text.isNotEmpty) {
      await _stravaSvc.saveCredentials(
        clientId:     idCtrl.text.trim(),
        clientSecret: secretCtrl.text.trim(),
      );
      return true;
    }
    return false;
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notifLoading = true);

    // Na Android 13+ požádej o oprávnění při prvním zapnutí
    if (value && _notifSvc.platformSupported) {
      final granted = await _notifSvc.requestPermission();
      if (!granted && mounted) {
        setState(() => _notifLoading = false);
        _showPermissionDeniedSnackbar();
        return;
      }
    }

    await _notifSvc.setEnabled(value: value);

    if (mounted) {
      setState(() {
        _notificationsEnabled = value;
        _notifLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'Notifikace zapnuty – termíny servisu tě připomenou.'
              : 'Notifikace vypnuty.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPermissionDeniedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Oprávnění pro notifikace bylo zamítnuto.'),
        action: SnackBarAction(
          label: 'Nastavení',
          onPressed: () {
            // Uživatel může oprávnění udělit ručně v systémovém nastavení
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nastavení')),
      body: ListView(
        children: [
          // ── Sekce: Aplikace ─────────────────────────────────────────────
          _SectionHeader('Aplikace'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Vzhled',
            subtitle: 'Světlý / tmavý / systémový motiv',
            onTap: () {},
          ),

          // ── Notifikace – switch tile ─────────────────────────────────────
          _NotificationTile(
            loading: _notifLoading,
            enabled: _notificationsEnabled,
            platformSupported: _notifSvc.platformSupported,
            onChanged: _toggleNotifications,
          ),

          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Jazyk',
            subtitle: 'Čeština',
            onTap: () {},
          ),

          // ── Sekce: Propojené služby ──────────────────────────────────────
          _SectionHeader('Propojené služby'),
          _StravaSection(
            loading:      _stravaLoading,
            connected:    _stravaConnected,
            syncing:      _stravaSyncing,
            athlete:      _stravaAthlete,
            syncedCount:  _syncedCount,
            loadError:    _stravaLoadError,
            autoSync:     _autoSync,
            lastSyncDate: _lastSyncDate,
            onConnect:    _connectStrava,
            onDisconnect: _disconnectStrava,
            onSyncAll:    _syncAll,
            onRetry:      _loadStravaState,
            onAutoSyncChanged: (v) async {
              await _stravaSvc.setAutoSync(enabled: v);
              setState(() => _autoSync = v);
            },
            onEditCredentials: () async {
              await _showCredentialsDialog();
            },
          ),

          // ── Sekce: Data ─────────────────────────────────────────────────
          _SectionHeader('Data'),
          _SettingsTile(
            icon: Icons.backup_outlined,
            title: 'Záloha a export',
            subtitle: 'Export do CSV nebo záloha do cloudu',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.upload_file_outlined,
            title: 'Import',
            subtitle: 'Import ze souboru CSV nebo GPX',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Vymazat všechna data',
            subtitle: 'Trvale odstraní vše z databáze',
            titleColor: cs.error,
            onTap: () {},
          ),

          // ── Sekce: O aplikaci ───────────────────────────────────────────
          _SectionHeader('O aplikaci'),
          const _SettingsTile(
            icon: Icons.info_outline,
            title: 'Verze',
            subtitle: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Zásady ochrany osobních údajů',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final bool loading;
  final bool enabled;
  final bool platformSupported;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.loading,
    required this.enabled,
    required this.platformSupported,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (!platformSupported) {
      // Web: zobraz informaci místo přepínače
      return ListTile(
        leading: Icon(Icons.notifications_off_outlined, color: cs.outline),
        title: const Text('Oznámení'),
        subtitle: Text(
          'Push notifikace nejsou v prohlížeči podporovány.\nPoužij Android / iOS aplikaci.',
          style: TextStyle(color: cs.outline),
        ),
        isThreeLine: true,
      );
    }

    return SwitchListTile(
      secondary: loading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            )
          : Icon(
              enabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: enabled ? cs.primary : cs.outline,
            ),
      title: const Text('Oznámení'),
      subtitle: Text(
        enabled
            ? 'Dostaneš připomenutí před termínem servisu i po termínu.'
            : 'Připomínky servisních termínů jsou vypnuty.',
        style: tt.bodySmall,
      ),
      value: enabled,
      onChanged: loading ? null : onChanged,
    );
  }
}

// ─── Sdílené pomocné widgety ──────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: titleColor != null ? TextStyle(color: titleColor) : null,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing:
          onTap != null ? const Icon(Icons.chevron_right, size: 20) : null,
      onTap: onTap,
    );
  }
}

// ─── Strava section ───────────────────────────────────────────────────────────

class _StravaSection extends StatelessWidget {
  final bool            loading;
  final bool            connected;
  final bool            syncing;
  final StravaAthlete?  athlete;
  final int             syncedCount;
  final String?         loadError;
  final bool            autoSync;
  final DateTime?       lastSyncDate;
  final VoidCallback    onConnect;
  final VoidCallback    onDisconnect;
  final VoidCallback    onSyncAll;
  final VoidCallback    onRetry;
  final ValueChanged<bool> onAutoSyncChanged;
  final VoidCallback    onEditCredentials;

  const _StravaSection({
    required this.loading,
    required this.connected,
    required this.syncing,
    required this.athlete,
    required this.syncedCount,
    required this.loadError,
    required this.autoSync,
    required this.lastSyncDate,
    required this.onConnect,
    required this.onDisconnect,
    required this.onSyncAll,
    required this.onRetry,
    required this.onAutoSyncChanged,
    required this.onEditCredentials,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const stravaOrange = Color(0xFFFC4C02);

    // ── Loading ────────────────────────────────────────────────────────────
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ── Load error (timeout / network) ────────────────────────────────────
    if (loadError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 0,
          color: const Color(0xFFFFF3E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFFCC80)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFE65100), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(loadError!,
                      style:
                          const TextStyle(fontSize: 13, color: Color(0xFF5D4037))),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Zkusit znovu'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Not connected ──────────────────────────────────────────────────────
    if (!connected) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_run, color: stravaOrange),
                    const SizedBox(width: 8),
                    const Text('Strava',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Propoj aplikaci se Stravou a automaticky synchronizuj '
                  'aktivity jako záznamy použití vybavení.',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: onEditCredentials,
                      icon: const Icon(Icons.key_outlined, size: 16),
                      label: const Text('API klíče'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: onConnect,
                      style: FilledButton.styleFrom(
                          backgroundColor: stravaOrange),
                      icon: const Icon(Icons.link, size: 16),
                      label: const Text('Připojit Strava'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Connected ──────────────────────────────────────────────────────────
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: stravaOrange, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title + "Propojeno" badge ──────────────────────────────
              Row(
                children: [
                  const Icon(Icons.directions_run, color: stravaOrange,
                      size: 20),
                  const SizedBox(width: 8),
                  const Text('Strava',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const Spacer(),
                  _ConnectedBadge(),
                ],
              ),

              const SizedBox(height: 12),

              // ── Athlete row (photo + name + count) ─────────────────────
              Row(
                children: [
                  // Avatar: network photo if available, else initials
                  _AthleteAvatar(athlete: athlete),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          athlete?.fullName ?? 'Strava účet',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          syncedCount > 0
                              ? '$syncedCount synchronizovaných aktivit'
                              : 'Zatím žádné synchronizované aktivity',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 0),

              // ── Auto-sync toggle ────────────────────────────────────────
              SwitchListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4),
                title: const Text(
                  'Synchronizovat při spuštění aplikace',
                  style: TextStyle(fontSize: 13),
                ),
                value: autoSync,
                activeColor: stravaOrange,
                onChanged: onAutoSyncChanged,
              ),

              // ── Last sync date ──────────────────────────────────────────
              if (lastSyncDate != null)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 4, right: 4, bottom: 8),
                  child: Text(
                    'Poslední sync: ${_formatSyncDate(lastSyncDate!)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),

              const Divider(height: 0),
              const SizedBox(height: 12),

              // ── Action buttons ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: syncing ? null : onSyncAll,
                      style: FilledButton.styleFrom(
                        backgroundColor: stravaOrange,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: syncing
                          ? const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.sync, size: 16),
                      label: Text(syncing
                          ? 'Synchronizuji…'
                          : 'Synchronizovat aktivity'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onDisconnect,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    child: const Text('Odpojit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatSyncDate(DateTime dt) {
    final now   = DateTime.now();
    final local = dt.toLocal();
    final time  = '${local.hour.toString().padLeft(2, '0')}:'
                  '${local.minute.toString().padLeft(2, '0')}';
    if (local.year == now.year &&
        local.month == now.month &&
        local.day   == now.day) {
      return 'Dnes v $time';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year  == yesterday.year &&
        local.month == yesterday.month &&
        local.day   == yesterday.day) {
      return 'Včera v $time';
    }
    return '${local.day}. ${local.month}. ${local.year} v $time';
  }
}

// ─── Athlete avatar ───────────────────────────────────────────────────────────

class _AthleteAvatar extends StatelessWidget {
  final StravaAthlete? athlete;
  const _AthleteAvatar({required this.athlete});

  @override
  Widget build(BuildContext context) {
    const stravaOrange = Color(0xFFFC4C02);
    const size = 40.0;

    final photoUrl = athlete?.profileMedium;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl,
          width: size, height: size,
          fit: BoxFit.cover,
          // On error (e.g. no network) fall back to initials
          errorBuilder: (_, __, ___) =>
              _initialsAvatar(athlete, size, stravaOrange),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: size, height: size,
              child: const CircularProgressIndicator(
                  strokeWidth: 2, color: stravaOrange),
            );
          },
        ),
      );
    }

    return _initialsAvatar(athlete, size, stravaOrange);
  }

  static Widget _initialsAvatar(
      StravaAthlete? athlete, double size, Color color) {
    final initials = athlete != null && athlete.firstname.isNotEmpty
        ? athlete.firstname[0].toUpperCase()
        : 'S';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withAlpha(30),
      child: Text(initials,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: color, fontSize: size * 0.4)),
    );
  }
}

// ─── Connected badge ──────────────────────────────────────────────────────────

class _ConnectedBadge extends StatelessWidget {
  const _ConnectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 13, color: Color(0xFF2E7D32)),
          SizedBox(width: 4),
          Text(
            'Připojeno',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
