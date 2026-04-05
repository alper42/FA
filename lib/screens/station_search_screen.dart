import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transit_models.dart';
import '../services/transit_service.dart';

class StationSearchScreen extends StatefulWidget {
  final bool isOrigin;
  const StationSearchScreen({super.key, required this.isOrigin});

  @override
  State<StationSearchScreen> createState() => _StationSearchScreenState();
}

class _StationSearchScreenState extends State<StationSearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      context.read<TransitService>().searchStations(_ctrl.text);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon:
                Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
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
      body: Consumer<TransitService>(
        builder: (ctx, svc, _) {
          // Ladeindikator
          if (svc.isSearching) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0057B8)),
            );
          }

          // Fehlermeldung
          if (svc.error != null && svc.searchResults.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        color: Colors.white38, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      svc.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fallback-Stationen werden angezeigt',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3), fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          // Keine Ergebnisse
          if (svc.searchResults.isEmpty && _ctrl.text.length >= 2) {
            return Center(
              child: Text(
                'Keine Haltestellen gefunden',
                style: TextStyle(color: Colors.white38),
              ),
            );
          }

          // Hinweis wenn noch nicht getippt
          if (svc.searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, color: Colors.white12, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    'Mindestens 2 Zeichen eingeben',
                    style: TextStyle(color: Colors.white24, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // Ergebnisliste
          return ListView.builder(
            itemCount: svc.searchResults.length,
            itemBuilder: (ctx, i) {
              final station = svc.searchResults[i];
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
                title: Text(
                  station.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'ID: ${station.id}',
                  style:
                  TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                ),
                onTap: () {
                  final svc = context.read<TransitService>();
                  if (widget.isOrigin) {
                    svc.setOrigin(station.name, station.id);
                  } else {
                    svc.setDestination(station.name, station.id);
                  }
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}