import 'package:flutter/material.dart';

enum LineType { sbahn, ubahn, tram, bus, regional }

class TransitLine {
  final String id;
  final String name;
  final LineType type;
  final Color color;

  const TransitLine({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
  });
}

class Station {
  final String id;
  final String name;
  final List<TransitLine> lines;
  final String? platform;

  const Station({
    required this.id,
    required this.name,
    required this.lines,
    this.platform,
  });
}

class Departure {
  final String id;
  final TransitLine line;
  final String destination;
  final DateTime scheduledTime;
  final int? delayMinutes;
  final String platform;
  final bool isCancelled;

  const Departure({
    required this.id,
    required this.line,
    required this.destination,
    required this.scheduledTime,
    this.delayMinutes,
    required this.platform,
    this.isCancelled = false,
  });

  DateTime get actualTime {
    if (delayMinutes != null) {
      return scheduledTime.add(Duration(minutes: delayMinutes!));
    }
    return scheduledTime;
  }

  int get minutesUntilDeparture {
    final now = DateTime.now();
    final diff = actualTime.difference(now).inMinutes;
    return diff < 0 ? 0 : diff;
  }
}

class JourneyLeg {
  final Station from;
  final Station to;
  final TransitLine line;
  final DateTime departure;
  final DateTime arrival;
  final int? delayMinutes;

  const JourneyLeg({
    required this.from,
    required this.to,
    required this.line,
    required this.departure,
    required this.arrival,
    this.delayMinutes,
  });

  Duration get duration => arrival.difference(departure);
}

class Journey {
  final String id;
  final List<JourneyLeg> legs;
  final DateTime departure;
  final DateTime arrival;
  final int transfers;

  const Journey({
    required this.id,
    required this.legs,
    required this.departure,
    required this.arrival,
    required this.transfers,
  });

  Duration get totalDuration => arrival.difference(departure);
}
