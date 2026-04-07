import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/transit_models.dart';
import '../../services/transit_service.dart';

part 'journey_event.dart';
part 'journey_state.dart';

class JourneyBloc extends Bloc<JourneyEvent, JourneyState> {
  final TransitService _service;

  JourneyBloc({TransitService? service})
      : _service = service ?? TransitService(),
        super(JourneyInitial()) {
    on<SetOrigin>(_onSetOrigin);
    on<SetDestination>(_onSetDestination);
    on<SetTravelTime>(_onSetTravelTime);
    on<SwapStations>(_onSwap);
    on<SearchJourneys>(_onSearch);
    on<ResetJourneys>(_onReset);
  }

  JourneyInitial get _currentInitial =>
      state is JourneyInitial ? state as JourneyInitial : JourneyInitial();

  void _onSetOrigin(SetOrigin event, Emitter<JourneyState> emit) {
    emit(_currentInitial.copyWith(
        originName: event.name, originId: event.id));
  }

  void _onSetDestination(SetDestination event, Emitter<JourneyState> emit) {
    emit(_currentInitial.copyWith(
        destinationName: event.name, destinationId: event.id));
  }

  void _onSetTravelTime(SetTravelTime event, Emitter<JourneyState> emit) {
    emit(_currentInitial.copyWith(
        travelTime: event.dateTime, isDeparture: event.isDeparture));
  }

  void _onSwap(SwapStations event, Emitter<JourneyState> emit) {
    emit(_currentInitial.copyWith(
      originName:      event.destinationName,
      originId:        event.destinationId,
      destinationName: event.originName,
      destinationId:   event.originId,
    ));
  }

  Future<void> _onSearch(
      SearchJourneys event, Emitter<JourneyState> emit) async {
    final current = _currentInitial;
    emit(JourneyLoading());
    try {
      final journeys = await _service.fetchJourneys(
        fromId:      event.originId,
        toId:        event.destinationId,
        travelTime:  event.travelTime,
        isDeparture: event.isDeparture,
      );
      if (journeys.isEmpty) {
        emit(JourneyError('Keine Verbindungen gefunden'));
      } else {
        emit(JourneyLoaded(
          journeys:        journeys,
          originName:      current.originName,
          destinationName: current.destinationName,
        ));
      }
    } catch (e) {
      emit(JourneyError('Keine Verbindung – bitte Internetverbindung prüfen'));
    }
  }

  void _onReset(ResetJourneys event, Emitter<JourneyState> emit) {
    emit(JourneyInitial());
  }
}
