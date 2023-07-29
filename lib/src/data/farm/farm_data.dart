import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_storage/firebase_storage.dart' as storage;

import 'farm.dart';

final farmDataInstance = FarmData();

class FarmData {
  final CollectionReference farmCollection =
      FirebaseFirestore.instance.collection('farms');

  final List<Farm> allFarms = [];

  Future<void> addFarm({
    required String nombre,
  }) async {
    final existingFarm = await getFarmByName(nombre);
    if (existingFarm == null) {
      final newFarm = Farm(
        id: farmCollection.doc().id,
        nombre: nombre,
      );
      await farmCollection.doc(newFarm.id).set(newFarm.toMap());
    }
  }

  Future<Farm?> getFarmByName(String nombre) async {
    final querySnapshot =
        await farmCollection.where('nombre', isEqualTo: nombre).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      final farmData = querySnapshot.docs.first.data() as Map<String, dynamic>;

      return Farm(
        id: querySnapshot.docs.first.id,
        nombre: farmData['nombre'],
        descripcion: farmData['descripcion'],
        logo: farmData['logo'],
      );
    } else {
      return null;
    }
  }

  Future<bool> deleteFarmById(String farmId, String? linkImage) async {
    try {
      await farmCollection.doc(farmId).delete();

      if (linkImage != null && linkImage != "") {
        await storage.FirebaseStorage.instance.refFromURL(linkImage).delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markFarmById(String farmId, bool isActive) async {
    try {
      final farmStatusData = {"isActive": isActive};

      await farmCollection.doc(farmId).update(farmStatusData);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Farm>> getAllFarms() async {
    final querySnapshot = await farmCollection.get();
    return querySnapshot.docs.map((doc) {
      final farmData = doc.data() as Map<String, dynamic>;
      return Farm(
        id: doc.id,
        nombre: farmData['nombre'],
        descripcion: farmData['descripcion'],
        logo: farmData['logo'],
      );
    }).toList();
  }

  Future<Farm?> getFarmById(String farmId) async {
    final documentSnapshot = await farmCollection.doc(farmId).get();

    if (documentSnapshot.exists) {
      final farmData = documentSnapshot.data() as Map<String, dynamic>;

      return Farm(
        id: documentSnapshot.id,
        nombre: farmData['nombre'],
        descripcion: farmData['descripcion'],
        logo: farmData['logo'],
        isActive: farmData["isActive"],
      );
    } else {
      return null;
    }
  }
}
