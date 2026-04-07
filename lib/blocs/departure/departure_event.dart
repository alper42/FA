part of 'departure_bloc.dart';

abstract class DepartureEvent {}

/// Lädt Abfahrten für eine Haltestelle
class LoadDepartures extends DepartureEvent {
  final String stationId;
  final String stationName;
  LoadDepartures({required this.stationId, required this.stationName});
}

/// Aktualisiert Abfahrten (Pull-to-refresh)
class RefreshDepartures extends DepartureEvent {}
