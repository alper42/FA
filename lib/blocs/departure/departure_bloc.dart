import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/transit_models.dart';
import '../../services/transit_service.dart';

part 'departure_event.dart';
part 'departure_state.dart';

class DepartureBloc extends Bloc<DepartureEvent, DepartureState> {
  final TransitService _service;

  String _lastStationId   = '';
  String _lastStationName = '';

  DepartureBloc({TransitService? service})
      : _service = service ?? TransitService(),
        super(DepartureInitial()) {
    on<LoadDepartures>(_onLoad);
    on<RefreshDepartures>(_onRefresh);
  }

  Future<void> _onLoad(
      LoadDepartures event, Emitter<DepartureState> emit) async {
    _lastStationId   = event.stationId;
    _lastStationName = event.stationName;
    emit(DepartureLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
      RefreshDepartures event, Emitter<DepartureState> emit) async {
    if (_lastStationId.isEmpty) return;
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<DepartureState> emit) async {
    try {
      final deps = await _service.fetchDepartures(_lastStationId);
      if (deps.isEmpty) {
        emit(DepartureError(
            message: 'Keine Abfahrten gefunden',
            stationName: _lastStationName));
      } else {
        emit(DepartureLoaded(
          departures:  deps,
          stationName: _lastStationName,
          stationId:   _lastStationId,
        ));
      }
    } catch (e) {
      emit(DepartureError(
          message: 'Keine Verbindung zur DB API',
          stationName: _lastStationName));
    }
  }
}
