import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_storage/firebase_storage.dart' as storage;

import 'vehicle.dart';

final vehicleDataInstance = VehicleData();

class VehicleData {
  final CollectionReference vehicleCollection =
      FirebaseFirestore.instance.collection('vehicles');

  final List<Vehicle> allVehicles = [];

  Future<void> addVehicle({
    required String nombre,
    required String marca,
    required String placa,
  }) async {
    final existingVehicle = await getVehicleByPlaca(placa);
    if (existingVehicle == null) {
      final newVehicle = Vehicle(
        id: vehicleCollection.doc().id,
        nombre: nombre,
        marca: marca,
        placa: placa,
      );
      await vehicleCollection.doc(newVehicle.id).set(newVehicle.toMap());
    }
  }

  Future<Vehicle?> getVehicleByPlaca(String placa) async {
    final querySnapshot =
        await vehicleCollection.where('placa', isEqualTo: placa).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      final vehicleData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      return Vehicle(
        id: querySnapshot.docs.first.id,
        nombre: vehicleData['nombre'],
        marca: vehicleData['marca'],
        placa: vehicleData['placa'],
      );
    } else {
      return null;
    }
  }

  Future<bool> deleteVehicleById(String vehicleId, String? linkImage) async {
    try {
      await vehicleCollection.doc(vehicleId).delete();

      if (linkImage != null && linkImage != "") {
        await storage.FirebaseStorage.instance.refFromURL(linkImage).delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markVehicleById(String vehicleId, bool isActive) async {
    try {
      final vehicleStatusData = {"activo": isActive};

      await vehicleCollection.doc(vehicleId).update(vehicleStatusData);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final querySnapshot = await vehicleCollection.get();
    return querySnapshot.docs.map((doc) {
      final vehicleData = doc.data() as Map<String, dynamic>;
      return Vehicle(
        id: doc.id,
        nombre: vehicleData['nombre'],
        marca: vehicleData['serial'],
        placa: vehicleData['placa'],
      );
    }).toList();
  }

  Future<Vehicle?> getVehicleById(String vehicleId) async {
    final documentSnapshot = await vehicleCollection.doc(vehicleId).get();

    if (documentSnapshot.exists) {
      final vehicleData = documentSnapshot.data() as Map<String, dynamic>;

      return Vehicle(
        id: documentSnapshot.id,
        nombre: vehicleData['nombre'],
        marca: vehicleData['marca'],
        placa: vehicleData['placa'],
        modelo: vehicleData["modelo"],
        profileImage: vehicleData["profileImage"],
        serial: vehicleData["serial"],
        motor: vehicleData['motor'],
        color: vehicleData['color'],
        year: vehicleData['year'],
        observaciones: vehicleData['observaciones'],
        isActive: vehicleData["activo"],
        startTime: DateTime.parse(vehicleData["startTime"]),
      );
    } else {
      return null;
    }
  }
}
