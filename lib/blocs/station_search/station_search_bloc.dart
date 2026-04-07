import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/transit_models.dart';
import '../../services/transit_service.dart';

part 'station_search_event.dart';
part 'station_search_state.dart';

class StationSearchBloc extends Bloc<StationSearchEvent, StationSearchState> {
  final TransitService _service;

  StationSearchBloc({TransitService? service})
      : _service = service ?? TransitService(),
        super(StationSearchInitial()) {
    on<SearchStations>(_onSearch);
    on<ClearSearch>(_onClear);
  }

  Future<void> _onSearch(
      SearchStations event, Emitter<StationSearchState> emit) async {
    if (event.query.length < 2) {
      emit(StationSearchInitial());
      return;
    }
    emit(StationSearchLoading());
    try {
      final results = await _service.fetchStations(event.query);
      emit(StationSearchLoaded(results));
    } catch (e) {
      final fallback = _service.fallbackStations(event.query);
      emit(StationSearchError(
        message: 'Keine Verbindung – Fallback wird angezeigt',
        fallbackResults: fallback,
      ));
    }
  }

  void _onClear(ClearSearch event, Emitter<StationSearchState> emit) {
    emit(StationSearchInitial());
  }
}
