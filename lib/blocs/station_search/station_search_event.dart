part of 'station_search_bloc.dart';

abstract class StationSearchEvent {}

/// Sucht Haltestellen nach Eingabe
class SearchStations extends StationSearchEvent {
  final String query;
  SearchStations(this.query);
}

/// Leert die Suchergebnisse
class ClearSearch extends StationSearchEvent {}
