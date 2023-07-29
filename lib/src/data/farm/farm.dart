// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Farm {
  final String id;
  final String nombre;
  String? descripcion;
  String? logo;
  bool? isActive;

  Farm({
    required this.id,
    required this.nombre,
    this.logo,
    this.descripcion,
    this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'logo': logo,
      'activo': isActive,
    };
  }
}
