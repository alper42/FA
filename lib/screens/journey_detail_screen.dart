import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transit_models.dart';
import '../widgets/line_badge.dart';

class JourneyDetailScreen extends StatelessWidget {
  final Journey journey;
  const JourneyDetailScreen({super.key, required this.journey});

  String _fmt(DateTime dt) => DateFormat('HH:mm').format(dt);
  String _dur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m} min';
    return '$m min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        title: const Text(
          'Verbindungsdetails',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Summary card ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0057B8), Color(0xFF003D82)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fmt(journey.departure),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const Text(
                        'Abfahrt',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        _dur(journey.totalDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 2,
                        color: Colors.white30,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${journey.transfers} Umstieg${journey.transfers == 1 ? '' : 'e'}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _fmt(journey.arrival),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const Text(
                        'Ankunft',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Legs ──────────────────────────────────────────────────
            ...journey.legs.asMap().entries.map((entry) {
              final i = entry.key;
              final leg = entry.value;
              return _LegCard(leg: leg, isLast: i == journey.legs.length - 1);
            }),
          ],
        ),
      ),
    );
  }
}

class _LegCard extends StatelessWidget {
  final JourneyLeg leg;
  final bool isLast;

  const _LegCard({required this.leg, required this.isLast});

  String _fmt(DateTime dt) => DateFormat('HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    final hasDelay = (leg.delayMinutes ?? 0) > 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131929),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasDelay
                  ? Colors.orange.withOpacity(0.4)
                  : Colors.white.withOpacity(0.07),
            ),
          ),
          child: Column(
            children: [
              // ── Departure stop ───────────────────────────────────
              _StopRow(
                time: _fmt(leg.departure),
                stationName: leg.from.name,
                isDelay: hasDelay,
                delayMin: leg.delayMinutes,
              ),
              const SizedBox(height: 12),
              // ── Line info ────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 2,
                    height: 40,
                    margin: const EdgeInsets.only(left: 22),
                    decoration: BoxDecoration(
                      color: leg.line.color,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 20),
                  LineBadge(line: leg.line),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Richtung ${leg.to.name}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${leg.duration.inMinutes} Minuten Fahrtzeit',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ── Arrival stop ─────────────────────────────────────
              _StopRow(
                time: _fmt(leg.arrival),
                stationName: leg.to.name,
                isArrival: true,
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 46),
                Icon(
                  Icons.transfer_within_a_station_rounded,
                  color: Colors.white.withOpacity(0.4),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Umstieg · 3 Min Fußweg',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StopRow extends StatelessWidget {
  final String time;
  final String stationName;
  final bool isDelay;
  final int? delayMin;
  final bool isArrival;

  const _StopRow({
    required this.time,
    required this.stationName,
    this.isDelay = false,
    this.delayMin,
    this.isArrival = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 46,
          child: Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isArrival ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            stationName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isDelay && delayMin != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '+$delayMin min',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
