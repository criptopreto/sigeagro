import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobix/src/components/home_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _employeesStream =
      FirebaseFirestore.instance.collection("employees").snapshots();
  User? loggedUser;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    try {
      _authSubscription =
          FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          Navigator.of(context).pushReplacementNamed("/");
        } else {
          setState(() {
            loggedUser = user;
          });
        }
      });
    } catch (e) {
      print(e);
    }
    super.initState();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("San Gonzalo"),
        backgroundColor: const Color.fromARGB(255, 89, 0, 0),
        foregroundColor: Colors.white,
      ),
      drawer: HomeDrawer(
        loggedUser: loggedUser,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _employeesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Error al obtener los datos");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Cargando...");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      child: Text("A"),
                    ),
                    title: Text(data['nombres'] + " " + data["apellidos"]),
                    subtitle: Text(data['idcard']),
                    trailing: const Icon(Icons.face_rounded),
                  ),
                  const Divider(
                    height: 0,
                  )
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //Navigator.push(context, )
        },
        backgroundColor: const Color.fromARGB(255, 89, 0, 0),
        foregroundColor: Colors.white,
        label: const Text("Agregar Empleado"),
        icon: const Icon(Icons.supervisor_account),
      ),
    );
  }
}
