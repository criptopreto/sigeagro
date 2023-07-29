// Copyright 2021, the Flutter project employees. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobix/src/screens/employee/add_employee.dart';
import 'package:jobix/src/screens/employee/edit_employee.dart';
import 'package:jobix/src/screens/production/porcicultura/porcicultura_home.dart';
import 'package:jobix/src/screens/vehicle/add_vehicle.dart';
import 'package:jobix/src/screens/vehicle/edit_vehicle.dart';
import 'package:jobix/src/screens/vehicle/vehicle_details.dart';

import '../auth.dart';
import '../routing.dart';
import '../screens/login_page.dart';
import '../widgets/fade_transition_page.dart';
import 'employee/employee_details.dart';
import 'scaffold.dart';

/// Builds the top-level navigator for the app. The pages to display are based
/// on the `routeState` that was parsed by the TemplateRouteParser.
class SigeagroNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final User? loggedInUser;

  const SigeagroNavigator({
    required this.navigatorKey,
    required this.loggedInUser,
    super.key,
  });

  @override
  State<SigeagroNavigator> createState() => _SigeagroNavigatorState();
}

class _SigeagroNavigatorState extends State<SigeagroNavigator> {
  final _signInKey = const ValueKey('Sign in');
  // Employee
  final _addEmployeeKey = const ValueKey("Add Employee");
  final _scaffoldKey = const ValueKey('App scaffold');
  final _employeeDetailsKey = const ValueKey('Employee details screen');
  final _employeeEditKey = const ValueKey("Employee edit screen");
  // Vehicle
  final _addVehicleKey = const ValueKey("Add Vehicle");
  final _vehicleDetailsKey = const ValueKey('Vehicle details screen');
  final _vehicleEditKey = const ValueKey("Vehicle edit screen");
  // Porcicultura
  final _porciculturaHomeKey = const ValueKey("Porcicultura Home");

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    final authState = FirebaseAuthScope.of(context);
    final pathTemplate = routeState.route.pathTemplate;

    String selectedEmployee = "";
    String selectedVehicle = "";
    String selectedEditEmployee = "";
    String selectedEditVehicle = "";
    String selectedFarm = "";

    if (pathTemplate == '/employee/:employeeId') {
      selectedEmployee = routeState.route.parameters["employeeId"] ?? "";
    } else if (pathTemplate == "/edit_employee/:employeeId") {
      selectedEditEmployee = routeState.route.parameters["employeeId"] ?? "";
    } else if (pathTemplate == "/edit_vehicle/:vehicleId") {
      selectedEditVehicle = routeState.route.parameters["vehicleId"] ?? "";
    } else if (pathTemplate == "/vehicle/:vehicleId") {
      selectedVehicle = routeState.route.parameters["vehicleId"] ?? "";
    } else if (pathTemplate == "/employees/fijos/:farm") {
      selectedFarm = routeState.route.parameters["farm"] ?? "";
    }

    return Navigator(
      key: widget.navigatorKey,
      onPopPage: (route, dynamic result) {
        // When a page that is stacked on top of the scaffold is popped, display
        // Vehicles.
        if (route.settings is Page &&
            (route.settings as Page).key == _employeeDetailsKey) {
          routeState.go('/employees');
        }

        print((route.settings as Page).arguments);

        if (route.settings is Page &&
            (route.settings as Page).key == _addEmployeeKey) {
          // Realiza el pop sin mostrar el diálogo de confirmación
          routeState.go('/employees_home');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _employeeEditKey) {
          routeState.go("/employees");
        }

        // Vehicles
        if (route.settings is Page &&
            (route.settings as Page).key == _vehicleDetailsKey) {
          routeState.go('/vehicles');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _addVehicleKey) {
          // Realiza el pop sin mostrar el diálogo de confirmación
          routeState.go('/vehicles');
        }

        if (route.settings is Page &&
            (route.settings as Page).key == _vehicleEditKey) {
          routeState.go("/vehicles");
        }

        // Production Porcicultura
        if (route.settings is Page &&
            (route.settings as Page).key == _porciculturaHomeKey) {
          routeState.go('/production_home');
        }

        return route.didPop(result);
      },
      pages: [
        if (routeState.route.pathTemplate == '/signin')
          // Display the sign in screen.
          FadeTransitionPage<void>(
            key: _signInKey,
            child: LoginPage(
              onSignIn: (credentials) async {
                var signedIn = await authState.signIn(
                    credentials.email, credentials.password);
                if (signedIn) {
                  await routeState.go('/home');
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Center(
                    child: Text("Usuario o contraseña inválidos"),
                  )));
                }
              },
            ),
          )
        /*  else if (routeState.route.pathTemplate == "/add_employee")
          FadeTransitionPage<void>(
            key: _addEmployeeKey,
            child: const AddEmployee(),
          ) */
        else ...[
          // Display the app
          FadeTransitionPage<void>(
            key: _scaffoldKey,
            child: BookstoreScaffold(
              loggedInUser: widget.loggedInUser,
            ),
          ),
          // Employee
          if (routeState.route.pathTemplate == "/add_employee")
            MaterialPage<void>(
              key: _addEmployeeKey,
              child: const AddEmployee(),
            )
          else if (selectedEmployee != "")
            MaterialPage<void>(
              key: _employeeDetailsKey,
              child: EmployeeDetailScreen(
                employeeId: selectedEmployee,
              ),
            )
          else if (selectedEditEmployee != "")
            MaterialPage<void>(
              key: _employeeEditKey,
              child: EditEmployee(
                employeeId: selectedEditEmployee,
              ),
            )
          // Vehicle
          else if (routeState.route.pathTemplate == "/add_vehicle")
            MaterialPage<void>(
              key: _addVehicleKey,
              child: const AddVehicle(),
            )
          else if (selectedVehicle != "")
            MaterialPage<void>(
              key: _vehicleDetailsKey,
              child: VehicleDetailScreen(
                vehicleId: selectedVehicle,
              ),
            )
          else if (selectedEditVehicle != "")
            MaterialPage<void>(
              key: _vehicleEditKey,
              child: EditVehicle(
                vehicleId: selectedEditVehicle,
              ),
            )
          // Production
          else if (routeState.route.pathTemplate == "/porcicultura_home")
            MaterialPage<void>(
              key: _porciculturaHomeKey,
              child: const PorciculturaHome(),
            )
          else if (routeState.route.pathTemplate == "/employees/fijos/:farm")
            MaterialPage<void>(
              key: _porciculturaHomeKey,
              child: const PorciculturaHome(),
            )
        ],
      ],
    );
  }
}
