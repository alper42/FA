import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transit_models.dart';
import 'line_badge.dart';

class JourneyCard extends StatelessWidget {
  final Journey journey;
  final VoidCallback? onTap;

  const JourneyCard({super.key, required this.journey, this.onTap});

  String _fmt(DateTime dt) => DateFormat('HH:mm').format(dt);
  String _dur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h ${m}min';
    return '${m} min';
  }

  @override
  Widget build(BuildContext context) {
    final hasDelay = journey.legs.any((l) => (l.delayMinutes ?? 0) > 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDelay
                ? Colors.orange.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Time row ──────────────────────────────────────────────
              Row(
                children: [
                  _TimeDisplay(
                    time: _fmt(journey.departure),
                    label: 'Abfahrt',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DurationBar(
                      duration: _dur(journey.totalDuration),
                      transfers: journey.transfers,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _TimeDisplay(
                    time: _fmt(journey.arrival),
                    label: 'Ankunft',
                    alignRight: true,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // ── Lines row ─────────────────────────────────────────────
              Row(
                children: [
                  ...journey.legs.map((leg) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: LineBadge(line: leg.line),
                      )),
                  const Spacer(),
                  if (hasDelay)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+${journey.legs.where((l) => l.delayMinutes != null).first.delayMinutes} Min',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (journey.transfers == 0)
                    _Chip(label: 'Direkt', color: const Color(0xFF00A650)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String time;
  final String label;
  final bool alignRight;

  const _TimeDisplay({
    required this.time,
    required this.label,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _DurationBar extends StatelessWidget {
  final String duration;
  final int transfers;

  const _DurationBar({required this.duration, required this.transfers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          duration,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0057B8), Color(0xFF00A650)],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF131929),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                transfers == 0
                    ? '→'
                    : '${transfers}× Um${transfers == 1 ? 'stieg' : 'stiege'}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
