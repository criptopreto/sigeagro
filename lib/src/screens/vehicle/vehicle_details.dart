import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jobix/src/data/vehicle/vehicles_data.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jobix/src/routing.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  bool isLoading = false;
  bool vehicleStatus = false;
  final TextEditingController funcionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;

    final bool useMobileLayout = shortestSide < 600;

    return FutureBuilder(
      future: vehicleDataInstance.getVehicleById(widget.vehicleId),
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
          final vehicle = snp.data;

          if (vehicle != null) {
            vehicleStatus = vehicle.isActive ?? false;

            return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                      onPressed: () => {
                            RouteStateScope.of(context)
                                .go("/edit_vehicle/${vehicle.id}")
                          },
                      icon: const Icon(Icons.edit)),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext ctx) => AlertDialog(
                        title: const Text("Confirmar eliminación"),
                        content: const Text(
                            "¿Estás seguro de eliminar este vehículo?"),
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
                                await vehicleDataInstance.deleteVehicleById(
                                    vehicle.id, vehicle.profileImage);
                              } catch (e) {
                                print("Error al intentar eliminar");
                              } finally {
                                isLoading = false;

                                RouteStateScope.of(context).go("/vehicles");
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
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary
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
                                "${vehicle.nombre}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold),
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
                                      color: vehicle.profileImage == null ||
                                              vehicle.profileImage == ""
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : null,
                                    ),
                                    child: vehicle.profileImage == null ||
                                            vehicle.profileImage == ""
                                        ? Center(
                                            child: Text(
                                              vehicle.nombre[0],
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
                                                  vehicle.profileImage ?? "",
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
                                              vehicle.nombre,
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
                                              "Marca: ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              vehicle.marca ?? "",
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
                                              "Placa: ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              vehicle.placa ?? "",
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
                                                  color: (vehicle.isActive !=
                                                              null &&
                                                          vehicle.isActive ==
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
                                                (vehicle.isActive != null &&
                                                        vehicle.isActive ==
                                                            true)
                                                    ? "Operativo"
                                                    : "Inoperativo",
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
                                              "Fecha actualización: ",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              _getFormatedDate(
                                                  vehicle.startTime),
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
                                "Clase",
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
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  vehicle.clase ?? "Vehículo",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 20,
                                  ),
                                ),
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
                                vehicle.observaciones?.toUpperCase() ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                ),
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
                        content: Text(vehicleStatus
                            ? "¿Estás seguro que quiere marcar este vehículo como Inoperativo?"
                            : "¿Estás seguro que quiere marcar este vehículo como Operativo?"),
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
                                await vehicleDataInstance.markVehicleById(
                                    vehicle.id, !vehicleStatus);
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
                    label: Text(
                        "Marcar ${(vehicle.isActive != null && vehicle.isActive == true) ? 'Inoperativo' : 'Operativo'}"),
                    icon: _getActiveIcon(vehicle.isActive),
                  )
                ],
              ),
            );
          } else {
            return const Scaffold(
              body: Center(child: Text("Vehículo no registrado")),
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
