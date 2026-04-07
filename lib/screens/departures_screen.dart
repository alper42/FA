import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/departure/departure_bloc.dart';
import '../blocs/station_search/station_search_bloc.dart';
import '../widgets/departure_tile.dart';
import '../services/transit_service.dart';

class DeparturesScreen extends StatelessWidget {
  const DeparturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepartureBloc, DepartureState>(
      builder: (context, state) {
        final stationName = state is DepartureLoaded
            ? state.stationName
            : state is DepartureError
                ? state.stationName
                : 'München Hbf';

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          body: RefreshIndicator(
            color: const Color(0xFF0057B8),
            onRefresh: () async =>
                context.read<DepartureBloc>().add(RefreshDepartures()),
            child: CustomScrollView(
              slivers: [
                // ── App Bar ───────────────────────────────────────────
                SliverAppBar(
                  backgroundColor: const Color(0xFF0A0E1A),
                  foregroundColor: Colors.white,
                  pinned: true,
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Abfahrten',
                            style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: () => _showStationPicker(context),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stationName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.expand_more_rounded,
                                  color: Colors.white54, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Liste ─────────────────────────────────────────────
                if (state is DepartureLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF0057B8)),
                    ),
                  )
                else if (state is DepartureError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              color: Colors.white38, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message,
                              style:
                                  const TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                  )
                else if (state is DepartureLoaded)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => DepartureTile(
                          departure: state.departures[i]),
                      childCount: state.departures.length,
                    ),
                  )
                else
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('Keine Abfahrten',
                          style: TextStyle(color: Colors.white54)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStationPicker(BuildContext context) {
    // Neue StationSearchBloc-Instanz nur für den Picker
    final searchBloc =
        StationSearchBloc(service: TransitService())
          ..add(SearchStations('München'));

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131929),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: searchBloc,
        child: _StationPickerSheet(
          onSelected: (name, id) {
            context
                .read<DepartureBloc>()
                .add(LoadDepartures(stationId: id, stationName: name));
          },
        ),
      ),
    );
  }
}

// ─── Station Picker Sheet ────────────────────────────────────────────────────
class _StationPickerSheet extends StatefulWidget {
  final void Function(String name, String id) onSelected;
  const _StationPickerSheet({required this.onSelected});

  @override
  State<_StationPickerSheet> createState() => _StationPickerSheetState();
}

class _StationPickerSheetState extends State<_StationPickerSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (ctx, scroll) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Haltestelle wählen',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) =>
                  context.read<StationSearchBloc>().add(SearchStations(v)),
              decoration: InputDecoration(
                hintText: 'Suchen...',
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
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<StationSearchBloc, StationSearchState>(
              builder: (ctx, state) {
                if (state is StationSearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF0057B8)),
                  );
                }
                final results = state is StationSearchLoaded
                    ? state.results
                    : state is StationSearchError
                        ? state.fallbackResults
                        : <dynamic>[];

                return ListView.builder(
                  controller: scroll,
                  itemCount: results.length,
                  itemBuilder: (ctx, i) {
                    final s = results[i];
                    return ListTile(
                      leading: const Icon(Icons.place_rounded,
                          color: Color(0xFF0057B8)),
                      title: Text(s.name,
                          style:
                              const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(ctx);
                        widget.onSelected(s.name, s.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
