// Copyright 2021, the Flutter project Vehicles. Please see the Vehicles file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:jobix/src/data.dart';
import 'package:jobix/src/data/vehicle/vehicles_data.dart';

import '../../routing.dart';
import '../../widgets/vehicle/vehicle_list.dart';

class VehiclesScreen extends StatelessWidget {
  final String title = 'Vehicles';
  final String searchValue;

  const VehiclesScreen({super.key, required this.searchValue});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<List<Vehicle>>(
          stream: vehicleDataInstance.vehicleCollection.snapshots().map(
                (querySnapshot) => querySnapshot.docs
                    .map(
                      (doc) {
                        final vehicleData = doc.data() as Map<String, dynamic>;

                        return Vehicle(
                          id: doc.id,
                          placa: vehicleData["placa"],
                          nombre: vehicleData["nombre"],
                          marca: vehicleData["marca"],
                          profileImage: vehicleData["profileImage"],
                          modelo: vehicleData["modelo"],
                          isActive: vehicleData["activo"],
                        );
                      },
                    )
                    .where((vehicle) =>
                        vehicle.nombre
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                        vehicle.marca!
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                        vehicle.placa!
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()))
                    .toList(),
              ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            }

            final vehicles = snapshot.data ?? [];

            if (vehicles.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.car_crash,
                      size: 30,
                    ),
                    Text(
                      "No hay vehículos registrados",
                      style: TextStyle(fontSize: 22),
                    )
                  ],
                ),
              );
            }

            return VehicleList(
              vehicles: vehicles,
              onTap: (vehicle) {
                RouteStateScope.of(context).go("/vehicle/${vehicle.id}");
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            //Navigator.push(context, )
            RouteStateScope.of(context).go("/add_vehicle");
          },
          label: const Text("Registrar Vehiculo"),
          icon: const Icon(Icons.local_shipping),
        ),
      );
}
