import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transit_service.dart';
import '../widgets/departure_tile.dart';

class DeparturesScreen extends StatefulWidget {
  const DeparturesScreen({super.key});

  @override
  State<DeparturesScreen> createState() => _DeparturesScreenState();
}

class _DeparturesScreenState extends State<DeparturesScreen> {
  String _stationName = 'München Hbf';
  String _stationId   = '8000261';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _load() =>
      context.read<TransitService>().loadDepartures(_stationId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0E1A),
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    onTap: _showStationPicker,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _stationName,
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

          // ── Liste ────────────────────────────────────────────────────
          Consumer<TransitService>(
            builder: (ctx, svc, _) {
              if (svc.isLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child:
                    CircularProgressIndicator(color: Color(0xFF0057B8)),
                  ),
                );
              }
              if (svc.error != null && svc.departures.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: Colors.white38, size: 48),
                        const SizedBox(height: 12),
                        Text(svc.error!,
                            style: const TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                );
              }
              if (svc.departures.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Keine Abfahrten',
                        style: TextStyle(color: Colors.white54)),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) =>
                      DepartureTile(departure: svc.departures[i]),
                  childCount: svc.departures.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Haltestellenpicker mit Suche ────────────────────────────────────────
  void _showStationPicker() {
    _searchCtrl.clear();
    context.read<TransitService>().searchStations('München');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131929),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: context.read<TransitService>(),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            builder: (ctx, scroll) => Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
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
                // Suchfeld
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) =>
                        context.read<TransitService>().searchStations(v),
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
                // Ergebnisse
                Expanded(
                  child: Consumer<TransitService>(
                    builder: (ctx, svc, _) {
                      if (svc.isSearching) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF0057B8)),
                        );
                      }
                      return ListView.builder(
                        controller: scroll,
                        itemCount: svc.searchResults.length,
                        itemBuilder: (ctx, i) {
                          final s = svc.searchResults[i];
                          return ListTile(
                            leading: const Icon(Icons.place_rounded,
                                color: Color(0xFF0057B8)),
                            title: Text(s.name,
                                style: const TextStyle(color: Colors.white)),
                            onTap: () {
                              setState(() {
                                _stationName = s.name;
                                _stationId   = s.id;
                              });
                              Navigator.pop(ctx);
                              _load();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}