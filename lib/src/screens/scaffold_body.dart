// Copyright 2021, the Flutter project employees. Please see the employees file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:jobix/src/screens/employee/employee_home.dart';
import 'package:jobix/src/screens/employee/employees.dart';
import 'package:jobix/src/screens/employee/employees_actives.dart';
import 'package:jobix/src/screens/employee/employees_pasive.dart';
import 'package:jobix/src/screens/home_page.dart';
import 'package:jobix/src/screens/production/production_home.dart';
import 'package:jobix/src/screens/vehicle/vehicles.dart';

import '../routing.dart';
import '../widgets/fade_transition_page.dart';
import 'scaffold.dart';

/// Displays the contents of the body of [BookstoreScaffold]
class BookstoreScaffoldBody extends StatelessWidget {
  final String searchValue;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const BookstoreScaffoldBody({
    super.key,
    required this.searchValue,
  });

  @override
  Widget build(BuildContext context) {
    var currentRoute = RouteStateScope.of(context).route;

    // A nested Router isn't necessary because the back button behavior doesn't
    // need to be customized.
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, dynamic result) => route.didPop(result),
      pages: [
        if (currentRoute.pathTemplate == '/home')
          const FadeTransitionPage<void>(
            key: ValueKey('home'),
            child: HomeScreen(),
          )
        // Employees
        else if (currentRoute.pathTemplate == '/employees')
          FadeTransitionPage<void>(
            key: const ValueKey('employees'),
            child: EmployeesScreen(
              searchValue: searchValue,
            ),
          )
        else if (currentRoute.pathTemplate.startsWith('/employees_home'))
          const FadeTransitionPage<void>(
            key: ValueKey('employees_home'),
            child: EmployeeHome(),
          )
        else if (currentRoute.pathTemplate.startsWith('/employees_actives'))
          FadeTransitionPage<void>(
            key: const ValueKey('employees_actives'),
            child: EmployeesActivesScreen(searchValue: searchValue),
          )
        else if (currentRoute.pathTemplate.startsWith('/employees_pasive'))
          FadeTransitionPage<void>(
            key: const ValueKey('employees_pasive'),
            child: EmployeesPasiveScreen(searchValue: searchValue),
          )

        // Vehicles
        else if (currentRoute.pathTemplate == '/vehicles')
          FadeTransitionPage<void>(
            key: const ValueKey('vehicles'),
            child: VehiclesScreen(
              searchValue: searchValue,
            ),
          )

        // Production
        else if (currentRoute.pathTemplate == '/production_home')
          FadeTransitionPage<void>(
            key: const ValueKey('production_home'),
            child: ProductionScreen(),
          )
        /*
        else if (currentRoute.pathTemplate.startsWith('/books') ||
            currentRoute.pathTemplate == '/')
          const FadeTransitionPage<void>(
            key: ValueKey('books'),
            child: BooksScreen(),
          ) */

        else
          FadeTransitionPage<void>(
            key: const ValueKey('empty'),
            child: Container(),
          ),
      ],
    );
  }
}
