// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Employee {
  final String id;
  final String nombres;
  final String apellidos;
  final String idcard;
  String? funcion;
  String? tipo;
  String? profileImage;
  String? oficio;
  String? gradoInstruccion;
  String? direccion;
  String? farm;
  String? telefono;
  String? tallaCamisa;
  String? tallaPantalon;
  String? tallaZapatos;
  String? observaciones;
  DateTime? startTime = DateTime.now();
  final DateTime endTime = DateTime.now();
  bool? isActive;

  Employee(
      {required this.id,
      required this.idcard,
      required this.nombres,
      required this.apellidos,
      this.startTime,
      this.profileImage,
      this.oficio,
      this.gradoInstruccion,
      this.direccion,
      this.farm,
      this.telefono,
      this.tallaCamisa,
      this.tallaPantalon,
      this.tallaZapatos,
      this.observaciones,
      this.funcion,
      this.tipo,
      this.isActive});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'idcard': idcard,
      "funcion": funcion,
      "gradoInstruccion": gradoInstruccion,
      "direccion": direccion,
      "farm": farm,
      "telefono": telefono,
      "tallaCamisa": tallaCamisa,
      "tallaPantalon": tallaPantalon,
      "tallaZapatos": tallaZapatos,
      "observaciones": observaciones,
      "tipo": tipo,
      "profileImage": profileImage,
    };
  }
}
