import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_redux/flutter_redux.dart';
import "package:jobix/src/screens/navigator.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:jobix/src/store/store.dart';

import 'routing.dart';
import 'auth.dart';

class Sigeagro extends StatefulWidget {
  const Sigeagro({Key? key}) : super(key: key);

  @override
  State<Sigeagro> createState() => _SigeagroState();
}

class _SigeagroState extends State<Sigeagro> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  final _navigatorKey = GlobalKey<NavigatorState>();
  late final RouteState _routeState;
  late final SimpleRouterDelegate _routerDelegate;
  late final TemplateRouteParser _routeParser;

  final Color _primaryColor = HexColor("#799941");
  final Color _secondaryColor = HexColor("#415E28");

  final ThemeData theme = ThemeData();

  User? loggedInUser; // Variable para almacenar los datos del usuario logeado

  @override
  void initState() {
    /// Configure the parser with all of the app's allowed path templates.
    _routeParser = TemplateRouteParser(
      allowedPaths: [
        '/home',
        '/signin',
        // Empleados
        '/employees',
        '/employees_home',
        '/employees_actives',
        '/employees_pasive',
        '/add_employee',
        '/add_employee?new=true',
        '/edit_employee/:employeeId',
        '/employee/:employeeId',
        // Vehiculos
        '/vehicles',
        '/vehicles_actives',
        '/vehicles_pasive',
        '/add_vehicle',
        '/edit_vehicle/:vehicleId',
        '/vehicle/:vehicleId',
        // Producción
        '/production_home',
        '/porcicultura_home',
      ],
      guard: _guard,
      initialRoute: '/signin',
    );

    _routeState = RouteState(_routeParser);

    _routerDelegate = SimpleRouterDelegate(
      routeState: _routeState,
      navigatorKey: _navigatorKey,
      builder: (context) => SigeagroNavigator(
        navigatorKey: _navigatorKey,
        loggedInUser:
            loggedInUser, // Pasa los datos del usuario logeado a SigeagroNavigator
      ),
    );

    // Listen for when the user logs out and display the signin screen.
    _authService.signedInStream.listen(_handleAuthStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => RouteStateScope(
        notifier: _routeState,
        child: FirebaseAuthScope(
          authService: _authService,
          child: StoreProvider(
            store: store,
            child: MaterialApp.router(
              routerDelegate: _routerDelegate,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale("es")],
              routeInformationParser: _routeParser,
              // Revert back to pre-Flutter-2.5 transition behavior:
              // https://github.com/flutter/flutter/issues/82053
              theme: ThemeData(
                colorScheme: theme.colorScheme.copyWith(
                  primary: _primaryColor,
                  secondary: _secondaryColor,
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                  },
                ),
              ),
            ),
          ),
        ),
      );

  Future<ParsedRoute> _guard(ParsedRoute from) async {
    final signedIn = _authService.currentUser != null;
    final signInRoute = ParsedRoute('/signin', '/signin', {}, {});

    // Go to /signin if the user is not signed in
    if (!signedIn && from != signInRoute) {
      return signInRoute;
    }

    // Go to /books if the user is signed in and tries to go to /signin.
    else if (signedIn && from == signInRoute) {
      return ParsedRoute('/home', '/home', {}, {});
    }

    return from;
  }

  void _handleAuthStateChanged(User? user) {
    if (user == null) {
      _routeState.go('/signin');
      setState(() {
        loggedInUser = null;
      });
    } else {
      setState(() {
        loggedInUser = _authService.currentUser;
      });
    }
  }

  @override
  void dispose() {
    _authService.dispose();
    _routeState.dispose();
    _routerDelegate.dispose();
    super.dispose();
  }
}
