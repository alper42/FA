import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/transit_service.dart';
import '../widgets/journey_card.dart';
import 'station_search_screen.dart';
import 'journey_detail_screen.dart';
import 'departures_screen.dart';

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
      body: IndexedStack(
        index: _tab,
        children: const [
          _RoutingTab(),
          DeparturesScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1220),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.route_rounded,
                  label: 'Verbindung',
                  active: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _NavItem(
                  icon: Icons.schedule_rounded,
                  label: 'Abfahrten',
                  active: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF4A9EFF) : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Routing Tab ──────────────────────────────────────────────────────────────

class _RoutingTab extends StatelessWidget {
  const _RoutingTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _SearchSection()),
        Consumer<TransitService>(
          builder: (ctx, svc, _) {
            if (svc.isLoading) {
              return const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF0057B8)),
                      SizedBox(height: 16),
                      Text(
                        'Verbindungen werden gesucht...',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (svc.journeys.isEmpty && svc.origin.isNotEmpty) {
              return const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Keine Verbindungen gefunden',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              );
            }
            if (svc.journeys.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0057B8).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_transit_filled_rounded,
                          color: Color(0xFF0057B8),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Wo möchtest du hin?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gib Start und Ziel ein\num Verbindungen zu suchen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => JourneyCard(
                  journey: svc.journeys[i],
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) =>
                          JourneyDetailScreen(journey: svc.journeys[i]),
                    ),
                  ),
                ),
                childCount: svc.journeys.length,
              ),
            );
          },
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

// ─── Search Section ───────────────────────────────────────────────────────────

class _SearchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── App header ───────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0057B8), Color(0xFF00A650)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'FAA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FAA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Fahrplanauskunft App',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // ── Search card ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF131929),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                _StationField(isOrigin: true),
                Divider(color: Colors.white.withOpacity(0.07), height: 1),
                _StationField(isOrigin: false),
                Divider(color: Colors.white.withOpacity(0.07), height: 1),
                _TimeRow(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── Search button ────────────────────────────────────────────
          Consumer<TransitService>(
            builder: (ctx, svc, _) {
              final canSearch = svc.origin.isNotEmpty && svc.destination.isNotEmpty;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canSearch ? () => svc.searchJourneys() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0057B8),
                    disabledBackgroundColor: const Color(0xFF0057B8).withOpacity(0.3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Verbindung suchen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StationField extends StatelessWidget {
  final bool isOrigin;
  const _StationField({required this.isOrigin});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransitService>(
      builder: (ctx, svc, _) {
        final value = isOrigin ? svc.origin : svc.destination;
        final isEmpty = value.isEmpty;

        return GestureDetector(
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: svc,
                child: StationSearchScreen(isOrigin: isOrigin),
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isOrigin
                        ? const Color(0xFF0057B8).withOpacity(0.2)
                        : const Color(0xFF00A650).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOrigin ? Icons.circle_outlined : Icons.location_on_rounded,
                    color: isOrigin ? const Color(0xFF4A9EFF) : const Color(0xFF00A650),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOrigin ? 'Von' : 'Nach',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEmpty ? (isOrigin ? 'Startpunkt eingeben' : 'Ziel eingeben') : value,
                        style: TextStyle(
                          color: isEmpty ? Colors.white24 : Colors.white,
                          fontSize: 15,
                          fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isOrigin)
                  GestureDetector(
                    onTap: () => svc.swapStations(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.swap_vert_rounded,
                        color: Colors.white.withOpacity(0.5),
                        size: 18,
                      ),
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

class _TimeRow extends StatefulWidget {
  @override
  State<_TimeRow> createState() => _TimeRowState();
}

class _TimeRowState extends State<_TimeRow> {
  bool _isDeparture = true;

  Future<void> _pickTime(BuildContext context) async {
    final svc = context.read<TransitService>();
    final now = svc.travelTime;
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF0057B8)),
        ),
        child: child!,
      ),
    );
    if (picked == null || !context.mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF0057B8)),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null || !context.mounted) return;
    final dt = DateTime(
      picked.year, picked.month, picked.day,
      pickedTime.hour, pickedTime.minute,
    );
    svc.setTravelTime(dt, _isDeparture);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransitService>(
      builder: (ctx, svc, _) {
        final fmt = DateFormat('EE, d. MMM · HH:mm', 'de_DE');
        final isNow = svc.travelTime.difference(DateTime.now()).abs() <
            const Duration(minutes: 1);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Departure / Arrival toggle
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _ToggleBtn(
                      label: 'Ab',
                      active: _isDeparture,
                      onTap: () => setState(() {
                        _isDeparture = true;
                        svc.setTravelTime(svc.travelTime, true);
                      }),
                    ),
                    _ToggleBtn(
                      label: 'An',
                      active: !_isDeparture,
                      onTap: () => setState(() {
                        _isDeparture = false;
                        svc.setTravelTime(svc.travelTime, false);
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Time selector
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(context),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isNow ? 'Jetzt' : fmt.format(svc.travelTime),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Reset to now
              if (!isNow) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => svc.setTravelTime(DateTime.now(), _isDeparture),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0057B8).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Jetzt',
                        style: TextStyle(
                          color: Color(0xFF4A9EFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 32,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0057B8) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
