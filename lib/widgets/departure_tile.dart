import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transit_models.dart';
import 'line_badge.dart';

class DepartureTile extends StatelessWidget {
  final Departure departure;

  const DepartureTile({super.key, required this.departure});

  @override
  Widget build(BuildContext context) {
    final minutes = departure.minutesUntilDeparture;
    final hasDelay = (departure.delayMinutes ?? 0) > 0;
    final timeStr = DateFormat('HH:mm').format(departure.scheduledTime);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: departure.isCancelled
            ? const Color(0xFF2A0A0A)
            : const Color(0xFF131929),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: departure.isCancelled
              ? Colors.red.withOpacity(0.3)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          LineBadge(line: departure.line),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  departure.destination,
                  style: TextStyle(
                    color: departure.isCancelled
                        ? Colors.red.withOpacity(0.7)
                        : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: departure.isCancelled
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.train_rounded,
                      size: 11,
                      color: Colors.white.withOpacity(0.35),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Gleis ${departure.platform}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (departure.isCancelled)
                const Text(
                  'Ausfall',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                )
              else
                _MinutesDisplay(minutes: minutes, hasDelay: hasDelay),
              if (!departure.isCancelled) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                        decoration: hasDelay ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (hasDelay) ...[
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(departure.actualTime),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MinutesDisplay extends StatelessWidget {
  final int minutes;
  final bool hasDelay;

  const _MinutesDisplay({required this.minutes, required this.hasDelay});

  @override
  Widget build(BuildContext context) {
    final color = hasDelay
        ? Colors.orange
        : minutes <= 2
            ? Colors.red
            : minutes <= 5
                ? Colors.yellow
                : Colors.white;

    return Row(
      children: [
        Text(
          minutes == 0 ? 'Jetzt' : '$minutes',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        if (minutes > 0)
          Text(
            ' min',
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
