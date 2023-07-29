import 'package:flutter/material.dart';

class EmployeePanelInfo {
  final String? svgSrc, title, linkScreen;
  final int? count;
  final Color? color;

  EmployeePanelInfo({
    this.svgSrc,
    this.title,
    this.count,
    this.linkScreen,
    this.color,
  });
}

List listEmployeePanel = [
  EmployeePanelInfo(
    title: "Personal Registrado",
    count: 0,
    svgSrc: "assets/icons/all_workers.svg",
    linkScreen: "/employees",
    color: Colors.blue,
  ),
  EmployeePanelInfo(
    title: "Empleados Activos",
    count: 0,
    svgSrc: "assets/icons/worker_active.svg",
    color: const Color.fromARGB(255, 12, 160, 88),
  ),
  EmployeePanelInfo(
    title: "Empleados Inactivos",
    count: 0,
    svgSrc: "assets/icons/worker_inactive.svg",
    color: const Color.fromARGB(255, 162, 162, 162),
  ),
  EmployeePanelInfo(
    title: "Empleados Fijos",
    count: 0,
    svgSrc: "assets/icons/worker_fijo.svg",
    color: const Color.fromARGB(255, 16, 226, 166),
  ),
  EmployeePanelInfo(
    title: "Empleados Contratados",
    count: 0,
    svgSrc: "assets/icons/worker_contract.svg",
    color: const Color.fromARGB(255, 33, 162, 201),
  ),
];
