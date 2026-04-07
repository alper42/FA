part of 'departure_bloc.dart';

abstract class DepartureState {}

class DepartureInitial extends DepartureState {}

class DepartureLoading extends DepartureState {}

class DepartureLoaded extends DepartureState {
  final List<Departure> departures;
  final String stationName;
  final String stationId;

  DepartureLoaded({
    required this.departures,
    required this.stationName,
    required this.stationId,
  });
}

class DepartureError extends DepartureState {
  final String message;
  final String stationName;
  DepartureError({required this.message, required this.stationName});
}
