// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobix/src/components/home_drawer.dart';
import 'package:jobix/src/screens/employee/employees.dart';

import '../routing.dart';
import 'scaffold_body.dart';

class BookstoreScaffold extends StatefulWidget {
  final User? loggedInUser;
  const BookstoreScaffold({
    this.loggedInUser,
    super.key,
  });

  @override
  State<BookstoreScaffold> createState() => _BookstoreScaffoldState();
}

class _BookstoreScaffoldState extends State<BookstoreScaffold> {
  String searchValue = "";

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    var currentRoute = routeState.route;
    final selectedIndex = _getSelectedIndex(routeState.route.pathTemplate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SIGEAGRO",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ])),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await showSearch(
                  context: context, delegate: MySearchDelegate());

              setState(() {
                searchValue = result ?? "";
              });
            },
            icon: const Icon(Icons.search),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 16,
              right: 16,
            ),
            child: Stack(
              children: <Widget>[
                const Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
      drawer: HomeDrawer(
        loggedUser: widget.loggedInUser,
      ),
      body: _generateBody(selectedIndex, routeState, currentRoute),
    );
  }

  Widget _generateBody(
      int selectedIndex, RouteState routeState, ParsedRoute currentRoute) {
    if (currentRoute.pathTemplate == "/employees") {
      return AdaptiveNavigationScaffold(
        selectedIndex: selectedIndex,
        body: BookstoreScaffoldBody(
          searchValue: searchValue,
        ),
        onDestinationSelected: (idx) {
          if (idx == 0) routeState.go('/employees');
          if (idx == 1) routeState.go('/employees_actives');
          if (idx == 2) routeState.go('/employees_pasive');
        },
        destinations: const [
          AdaptiveScaffoldDestination(
            title: 'Todos los Empleados',
            icon: Icons.groups,
          ),
          AdaptiveScaffoldDestination(
            title: 'Fijos',
            icon: Icons.badge,
          ),
          AdaptiveScaffoldDestination(
            title: 'Contratados',
            icon: Icons.hourglass_bottom,
          ),
          AdaptiveScaffoldDestination(
            title: 'Empleados Activos',
            icon: Icons.group,
          ),
          AdaptiveScaffoldDestination(
            title: 'Empleados Inactivos',
            icon: Icons.group_off,
          ),
        ],
      );
    } else {
      return BookstoreScaffoldBody(
        searchValue: searchValue,
      );
    }
  }

  int _getSelectedIndex(String pathTemplate) {
    if (pathTemplate == '/employees') return 0;
    if (pathTemplate == '/employees_actives') return 1;
    if (pathTemplate == '/employees_pasive') return 2;
    return 0;
  }
}

class MySearchDelegate extends SearchDelegate {
  final keyS = GlobalKey();
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () => close(context, null), icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = "";
          }
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return EmployeesScreen(
      searchValue: query,
    ); // No mostrar nada aquí
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = [query];

    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (ctx, index) {
          final suggestion = suggestions[index];

          return ListTile(
            title: Text(suggestion),
            onTap: () {
              query = suggestion;
            },
          );
        });
  }
}
