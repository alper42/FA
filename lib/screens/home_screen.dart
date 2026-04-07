import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/journey/journey_bloc.dart';
import '../widgets/journey_card.dart';
import 'departures_screen.dart';
import 'station_search_screen.dart';
import 'journey_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: _tab == 0 ? const _JourneyTab() : const DeparturesScreen(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0F1423),
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: const Color(0xFF0057B8).withOpacity(0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'Verbindung',
          ),
          NavigationDestination(
            icon: Icon(Icons.departure_board_outlined),
            selectedIcon: Icon(Icons.departure_board_rounded),
            label: 'Abfahrten',
          ),
        ],
      ),
    );
  }
}

// ─── Journey Tab ────────────────────────────────────────────────────────────
class _JourneyTab extends StatelessWidget {
  const _JourneyTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JourneyBloc, JourneyState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            _buildAppBar(context),
            _buildSearchCard(context, state),
            _buildResults(context, state),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0A0E1A),
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: const Text(
          'Fahrplanauskunft',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, JourneyState state) {
    final initial = state is JourneyInitial ? state : JourneyInitial();
    final bloc = context.read<JourneyBloc>();

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            // ── Von ──────────────────────────────────────────────────
            _StationField(
              label: 'Von',
              value: initial.originName,
              icon: Icons.trip_origin_rounded,
              color: const Color(0xFF00A650),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<JourneyBloc>(),
                      child: const StationSearchScreen(isOrigin: true),
                    ),
                  ),
                );
              },
            ),
            // ── Swap Button ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Container(width: 2, height: 20, color: Colors.white12),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => bloc.add(SwapStations(
                      originName:      initial.originName,
                      originId:        initial.originId,
                      destinationName: initial.destinationName,
                      destinationId:   initial.destinationId,
                    )),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2840),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.swap_vert_rounded,
                        color: Color(0xFF0057B8),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Nach ─────────────────────────────────────────────────
            _StationField(
              label: 'Nach',
              value: initial.destinationName,
              icon: Icons.location_on_rounded,
              color: const Color(0xFF0057B8),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<JourneyBloc>(),
                      child: const StationSearchScreen(isOrigin: false),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // ── Zeit ─────────────────────────────────────────────────
            _TimeSelector(
              travelTime:  initial.travelTime,
              isDeparture: initial.isDeparture,
              onChanged: (dt, isDep) =>
                  bloc.add(SetTravelTime(dt, isDep)),
            ),
            const SizedBox(height: 14),
            // ── Suchen Button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (initial.originId.isNotEmpty &&
                        initial.destinationId.isNotEmpty)
                    ? () => bloc.add(SearchJourneys(
                          originId:      initial.originId,
                          destinationId: initial.destinationId,
                          travelTime:    initial.travelTime,
                          isDeparture:   initial.isDeparture,
                        ))
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0057B8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor: Colors.white12,
                ),
                child: const Text(
                  'Verbindungen suchen',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, JourneyState state) {
    if (state is JourneyLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF0057B8)),
        ),
      );
    }

    if (state is JourneyError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  color: Colors.white38, size: 48),
              const SizedBox(height: 12),
              Text(state.message,
                  style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      );
    }

    if (state is JourneyLoaded) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => JourneyCard(
            journey: state.journeys[i],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    JourneyDetailScreen(journey: state.journeys[i]),
              ),
            ),
          ),
          childCount: state.journeys.length,
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

// ─── Station Field Widget ───────────────────────────────────────────────────
class _StationField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StationField({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2035),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11)),
                  Text(
                    value.isEmpty ? 'Haltestelle wählen...' : value,
                    style: TextStyle(
                      color: value.isEmpty
                          ? Colors.white24
                          : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.2), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Time Selector ──────────────────────────────────────────────────────────
class _TimeSelector extends StatelessWidget {
  final DateTime travelTime;
  final bool isDeparture;
  final void Function(DateTime, bool) onChanged;

  const _TimeSelector({
    required this.travelTime,
    required this.isDeparture,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, dd.MM  HH:mm', 'de_DE');

    return Row(
      children: [
        // Abfahrt / Ankunft Toggle
        GestureDetector(
          onTap: () => onChanged(travelTime, !isDeparture),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2035),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isDeparture
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: const Color(0xFF0057B8),
                ),
                const SizedBox(width: 4),
                Text(
                  isDeparture ? 'Ab' : 'An',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Zeit auswählen
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: travelTime,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date == null || !context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(travelTime),
              );
              if (time == null) return;
              onChanged(
                DateTime(date.year, date.month, date.day,
                    time.hour, time.minute),
                isDeparture,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2035),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: Colors.white38),
                  const SizedBox(width: 6),
                  Text(
                    fmt.format(travelTime),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
