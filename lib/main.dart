import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'blocs/journey/journey_bloc.dart';
import 'blocs/departure/departure_bloc.dart';
import 'blocs/station_search/station_search_bloc.dart';
import 'screens/home_screen.dart';
import 'services/transit_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE', null);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FAAApp());
}

class FAAApp extends StatelessWidget {
  const FAAApp({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TransitService();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => JourneyBloc(service: service)),
        BlocProvider(create: (_) => DepartureBloc(service: service)
          ..add(LoadDepartures(
              stationId: '8000261', stationName: 'München Hbf'))),
        BlocProvider(create: (_) => StationSearchBloc(service: service)),
      ],
      child: MaterialApp(
        title: 'FA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0057B8),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0E1A),
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
