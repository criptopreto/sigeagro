import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobix/src/routing.dart';

class HomeDrawer extends StatelessWidget {
  final User? loggedUser;

  const HomeDrawer({required this.loggedUser, super.key});

  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [
              0.0,
              1.0
            ],
                colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
              Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ])),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/home-drawer-backend.png"),
                    fit: BoxFit.cover),
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                child: const Text(
                  "",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.dashboard,
                size: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Dashboard',
                style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pop(context);
                routeState.go("/home");
              },
            ),
            Divider(
              color: Theme.of(context).colorScheme.primary,
              height: 1,
            ),
            ListTile(
              leading: Icon(
                Icons.supervisor_account,
                size: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Gestión de Empleados',
                style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pop(context);
                routeState.go("/employees_home");
              },
            ),
            ListTile(
              leading: Icon(
                Icons.agriculture,
                size: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Gestión de Vehiculos',
                style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pop(context);
                routeState.go("/vehicles");
              },
            ),
            ListTile(
              leading: Icon(
                Icons.factory,
                size: 25,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                'Sistema Productivo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () {
                Navigator.pop(context);
                routeState.go("/production_home");
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  title: Text(
                    "Gestión Agropecuaria",
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  leading: Icon(
                    Icons.maps_home_work,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    routeState.go("/production_home");
                  },
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  title: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(fontSize: 18),
                  ),
                  leading: const Icon(
                    Icons.logout,
                    color: Color.fromARGB(255, 76, 5, 0),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _navigateMenu(BuildContext context) => Navigator.pop(context);
}
