part of 'journey_bloc.dart';

abstract class JourneyState {}

class JourneyInitial extends JourneyState {
  final String originName;
  final String originId;
  final String destinationName;
  final String destinationId;
  final DateTime travelTime;
  final bool isDeparture;

  JourneyInitial({
    this.originName = '',
    this.originId = '',
    this.destinationName = '',
    this.destinationId = '',
    DateTime? travelTime,
    this.isDeparture = true,
  }) : travelTime = travelTime ?? DateTime.now();

  JourneyInitial copyWith({
    String? originName,
    String? originId,
    String? destinationName,
    String? destinationId,
    DateTime? travelTime,
    bool? isDeparture,
  }) {
    return JourneyInitial(
      originName:       originName       ?? this.originName,
      originId:         originId         ?? this.originId,
      destinationName:  destinationName  ?? this.destinationName,
      destinationId:    destinationId    ?? this.destinationId,
      travelTime:       travelTime       ?? this.travelTime,
      isDeparture:      isDeparture      ?? this.isDeparture,
    );
  }
}

class JourneyLoading extends JourneyState {}

class JourneyLoaded extends JourneyState {
  final List<Journey> journeys;
  final String originName;
  final String destinationName;

  JourneyLoaded({
    required this.journeys,
    required this.originName,
    required this.destinationName,
  });
}

class JourneyError extends JourneyState {
  final String message;
  JourneyError(this.message);
}
