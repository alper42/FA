part of 'station_search_bloc.dart';

abstract class StationSearchState {}

class StationSearchInitial extends StationSearchState {}

class StationSearchLoading extends StationSearchState {}

class StationSearchLoaded extends StationSearchState {
  final List<Station> results;
  StationSearchLoaded(this.results);
}

class StationSearchError extends StationSearchState {
  final String message;
  final List<Station> fallbackResults;
  StationSearchError({required this.message, required this.fallbackResults});
}
