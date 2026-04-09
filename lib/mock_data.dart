import 'database/database_helper.dart';

/// Vloží ukázková data při prvním spuštění aplikace (pokud je DB prázdná).
class MockDataSeeder {
  static Future<void> seedIfEmpty() async {
    final db = DatabaseHelper.instance;
    final items = await db.getGearItems();
    if (items.isNotEmpty) return;

    final rawDb = await db.database;

    // ── Načti kategorie podle jména (ID jsou AUTOINCREMENT) ──
    final cats = await rawDb.query('categories');
    final catId = {for (final c in cats) c['name'] as String: c['id'] as int};

    final now = DateTime.now();

    // ── Gear items ────────────────────────────────────────────
    final ropeId = await rawDb.insert('gear_items', {
      'name': 'Mammut Crag Classic 9.5',
      'category_id': catId['Lano']!,
      'brand': 'Mammut',
      'model': 'Crag Classic 9.5',
      'serial_number': 'MM-2021-4471',
      'purchase_date': _d(now, -730),
      'status': 'active',
      'notes': 'Hlavní lano na skalní lezení.',
    });

    final harnessId = await rawDb.insert('gear_items', {
      'name': 'Black Diamond Momentum',
      'category_id': catId['Úvazek']!,
      'brand': 'Black Diamond',
      'model': 'Momentum',
      'purchase_date': _d(now, -1100),
      'status': 'active',
    });

    final helmetId = await rawDb.insert('gear_items', {
      'name': 'Petzl Meteor',
      'category_id': catId['Přilba']!,
      'brand': 'Petzl',
      'model': 'Meteor',
      'purchase_date': _d(now, -500),
      'status': 'active',
    });

    final iceAxeId = await rawDb.insert('gear_items', {
      'name': 'Grivel Ghost Evo',
      'category_id': catId['Cepín']!,
      'brand': 'Grivel',
      'model': 'Ghost Evo',
      'purchase_date': _d(now, -900),
      'status': 'active',
    });

    final skiId = await rawDb.insert('gear_items', {
      'name': 'Dynafit Blacklight 80',
      'category_id': catId['Lyže']!,
      'brand': 'Dynafit',
      'model': 'Blacklight 80',
      'purchase_date': _d(now, -400),
      'status': 'active',
    });

    final bikeId = await rawDb.insert('gear_items', {
      'name': 'Trek Marlin 7',
      'category_id': catId['Kolo']!,
      'brand': 'Trek',
      'model': 'Marlin 7',
      'serial_number': 'TK-WTU22-0093',
      'purchase_date': _d(now, -600),
      'status': 'active',
    });

    // ── Maintenance rules ────────────────────────────────────
    // Lano: roční prohlídka (OVERDUE – poslední servis před 400 dny)
    final ropeRuleId = await rawDb.insert('maintenance_rules', {
      'gear_item_id': ropeId,
      'name': 'Roční prohlídka lana',
      'trigger_type': 'date',
      'trigger_value': 365.0,
      'warning_before': 30.0,
      'is_safety_critical': 1,
    });

    // Úvazek: 3letá prohlídka (WARNING – next due za ~35 dní)
    final harnessRuleId = await rawDb.insert('maintenance_rules', {
      'gear_item_id': harnessId,
      'name': 'Tříletá bezpečnostní prohlídka',
      'trigger_type': 'date',
      'trigger_value': 1095.0,
      'warning_before': 60.0,
      'is_safety_critical': 1,
    });

    // Přilba: roční prohlídka (OK – provedena před 60 dny)
    final helmetRuleId = await rawDb.insert('maintenance_rules', {
      'gear_item_id': helmetId,
      'name': 'Roční prohlídka přilby',
      'trigger_type': 'date',
      'trigger_value': 365.0,
      'warning_before': 30.0,
      'is_safety_critical': 1,
    });

    // Lyže: servis vázání každou sezónu (WARNING – next due za ~20 dní)
    final skiRuleId = await rawDb.insert('maintenance_rules', {
      'gear_item_id': skiId,
      'name': 'Servis a seřízení vázání',
      'trigger_type': 'date',
      'trigger_value': 180.0,
      'warning_before': 30.0,
      'is_safety_critical': 0,
    });

    // Kolo: servis každých 1000 km (OVERDUE – najeto 1 150 km)
    await rawDb.insert('maintenance_rules', {
      'gear_item_id': bikeId,
      'name': 'Servis po 1 000 km',
      'trigger_type': 'usageDistance',
      'trigger_value': 1000.0,
      'warning_before': 100.0,
      'is_safety_critical': 0,
    });

    // Kolo: přemazání řetězu každých 250 km (WARNING – najeto 1 150, log po 900)
    final bikeChainRuleId = await rawDb.insert('maintenance_rules', {
      'gear_item_id': bikeId,
      'name': 'Přemazání řetězu',
      'trigger_type': 'usageDistance',
      'trigger_value': 250.0,
      'warning_before': 30.0,
      'is_safety_critical': 0,
    });

    // ── Maintenance logs (nastavení stavů) ───────────────────
    // Lano: poslední prohlídka před 400 dny → nextDue = now-35 → OVERDUE
    await rawDb.insert('maintenance_logs', {
      'gear_item_id': ropeId,
      'rule_id': ropeRuleId,
      'performed_date': _d(now, -400),
      'performed_by': 'Jan Novák',
      'cost': 0.0,
      'notes': 'Vizuální kontrola, bez závad.',
      'next_due_date': _d(now, -35),
    });

    // Úvazek: poslední prohlídka před 1 060 dny → nextDue = now+35 → WARNING
    await rawDb.insert('maintenance_logs', {
      'gear_item_id': harnessId,
      'rule_id': harnessRuleId,
      'performed_date': _d(now, -1060),
      'performed_by': 'Hudy Sport Praha',
      'cost': 350.0,
      'notes': 'Prohlídka schválena, bez poškození.',
      'next_due_date': _d(now, 35),
    });

    // Přilba: prohlídka před 60 dny → nextDue = now+305 → OK
    await rawDb.insert('maintenance_logs', {
      'gear_item_id': helmetId,
      'rule_id': helmetRuleId,
      'performed_date': _d(now, -60),
      'performed_by': 'Vlastní kontrola',
      'cost': 0.0,
      'next_due_date': _d(now, 305),
    });

    // Lyže: servis před 160 dny → nextDue = now+20 → WARNING
    await rawDb.insert('maintenance_logs', {
      'gear_item_id': skiId,
      'rule_id': skiRuleId,
      'performed_date': _d(now, -160),
      'performed_by': 'Sport Chalet Špindl',
      'cost': 890.0,
      'notes': 'Servis vázání, voskování.',
      'next_due_date': _d(now, 20),
    });

    // Kolo: přemazání řetězu naposledy po 900 km (log), pak najeto 250 km → WARNING
    await rawDb.insert('maintenance_logs', {
      'gear_item_id': bikeId,
      'rule_id': bikeChainRuleId,
      'performed_date': _d(now, -45),
      'cost': 120.0,
      'notes': 'Čistění a mazání Squirt wax.',
    });

    // ── Usage logs ───────────────────────────────────────────
    // Lano + Úvazek + Přilba: 18 lezeckých výjezdů
    final climbingSessions = [
      (180, 0.0, 'Křížový vrch'), (240, 0.0, 'Labské pískovce'),
      (150, 0.0, 'Klínovec – umělá stěna'), (300, 0.0, 'Adršpach'),
      (200, 0.0, 'Křížový vrch'), (180, 0.0, 'Skalní město Broumov'),
      (240, 0.0, 'Labské pískovce'), (200, 0.0, 'Prachovské skály'),
      (160, 0.0, 'Klínovec'), (220, 0.0, 'Adršpach'),
      (190, 0.0, 'Křížový vrch'), (250, 0.0, 'Labské pískovce'),
      (175, 0.0, 'Skalní město Broumov'), (210, 0.0, 'Prachovské skály'),
      (195, 0.0, 'Adršpach'), (230, 0.0, 'Labské pískovce'),
      (160, 0.0, 'Klínovec'), (185, 0.0, 'Křížový vrch'),
    ];

    for (var i = 0; i < climbingSessions.length; i++) {
      final (min, km, loc) = climbingSessions[i];
      final daysAgo = -(i * 18 + 5);
      for (final gearId in [ropeId, harnessId, helmetId]) {
        await rawDb.insert('usage_logs', {
          'gear_item_id': gearId,
          'date': _d(now, daysAgo),
          'duration_minutes': min,
          'distance_km': km > 0 ? km : null,
          'location': loc,
          'source': 'manual',
        });
      }
    }

    // Cepín + Lyže: 12 skialpinistických výjezdů
    final skiSessions = [
      (420, 18.5, 'Krkonoše – Sněžka'), (360, 14.2, 'Jeseníky – Praděd'),
      (480, 22.0, 'Šumava – Boubín'), (390, 16.8, 'Beskydy – Lysá hora'),
      (300, 11.5, 'Krkonoše – Labská louka'), (450, 19.3, 'Jeseníky – Červenohorské sedlo'),
      (360, 15.0, 'Šumava – Plesná'), (420, 17.8, 'Beskydy – Radegast'),
      (380, 16.0, 'Krkonoše – Špindlerův Mlýn'), (290, 12.0, 'Jeseníky – Videlský kříž'),
      (440, 20.5, 'Šumava – Lipno'), (350, 14.5, 'Beskydy – Pustevny'),
    ];

    for (var i = 0; i < skiSessions.length; i++) {
      final (min, km, loc) = skiSessions[i];
      final daysAgo = -(i * 12 + 3);
      for (final gearId in [iceAxeId, skiId]) {
        await rawDb.insert('usage_logs', {
          'gear_item_id': gearId,
          'date': _d(now, daysAgo),
          'duration_minutes': min,
          'distance_km': km,
          'location': loc,
          'source': 'manual',
        });
      }
    }

    // Kolo: 16 výjezdů, celkem ~1 150 km
    final bikeSessions = [
      (185, 78.5, 'Šluknovský výběžek'), (150, 62.0, 'Česká Švýcarsko'),
      (200, 85.5, 'Labská stezka – Ústí'), (140, 58.0, 'Jezerní okruh'),
      (175, 74.0, 'Krušnohorská magistrála'), (160, 67.5, 'Elberadweg Decín'),
      (190, 80.0, 'Tisá – Sněžník okruh'), (145, 60.5, 'Roudnice nad Labem'),
      (170, 72.0, 'Máchovo jezero'), (155, 65.0, 'Bezděz – Doksy'),
      (185, 78.0, 'Liberecká výzva'), (130, 55.0, 'Frýdlantský výběžek'),
      (180, 76.5, 'Jablonec nad Nisou'), (165, 69.0, 'Ještěd okruh'),
      (175, 73.0, 'Liberec – Hrádek nad Nisou'), (140, 59.5, 'Zittau okruh'),
    ];

    for (var i = 0; i < bikeSessions.length; i++) {
      final (min, km, loc) = bikeSessions[i];
      final daysAgo = -(i * 14 + 2);
      await rawDb.insert('usage_logs', {
        'gear_item_id': bikeId,
        'date': _d(now, daysAgo),
        'duration_minutes': min,
        'distance_km': km,
        'location': loc,
        'source': 'manual',
      });
    }
  }

  static String _d(DateTime base, int offsetDays) {
    return base
        .add(Duration(days: offsetDays))
        .toIso8601String()
        .split('T')
        .first;
  }
}
