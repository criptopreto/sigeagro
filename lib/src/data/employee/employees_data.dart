import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_storage/firebase_storage.dart' as storage;

import 'employee.dart';

final employeeDataInstance = EmployeeData();

class EmployeeData {
  final CollectionReference employeeCollection =
      FirebaseFirestore.instance.collection('employees');

  final List<Employee> allEmployees = [];

  Future<void> addEmployee({
    required String nombres,
    required String apellidos,
    required String idcard,
    String? tipo,
  }) async {
    final existingEmployee = await getEmployeeByIdcard(idcard);
    if (existingEmployee == null) {
      final newEmployee = Employee(
        id: employeeCollection.doc().id,
        nombres: nombres,
        apellidos: apellidos,
        idcard: idcard,
        tipo: tipo,
      );
      await employeeCollection.doc(newEmployee.id).set(newEmployee.toMap());
    }
  }

  Future<int> getTotalEmployees() async {
    final querySnapshot = await employeeCollection.get();
    return querySnapshot.size;
  }

  Future<int> getTotalActiveEmployees() async {
    final querySnapshot =
        await employeeCollection.where('activo', isEqualTo: true).get();
    return querySnapshot.size;
  }

  Future<int> getTotalInactiveEmployees() async {
    final querySnapshot =
        await employeeCollection.where('activo', isEqualTo: false).get();
    return querySnapshot.size;
  }

  Future<int> getTotalFixedEmployees() async {
    final querySnapshot =
        await employeeCollection.where('tipo', isEqualTo: 'fijo').get();
    return querySnapshot.size;
  }

  Future<int> getTotalContractEmployees() async {
    final querySnapshot =
        await employeeCollection.where('tipo', isEqualTo: 'contratado').get();
    return querySnapshot.size;
  }

  Future<Employee?> getEmployeeByIdcard(String idcard) async {
    final querySnapshot = await employeeCollection
        .where('idcard', isEqualTo: idcard)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final employeeData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      return Employee(
        id: querySnapshot.docs.first.id,
        nombres: employeeData['nombres'],
        apellidos: employeeData['apellidos'],
        idcard: employeeData['idcard'],
      );
    } else {
      return null;
    }
  }

  Future<bool> deleteEmployeeById(String employeeId, String? linkImage) async {
    try {
      await employeeCollection.doc(employeeId).delete();

      if (linkImage != null && linkImage != "") {
        await storage.FirebaseStorage.instance.refFromURL(linkImage).delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markEmployeeById(String employeeId, bool isActive) async {
    try {
      final employeeStatusData = {"activo": isActive};

      await employeeCollection.doc(employeeId).update(employeeStatusData);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Employee>> getAllEmployees() async {
    final querySnapshot = await employeeCollection.get();
    return querySnapshot.docs.map((doc) {
      final employeeData = doc.data() as Map<String, dynamic>;
      return Employee(
        id: doc.id,
        nombres: employeeData['nombres'],
        apellidos: employeeData['apellidos'],
        idcard: employeeData['idcard'],
      );
    }).toList();
  }

  Future<Employee?> getEmployeeById(String employeeId) async {
    final documentSnapshot = await employeeCollection.doc(employeeId).get();

    if (documentSnapshot.exists) {
      final employeeData = documentSnapshot.data() as Map<String, dynamic>;

      return Employee(
        id: documentSnapshot.id,
        nombres: employeeData['nombres'],
        apellidos: employeeData['apellidos'],
        idcard: employeeData['idcard'],
        oficio: employeeData["oficio"],
        funcion: employeeData["funcion"],
        gradoInstruccion: employeeData["gradoInstruccion"],
        direccion: employeeData["direccion"],
        farm: employeeData["farm"],
        telefono: employeeData["telefono"],
        tallaCamisa: employeeData["tallaCamisa"],
        tallaPantalon: employeeData["tallaPantalon"],
        tallaZapatos: employeeData["tallaZapatos"],
        observaciones: employeeData["observaciones"],
        tipo: employeeData["tipo"],
        profileImage: employeeData["profileImage"],
        isActive: employeeData["activo"],
        startTime: DateTime.parse(employeeData["startTime"]),
      );
    } else {
      return null;
    }
  }
}
