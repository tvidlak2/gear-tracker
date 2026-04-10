import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notifSvc = NotificationService.instance;

  bool _notificationsEnabled = false;
  bool _notifLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();
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
