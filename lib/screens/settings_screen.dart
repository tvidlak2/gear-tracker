import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nastavení')),
      body: ListView(
        children: [
          _SectionHeader('Aplikace'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Vzhled',
            subtitle: 'Světlý / tmavý / systémový motiv',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Oznámení',
            subtitle: 'Připomínky servisu a termínů',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Jazyk',
            subtitle: 'Čeština',
            onTap: () {},
          ),
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
          _SectionHeader('O aplikaci'),
          _SettingsTile(
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
      leading: Icon(icon,
          color: titleColor ?? Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title,
          style: titleColor != null ? TextStyle(color: titleColor) : null),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
