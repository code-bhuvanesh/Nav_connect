import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:sist_nav_connect/data/model/bus.dart';
import 'package:sist_nav_connect/features/settings/bloc/settings_bloc.dart';

import 'features/set_locaiton_page/bloc/set_location_bloc.dart';
import 'features/set_locaiton_page/set_location_page.dart';
import 'features/homepage/homepage.dart';
import 'features/settings/settings_page.dart';
import 'features/share_location/bloc/sharelocation_bloc.dart';
import 'features/share_location/share_location.dart';
import 'features/homepage/bloc/bus_bloc.dart';
import 'features/mainbloc/main_bloc.dart';
import 'features/map_view_page/bloc/mapbloc_bloc.dart';
import 'features/map_view_page/mapviewpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(BlocProvider(
    create: (context) => MainBloc(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  PageRouteBuilder _pageTransition({required Widget child}) {
    //this is just a dummy transition function so onGenerateRoute works
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomePage.routename:
        return _pageTransition(
          child: BlocProvider(
            create: (context) => BusBloc(),
            child: const HomePage(),
          ),
        );
      case MapViewPage.routename:
        return _pageTransition(
          child: BlocProvider(
            create: (context) => MapBloc(),
            child: MapViewPage(bus: settings.arguments as Bus),
          ),
        );
      case ShareLocation.routename:
        return _pageTransition(
          child: BlocProvider(
            create: (context) => SharelocationBloc(),
            child: const ShareLocation(),
          ),
        );
      case SetLocationPage.routename:
        return _pageTransition(
          child: BlocProvider(
            create: (context) => SetLocationBloc(),
            child: const SetLocationPage(),
          ),
        );
      case SettingsPage.routename:
        return _pageTransition(
          child: BlocProvider(
            create: (context) => SettingsBloc(),
            child: const SettingsPage(),
          ),
        );
    }

    return _pageTransition(
        child: BlocProvider(
      create: (context) => BusBloc(),
      child: const HomePage(),
    ));
  }

  Future<void> changeRefreshrate() async {
    try {
      var modes = await FlutterDisplayMode.supported;
      // print("display modes");
      // print(modes);
      // print("active dispaly mode");
      await FlutterDisplayMode.setPreferredMode(modes[1]);
      // print("new active dispaly mode");
      await FlutterDisplayMode.active;
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    changeRefreshrate();
    return MaterialApp(
      title: 'sist nav connect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          displayMedium: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          displaySmall: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          headlineLarge: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
          headlineMedium: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          headlineSmall: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          titleLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          titleMedium: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          titleSmall: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
          bodyLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
          bodyMedium: TextStyle(
              fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white),
          bodySmall: TextStyle(
              fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),
          labelLarge: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          labelMedium: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          labelSmall: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
    );
  }
}
