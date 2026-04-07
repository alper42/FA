import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/journey/journey_bloc.dart';
import '../blocs/station_search/station_search_bloc.dart';
import '../services/transit_service.dart';

class StationSearchScreen extends StatefulWidget {
  final bool isOrigin;
  const StationSearchScreen({super.key, required this.isOrigin});

  @override
  State<StationSearchScreen> createState() => _StationSearchScreenState();
}

class _StationSearchScreenState extends State<StationSearchScreen> {
  final _ctrl = TextEditingController();
  late StationSearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = StationSearchBloc(service: TransitService());
    _ctrl.addListener(() =>
        _searchBloc.add(SearchStations(_ctrl.text)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _searchBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0E1A),
          foregroundColor: Colors.white,
          title: Text(
            widget.isOrigin ? 'Von wo?' : 'Nach wo?',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Haltestelle suchen...',
                  hintStyle:
                      TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: Icon(Icons.search,
                      color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: const Color(0xFF1E2436),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<StationSearchBloc, StationSearchState>(
          builder: (context, state) {
            if (state is StationSearchLoading) {
              return const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFF0057B8)),
              );
            }

            if (state is StationSearchError) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Text(state.message,
                            style: const TextStyle(
                                color: Colors.orange, fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(child: _buildList(context, state.fallbackResults)),
                ],
              );
            }

            if (state is StationSearchLoaded) {
              if (state.results.isEmpty) {
                return Center(
                  child: Text('Keine Haltestellen gefunden',
                      style: TextStyle(color: Colors.white38)),
                );
              }
              return _buildList(context, state.results);
            }

            // Initial state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_rounded,
                      color: Colors.white12, size: 64),
                  const SizedBox(height: 12),
                  Text('Mindestens 2 Zeichen eingeben',
                      style: TextStyle(
                          color: Colors.white24, fontSize: 14)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List stations) {
    return ListView.builder(
      itemCount: stations.length,
      itemBuilder: (ctx, i) {
        final station = stations[i];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2436),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.place_rounded,
                color: Color(0xFF0057B8), size: 20),
          ),
          title: Text(station.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Text('ID: ${station.id}',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 11)),
          onTap: () {
            // JourneyBloc updaten
            final journeyBloc = context.read<JourneyBloc>();
            if (widget.isOrigin) {
              journeyBloc.add(SetOrigin(station.name, station.id));
            } else {
              journeyBloc.add(SetDestination(station.name, station.id));
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
