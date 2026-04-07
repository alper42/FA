import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/transit_models.dart';

// ─── Farben ────────────────────────────────────────────────────────────────
const kSBahnGreen   = Color(0xFF00A650);
const kUBahnBlue    = Color(0xFF0057B8);
const kTramRed      = Color(0xFFE2001A);
const kBusOrange    = Color(0xFFFF6B00);
const kRegionalGray = Color(0xFF6D6E70);

const _kBaseUrl = 'https://v6.db.transport.rest';

// ─── TransitService – reine Datenschicht, kein ChangeNotifier ──────────────
class TransitService {
  // ── Haltestellensuche ──────────────────────────────────────────────────
  Future<List<Station>> fetchStations(String query) async {
    final uri = Uri.parse('$_kBaseUrl/locations').replace(
      queryParameters: {
        'query':     query,
        'results':   '8',
        'stops':     'true',
        'addresses': 'false',
        'poi':       'false',
      },
    );
    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));

    if (res.statusCode == 200) {
      final List data = json.decode(res.body) as List;
      return data
          .where((e) => e['type'] == 'stop' || e['type'] == 'station')
          .map<Station>((e) => _stationFromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('API Fehler ${res.statusCode}');
  }

  // ── Verbindungssuche ───────────────────────────────────────────────────
  Future<List<Journey>> fetchJourneys({
    required String fromId,
    required String toId,
    required DateTime travelTime,
    required bool isDeparture,
  }) async {
    final dt = travelTime.toUtc().toIso8601String();
    final uri = Uri.parse('$_kBaseUrl/journeys').replace(
      queryParameters: {
        'from':    fromId,
        'to':      toId,
        if (isDeparture) 'departure': dt else 'arrival': dt,
        'results': '5',
        'stopovers': 'false',
        'language': 'de',
      },
    );
    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data     = json.decode(res.body) as Map<String, dynamic>;
      final journeys = data['journeys'] as List? ?? [];
      return journeys
          .map((j) => _parseJourney(j as Map<String, dynamic>))
          .whereType<Journey>()
          .toList();
    }
    throw Exception('API Fehler ${res.statusCode}');
  }

  // ── Abfahrten ──────────────────────────────────────────────────────────
  Future<List<Departure>> fetchDepartures(String stationId) async {
    final uri = Uri.parse('$_kBaseUrl/stops/$stationId/departures').replace(
      queryParameters: {
        'results':  '20',
        'duration': '60',
        'language': 'de',
      },
    );
    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 8));

    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final deps = data['departures'] as List? ?? [];
      return deps
          .map((d) => _parseDeparture(d as Map<String, dynamic>))
          .whereType<Departure>()
          .toList();
    }
    throw Exception('API Fehler ${res.statusCode}');
  }

  // ── Fallback-Stationen ─────────────────────────────────────────────────
  List<Station> fallbackStations(String query) {
    const fallback = [
      {'id': '8000261', 'name': 'München Hbf'},
      {'id': '8004158', 'name': 'München Marienplatz'},
      {'id': '8004128', 'name': 'München Ostbahnhof'},
      {'id': '8004160', 'name': 'München Pasing'},
      {'id': '8003040', 'name': 'Flughafen München'},
      {'id': '8000013', 'name': 'Augsburg Hbf'},
      {'id': '8000096', 'name': 'Frankfurt(Main)Hbf'},
      {'id': '8011160', 'name': 'Berlin Hbf'},
    ];
    final q = query.toLowerCase();
    return fallback
        .where((s) => s['name']!.toLowerCase().contains(q))
        .map((s) => Station(id: s['id']!, name: s['name']!, lines: []))
        .toList();
  }

  // ── Private Hilfsmethoden ──────────────────────────────────────────────
  Station _stationFromJson(Map<String, dynamic> json) => Station(
        id:    json['id']?.toString() ?? '',
        name:  json['name']?.toString() ?? 'Unbekannt',
        lines: [],
      );

  TransitLine _lineFromProduct(Map<String, dynamic> product, String lineName) {
    final name = (product['name'] as String? ?? lineName).trim();
    final type = (product['productName'] as String? ?? '').toLowerCase();

    LineType lt;
    Color color;

    if (type.contains('s-bahn') || name.startsWith('S')) {
      lt = LineType.sbahn; color = kSBahnGreen;
    } else if (type.contains('u-bahn') || name.startsWith('U')) {
      lt = LineType.ubahn;
      const uColors = {
        'U1': Color(0xFF417C2B), 'U2': Color(0xFFCC0000),
        'U3': Color(0xFFEF7C00), 'U4': Color(0xFF00A3E0),
        'U5': Color(0xFF754F23), 'U6': Color(0xFF0057B8),
        'U7': Color(0xFF417C2B), 'U8': Color(0xFFCC0000),
      };
      color = uColors[name] ?? kUBahnBlue;
    } else if (type.contains('tram') || name.startsWith('T')) {
      lt = LineType.tram; color = kTramRed;
    } else if (type.contains('bus') || name.startsWith('B')) {
      lt = LineType.bus; color = kBusOrange;
    } else {
      lt = LineType.regional; color = kRegionalGray;
    }

    return TransitLine(id: name, name: name, type: lt, color: color);
  }

  Journey? _parseJourney(Map<String, dynamic> j) {
    try {
      final legs = (j['legs'] as List)
          .map((l) => _parseLeg(l as Map<String, dynamic>))
          .whereType<JourneyLeg>()
          .toList();
      if (legs.isEmpty) return null;
      return Journey(
        id:        j.hashCode.toString(),
        legs:      legs,
        departure: legs.first.departure,
        arrival:   legs.last.arrival,
        transfers: (legs.length - 1).clamp(0, 99),
      );
    } catch (_) {
      return null;
    }
  }

  JourneyLeg? _parseLeg(Map<String, dynamic> l) {
    try {
      final origin      = l['origin']      as Map<String, dynamic>? ?? {};
      final destination = l['destination'] as Map<String, dynamic>? ?? {};
      final lineJson    = l['line']        as Map<String, dynamic>? ?? {};
      final dep = DateTime.parse(
          (l['departure'] as String?) ?? (l['plannedDeparture'] as String?) ?? '');
      final arr = DateTime.parse(
          (l['arrival'] as String?) ?? (l['plannedArrival'] as String?) ?? '');
      final depDelay = l['departureDelay'] as int?;

      return JourneyLeg(
        from: Station(
            id: origin['id']?.toString() ?? '',
            name: origin['name']?.toString() ?? '?',
            lines: []),
        to: Station(
            id: destination['id']?.toString() ?? '',
            name: destination['name']?.toString() ?? '?',
            lines: []),
        line:         _lineFromProduct(lineJson, lineJson['name']?.toString() ?? '?'),
        departure:    dep,
        arrival:      arr,
        delayMinutes: depDelay != null ? depDelay ~/ 60 : null,
      );
    } catch (_) {
      return null;
    }
  }

  Departure? _parseDeparture(Map<String, dynamic> d) {
    try {
      final lineJson = d['line'] as Map<String, dynamic>? ?? {};
      final planned  = DateTime.parse(
          (d['plannedWhen'] as String?) ?? (d['when'] as String?) ?? '');
      final delay    = d['delay'] as int?;
      final platform = d['plannedPlatform']?.toString() ??
          d['platform']?.toString() ?? '–';
      final cancelled = d['cancelled'] as bool? ?? false;

      return Departure(
        id:            d.hashCode.toString(),
        line:          _lineFromProduct(lineJson, lineJson['name']?.toString() ?? '?'),
        destination:   (d['direction'] as String?) ?? '?',
        scheduledTime: planned,
        delayMinutes:  delay != null ? delay ~/ 60 : null,
        platform:      platform,
        isCancelled:   cancelled,
      );
    } catch (_) {
      return null;
    }
  }
}
