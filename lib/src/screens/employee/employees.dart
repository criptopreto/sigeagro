// Copyright 2021, the Flutter project Employees. Please see the Employees file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:jobix/src/data.dart';
import 'package:jobix/src/data/employee/employees_data.dart';

import '../../routing.dart';
import '../../widgets/employee/employee_list.dart';

class EmployeesScreen extends StatelessWidget {
  final String title = 'Employees';
  final String searchValue;

  const EmployeesScreen({super.key, required this.searchValue});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<List<Employee>>(
          stream: employeeDataInstance.employeeCollection.snapshots().map(
                (querySnapshot) => querySnapshot.docs
                    .map(
                      (doc) {
                        final employeeData = doc.data() as Map<String, dynamic>;

                        return Employee(
                          id: doc.id,
                          idcard: employeeData["idcard"],
                          nombres: employeeData["nombres"],
                          apellidos: employeeData["apellidos"],
                          profileImage: employeeData["profileImage"],
                          oficio: employeeData["oficio"],
                          tipo: employeeData["tipo"],
                          farm: employeeData["farm"],
                          funcion: employeeData["funcion"],
                          isActive: employeeData["activo"],
                        );
                      },
                    )
                    .where((employee) =>
                        employee.nombres
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                        employee.apellidos
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                        employee.idcard
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                        (employee.tipo != null &&
                            employee.tipo!
                                .toLowerCase()
                                .contains(searchValue.toLowerCase())) ||
                        (employee.farm != null &&
                            employee.farm!
                                .toLowerCase()
                                .contains(searchValue.toLowerCase())) ||
                        (employee.oficio != null &&
                            employee.oficio!
                                .toLowerCase()
                                .contains(searchValue.toLowerCase())) ||
                        (employee.funcion != null &&
                            employee.funcion!
                                .toLowerCase()
                                .contains(searchValue.toLowerCase())))
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

            final employees = snapshot.data ?? [];

            if (employees.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.no_accounts,
                      size: 30,
                    ),
                    Text(
                      "No hay empleados registrados",
                      style: TextStyle(fontSize: 22),
                    )
                  ],
                ),
              );
            }

            return EmployeeList(
              employees: employees,
              onTap: (employee) {
                RouteStateScope.of(context).go("/employee/${employee.id}");
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            //Navigator.push(context, )
            RouteStateScope.of(context).go("/add_employee");
          },
          label: const Text("Agregar Empleado"),
          icon: const Icon(Icons.group_add),
        ),
      );
}
