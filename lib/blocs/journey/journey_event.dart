part of 'journey_bloc.dart';

abstract class JourneyEvent {}

/// Startet die Verbindungssuche
class SearchJourneys extends JourneyEvent {
  final String originId;
  final String destinationId;
  final DateTime travelTime;
  final bool isDeparture;

  SearchJourneys({
    required this.originId,
    required this.destinationId,
    required this.travelTime,
    required this.isDeparture,
  });
}

/// Setzt Start und Ziel zurück
class ResetJourneys extends JourneyEvent {}

/// Tauscht Start und Ziel
class SwapStations extends JourneyEvent {
  final String originName;
  final String originId;
  final String destinationName;
  final String destinationId;

  SwapStations({
    required this.originName,
    required this.originId,
    required this.destinationName,
    required this.destinationId,
  });
}

/// Setzt Start-Haltestelle
class SetOrigin extends JourneyEvent {
  final String name;
  final String id;
  SetOrigin(this.name, this.id);
}

/// Setzt Ziel-Haltestelle
class SetDestination extends JourneyEvent {
  final String name;
  final String id;
  SetDestination(this.name, this.id);
}

/// Aktualisiert die Reisezeit
class SetTravelTime extends JourneyEvent {
  final DateTime dateTime;
  final bool isDeparture;
  SetTravelTime(this.dateTime, this.isDeparture);
}
