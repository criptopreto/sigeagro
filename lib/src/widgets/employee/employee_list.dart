// Copyright 2021, the Flutter project employees. Please see the employees file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data.dart';

class EmployeeList extends StatelessWidget {
  final List<Employee> employees;
  final ValueChanged<Employee>? onTap;

  const EmployeeList({
    required this.employees,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ListView.separated(
        itemCount: employees.length,
        separatorBuilder: (context, index) => const Divider(
          color: Color.fromARGB(85, 97, 20, 15),
        ),
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(
            radius: 31,
            backgroundColor: (employees[index].profileImage == null ||
                    employees[index].profileImage == "")
                ? const Color.fromARGB(255, 112, 26, 19)
                : null,
            backgroundImage: (employees[index].profileImage == null ||
                    employees[index].profileImage == "")
                ? null
                : CachedNetworkImageProvider(
                    employees[index].profileImage ?? ""),
            child: (employees[index].profileImage == "" ||
                    employees[index].profileImage == null)
                ? Text(
                    "${employees[index].nombres[0]}${employees[index].apellidos[0]}",
                    style: const TextStyle(fontSize: 21, color: Colors.white),
                  )
                : null,
          ),
          title:
              Text("${employees[index].nombres} ${employees[index].apellidos}"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "V-${employees[index].idcard}",
              ),
              Text(
                employees[index].oficio ?? "Empleado",
                style: const TextStyle(fontStyle: FontStyle.italic),
              )
            ],
          ),
          trailing: Icon(
            Icons.account_box,
            color: (employees[index].isActive != null &&
                    employees[index].isActive == true)
                ? Colors.green
                : null,
          ),
          onTap: onTap != null ? () => onTap!(employees[index]) : null,
          onLongPress: () => {},
        ),
      );
}
