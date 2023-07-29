// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Vehicle {
  final String id;
  final String nombre;
  String? marca;
  String? serial;
  String? motor;
  String? color;
  String? caucho;
  String? year;
  String? placa;
  String? clase;
  String? observaciones;
  String? profileImage;
  String? modelo;
  DateTime? startTime = DateTime.now();
  final DateTime endTime = DateTime.now();
  bool? isActive;

  Vehicle(
      {required this.id,
      this.placa,
      this.serial,
      required this.nombre,
      this.marca,
      this.clase,
      this.motor,
      this.color,
      this.caucho,
      this.year,
      this.startTime,
      this.profileImage,
      this.modelo,
      this.observaciones,
      this.isActive});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'marca': marca,
      'serial': serial,
      'motor': motor,
      'color': color,
      'caucho': caucho,
      'year': year,
      'modelo': modelo,
      'placa': placa,
      'clase': clase,
      "observaciones": observaciones,
      "profileImage": profileImage,
    };
  }
}
