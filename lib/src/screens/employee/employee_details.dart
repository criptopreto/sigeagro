import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jobix/src/data/employee/employees_data.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jobix/src/routing.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  bool isLoading = false;
  bool employeeStatus = false;
  final TextEditingController funcionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;

    final bool useMobileLayout = shortestSide < 600;

    return FutureBuilder(
      future: employeeDataInstance.getEmployeeById(widget.employeeId),
      builder: (ctx, snp) {
        if (snp.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snp.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snp.error}")),
          );
        } else {
          final employee = snp.data;

          if (employee != null) {
            employeeStatus = employee.isActive ?? false;

            return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 62, 18, 18),
                foregroundColor: Colors.white,
                title: Text(employee.tipo != null
                    ? "Personal ${employee.tipo}"
                    : "Personal Contratado"),
                actions: [
                  IconButton(
                      onPressed: () => {
                            RouteStateScope.of(context)
                                .go("/edit_employee/${employee.id}")
                          },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext ctx) => AlertDialog(
                        title: const Text("Confirmar eliminación"),
                        content: const Text(
                            "¿Estás seguro de eliminar este empleado?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (isLoading) return;

                              setState(() {
                                isLoading = true;
                              });
                              Navigator.pop(context);

                              try {
                                await employeeDataInstance.deleteEmployeeById(
                                    employee.id, employee.profileImage);
                              } catch (e) {
                                print("Error al intentar eliminar");
                              } finally {
                                isLoading = false;

                                RouteStateScope.of(context).go("/employees");
                              }

                              // ignore: use_build_context_synchronously
                            },
                            child: _buttonEliminar(),
                          )
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.delete),
                  )
                ],
              ),
              body: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 78, 36, 36),
                    Color.fromARGB(255, 42, 17, 17)
                  ],
                )),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${employee.nombres} ${employee.apellidos}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold),
                              ),
                              if (employee.tipo != null)
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 125, 56, 56),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    "Personal ${employee.tipo}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 125, 56, 56),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  padding: const EdgeInsets.all(8),
                                  margin: EdgeInsets.symmetric(vertical: 2),
                                  child: const Text(
                                    "Personal Contratado",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              Wrap(
                                spacing: 8,
                                children: <Widget>[
                                  Container(
                                    width:
                                        useMobileLayout ? double.infinity : 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: employee.profileImage == null ||
                                              employee.profileImage == ""
                                          ? const Color.fromARGB(
                                              255, 112, 26, 19)
                                          : null,
                                    ),
                                    child: employee.profileImage == null ||
                                            employee.profileImage == ""
                                        ? Center(
                                            child: Text(
                                              "${employee.nombres[0]}${employee.apellidos[0]}",
                                              style: const TextStyle(
                                                  fontSize: 21,
                                                  color: Colors.white),
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  employee.profileImage ?? "",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: useMobileLayout ? 20 : 0,
                                        horizontal: useMobileLayout ? 0 : 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      verticalDirection: VerticalDirection.down,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const Icon(
                                              Icons.description_outlined,
                                              color: Colors.white,
                                              weight: 0.5,
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              "Nombres: ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              employee.nombres,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                        _responsiveSizedBox(
                                            25, 10, useMobileLayout),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.description_outlined,
                                              color: Colors.white,
                                              weight: 0.5,
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              "Apellidos: ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              employee.apellidos,
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                        _responsiveSizedBox(
                                            25, 10, useMobileLayout),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.badge_outlined,
                                              color: Colors.white,
                                              weight: 0.5,
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              "Cedula: ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              "V-${employee.idcard}",
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                        _responsiveSizedBox(
                                            25, 10, useMobileLayout),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.work_outline,
                                              color: Colors.white,
                                              weight: 0.5,
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              "Situación: ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: (employee.isActive !=
                                                              null &&
                                                          employee.isActive ==
                                                              true)
                                                      ? const Color.fromARGB(
                                                          240, 28, 130, 45)
                                                      : const Color.fromARGB(
                                                          255, 125, 56, 56),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(20))),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2,
                                                      horizontal: 10),
                                              child: Text(
                                                (employee.isActive != null &&
                                                        employee.isActive ==
                                                            true)
                                                    ? "Activo"
                                                    : "Inactivo",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 21,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        _responsiveSizedBox(
                                            25, 10, useMobileLayout),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.calendar_month_outlined,
                                              color: Colors.white,
                                              weight: 0.5,
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              "Fecha Inicio: ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              _getFormatedDate(
                                                  employee.startTime),
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                        _responsiveSizedBox(
                                            25, 10, useMobileLayout),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              color: Colors.white,
                                              weight: 0.5,
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              "Teléfono: ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              employee.telefono ?? "",
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Oficio",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 125, 56, 56),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  employee.oficio ?? "Empleado",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                "Función en la finca",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                employee.funcion?.toUpperCase() ?? "Trabajador",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                "Tallas",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.article,
                                    color: Colors.white,
                                    weight: 0.5,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    "Talla Camisa: ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    employee.tallaCamisa ?? "",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.article,
                                    color: Colors.white,
                                    weight: 0.5,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    "Talla Pantalón: ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    employee.tallaPantalon ?? "",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.article,
                                    color: Colors.white,
                                    weight: 0.5,
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    "Talla Zapatos: ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    employee.tallaZapatos ?? "Sin registro",
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                "Dirección",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                employee.direccion?.toUpperCase() ??
                                    "Sin Registro",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                "Observaciones",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                employee.observaciones?.toUpperCase() ??
                                    "Ninguna",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: Wrap(
                direction: Axis.horizontal,
                children: <Widget>[
                  FloatingActionButton.extended(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext ctx) => AlertDialog(
                        title: const Text("Confirmar modificación"),
                        content: Text(employeeStatus
                            ? "¿Estás seguro que quiere marcar este empleado como Inactivo?"
                            : "¿Estás seguro que quiere marcar este empleado como Activo?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (isLoading) return;

                              setState(() {
                                isLoading = true;
                              });
                              Navigator.pop(context);

                              try {
                                await employeeDataInstance.markEmployeeById(
                                    employee.id, !employeeStatus);
                              } catch (e) {
                              } finally {
                                setState(() {
                                  isLoading = false;
                                });
                              }

                              // ignore: use_build_context_synchronously
                            },
                            child: _buttonMarcar(),
                          )
                        ],
                      ),
                    ),
                    backgroundColor: const Color.fromARGB(255, 111, 3, 3),
                    foregroundColor: Colors.white,
                    label: Text(
                        "Marcar ${(employee.isActive != null && employee.isActive == true) ? 'Inactivo' : 'Activo'}"),
                    icon: _getActiveIcon(employee.isActive),
                  )
                ],
              ),
            );
          } else {
            return const Scaffold(
              body: Center(child: Text("Empleado no registrado")),
            );
          }
        }
      },
    );
  }

  String _getFormatedDate(DateTime? fecha) {
    if (fecha != null) {
      return intl.DateFormat("dd/MM/yyyy").format(fecha);
    } else {
      return "-";
    }
  }

  Widget _buttonEliminar() {
    if (isLoading) {
      return const CircularProgressIndicator(
        color: Color.fromARGB(255, 109, 25, 19),
      );
    }
    return const Text("Eliminar");
  }

  Widget _buttonMarcar() {
    if (isLoading) {
      return const CircularProgressIndicator(
        color: Color.fromARGB(255, 109, 25, 19),
      );
    }
    return const Text("Marcar");
  }

  Widget _responsiveSizedBox(
      double medidaTablet, double medidaPhone, bool useMobileLayout) {
    return SizedBox(
      height: (useMobileLayout) ? medidaPhone : medidaTablet,
      width: (useMobileLayout) ? medidaTablet : medidaPhone,
    );
  }

  Widget _getActiveIcon(bool? isActive) {
    if (isActive != null && isActive == true) {
      return const Icon(Icons.work_off);
    } else {
      return const Icon(Icons.work);
    }
  }
}
