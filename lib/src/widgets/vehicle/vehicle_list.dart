// Copyright 2021, the Flutter project vehicles. Please see the vehicles file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data.dart';

class VehicleList extends StatelessWidget {
  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle>? onTap;

  const VehicleList({
    required this.vehicles,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListView.separated(
        itemCount: vehicles.length,
        separatorBuilder: (context, index) => const Divider(
          color: Color.fromARGB(85, 97, 20, 15),
        ),
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            radius: 31,
            backgroundColor: (vehicles[index].profileImage == null ||
                    vehicles[index].profileImage == "")
                ? Theme.of(context).colorScheme.secondary
                : null,
            backgroundImage: (vehicles[index].profileImage == null ||
                    vehicles[index].profileImage == "")
                ? null
                : CachedNetworkImageProvider(
                    vehicles[index].profileImage ?? ""),
            child: (vehicles[index].profileImage == "" ||
                    vehicles[index].profileImage == null)
                ? Text(
                    vehicles[index].nombre[0],
                    style: const TextStyle(fontSize: 21, color: Colors.white),
                  )
                : null,
          ),
          title: Text(vehicles[index].nombre),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (vehicles[index].placa ?? 'S/P').toUpperCase(),
              ),
              Text(
                vehicles[index].marca ?? "Vehículo",
                style: const TextStyle(fontStyle: FontStyle.italic),
              )
            ],
          ),
          trailing: Icon(
            Icons.garage,
            color: (vehicles[index].isActive != null &&
                    vehicles[index].isActive == true)
                ? Colors.green
                : null,
          ),
          onTap: onTap != null ? () => onTap!(vehicles[index]) : null,
          onLongPress: () => {},
        ),
      );
}
