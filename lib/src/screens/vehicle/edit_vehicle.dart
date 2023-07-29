import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mime/mime.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

enum SelectSourceItem { camera, gallery, cancel }

class EditVehicle extends StatefulWidget {
  final String vehicleId;

  const EditVehicle({super.key, required this.vehicleId});

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

class _EditVehicleState extends State<EditVehicle> {
  final _formKey = GlobalKey<FormState>();
  bool _placaExists = false;
  bool _serialExists = false;
  bool placaModified = false;
  bool serialModified = false;
  FocusNode placaFocus = FocusNode();
  FocusNode serialFocus = FocusNode();
  FocusNode nombreFocus = FocusNode();
  FocusNode marcaFocus = FocusNode();
  bool isCheckingPlaca = false;
  bool isCheckingSerial = false;

  String? oldSerial;
  String? oldPlaca;

  List<XFile>? _mediaFileList;
  String _vehicleProfileImage = "";

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
  }

  bool _isLoading = false;

  dynamic _pickImageError;
  bool isVideo = false;

  VideoPlayerController? _vpController;
  VideoPlayerController? _vpToBeDisposed;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  final TextEditingController placaController = TextEditingController();
  final TextEditingController serialController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController cauchoController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  DateTime date = DateTime.now();
  bool isActive = false;
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    loadVehicleData();
  }

  void loadVehicleData() async {
    final vehicleDoc =
        FirebaseFirestore.instance.collection("vehicles").doc(widget.vehicleId);

    final vehicleSnapshot = await vehicleDoc.get();

    if (vehicleSnapshot.exists) {
      final vehicleData = vehicleSnapshot.data() as Map<String, dynamic>;

      placaController.text = vehicleData['placa'] ?? '';
      serialController.text = vehicleData['serial'] ?? '';
      nombreController.text = vehicleData['nombre'] ?? '';
      marcaController.text = vehicleData['marca'] ?? '';
      modeloController.text = vehicleData['modelo'] ?? '';
      observacionesController.text = vehicleData['observaciones'] ?? '';
      isActive = _getVehicleStatus(vehicleData['activo']);
      _vehicleProfileImage = vehicleData["profileImage"];

      oldPlaca = vehicleData['placa'] ?? '';
      oldSerial = serialController.text = vehicleData['serial'] ?? '';

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    void handleCheckBoxState({bool updateState = true}) {
      if (updateState) setState(() {});
    }

    handleCheckBoxState(updateState: false);

    placaFocus.addListener(
      () => {
        setState(() {
          if (placaModified) isCheckingPlaca = true;
        }),
        if (!placaFocus.hasFocus)
          {_onPlacaFieldFocusLost()}
        else
          {isCheckingPlaca = false}
      },
    );

    serialFocus.addListener(
      () => {
        setState(() {
          if (serialModified) isCheckingSerial = true;
        }),
        if (!placaFocus.hasFocus)
          {_onSerialFieldFocusLost()}
        else
          {isCheckingSerial = false}
      },
    );

    nombreFocus.addListener(
      () => _formKey.currentState!.validate(),
    );

    marcaFocus.addListener(
      () => _formKey.currentState!.validate(),
    );

    return WillPopScope(
      onWillPop: () async {
        bool hasChanges = false;
        hasChanges |= _mediaFileList != null;
        hasChanges |= placaController.text.isNotEmpty;
        hasChanges |= nombreController.text.isNotEmpty;
        hasChanges |= marcaController.text.isNotEmpty;
        hasChanges |= modeloController.text.isNotEmpty;
        hasChanges |= observacionesController.text.isNotEmpty;
        hasChanges |= isActive != false;
        if (hasChanges) {
          final shouldExit = await _showExitConfirmationDialog();
          return shouldExit;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: TextButton(
            onPressed: () async {
              final shouldExit = await _showExitConfirmationDialog();
              if (shouldExit) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Icon(Icons.cancel_outlined),
          ),
          title: const Text('Editar Vehículo'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  if (_isLoading) return;
                  setState(() {
                    _isLoading = true;
                  });
                  _saveVehicle();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Guardar"),
                  ],
                ))
          ],
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          progressIndicator: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Form(
            key: _formKey,
            child: Scrollbar(
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 253, 253, 253),
                    Color.fromARGB(255, 240, 240, 240)
                  ],
                )),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                radius: 2,
                                colors: [
                                  Color.fromARGB(255, 120, 120, 120),
                                  Color.fromARGB(255, 58, 58, 58)
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                    children: [
                                  PopupMenuButton(
                                    onSelected: (SelectSourceItem opcion) {
                                      if (opcion == SelectSourceItem.camera) {
                                        isVideo = false;
                                        _onImageButtonPressed(
                                            ImageSource.camera,
                                            context: context);
                                      } else if (opcion ==
                                          SelectSourceItem.gallery) {
                                        _onImageButtonPressed(
                                          ImageSource.gallery,
                                          context: context,
                                          isMedia: true,
                                        );
                                      } else if (opcion ==
                                          SelectSourceItem.cancel) {
                                        _mediaFileList = null;
                                        setState(() {});
                                      }
                                    },
                                    itemBuilder: (BuildContext ctx) =>
                                        <PopupMenuEntry<SelectSourceItem>>[
                                      const PopupMenuItem<SelectSourceItem>(
                                        value: SelectSourceItem.camera,
                                        child: Text("Tomar Foto"),
                                      ),
                                      const PopupMenuItem<SelectSourceItem>(
                                        value: SelectSourceItem.gallery,
                                        child: Text("Galería"),
                                      ),
                                      if (_mediaFileList != null)
                                        const PopupMenuItem<SelectSourceItem>(
                                          value: SelectSourceItem.cancel,
                                          child: Text("Eliminar"),
                                        )
                                    ],
                                    icon: const Icon(Icons.add_a_photo),
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 4),
                                  if (_mediaFileList == null)
                                    if (_vehicleProfileImage == "")
                                      _avatarPlaceholder()
                                    else
                                      _avatarFirebase(_vehicleProfileImage)
                                  else if (_mediaFileList != null)
                                    _handlePreview()
                                  else if (_pickImageError != null)
                                    Text(
                                      'Error al cargar la imagen: $_pickImageError',
                                      textAlign: TextAlign.center,
                                    ),
                                  const SizedBox(
                                    height: 8,
                                  )
                                ].where((Object? o) => o != null).toList())
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                TextFormField(
                                  controller: placaController,
                                  decoration: InputDecoration(
                                    hintText: 'Introduzca la placa...',
                                    labelText: 'Placa',
                                    suffixIcon: (isCheckingPlaca)
                                        ? Transform.scale(
                                            scale: 0.5,
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              strokeWidth: 4,
                                            ),
                                          )
                                        : null,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        placaModified) {
                                      return null;
                                    }
                                    if (_placaExists) {
                                      return "La placa ya está registrada";
                                    }
                                    return null;
                                  },
                                  focusNode: placaFocus,
                                  onEditingComplete: _onPlacaFieldFocusLost,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: serialController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Introduzca el serial de carrocería...',
                                    labelText: 'Serial de carrocería',
                                    suffixIcon: (isCheckingSerial)
                                        ? Transform.scale(
                                            scale: 0.5,
                                            child: CircularProgressIndicator(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              strokeWidth: 4,
                                            ),
                                          )
                                        : null,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        serialModified) {
                                      return null;
                                    }
                                    if (_serialExists) {
                                      return "El serial ya está registrado";
                                    }
                                    return null;
                                  },
                                  focusNode: serialFocus,
                                  onEditingComplete: _onSerialFieldFocusLost,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: nombreController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej.: Tritón 350',
                                    labelText: 'Nombre',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, ingresa por lo menos un nombre';
                                    }
                                    return null;
                                  },
                                  focusNode: nombreFocus,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: marcaController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej.: Ford',
                                    labelText: 'Marca',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, ingresa la marca';
                                    }
                                    return null;
                                  },
                                  focusNode: marcaFocus,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: modeloController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej.: Tritón 350',
                                    labelText: 'Modelo',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: colorController,
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    hintText: 'Ej.: Blanco',
                                    labelText: 'Color',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: yearController,
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    hintText: 'Ej.: 2005',
                                    labelText: 'Año',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: observacionesController,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    hintText:
                                        'Describa brevemente alguna observación del vehículo.',
                                    labelText: 'Observaciones',
                                  ),
                                  maxLines: 5,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                _FormDatePicker(
                                  date: date,
                                  onChanged: (value) {
                                    setState(() {
                                      date = value;
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        '¿Vehículo está actualmente operativo?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                    Switch(
                                      value: isActive,
                                      onChanged: (enabled) {
                                        setState(() {
                                          isActive = enabled;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _validatePlaca(String placa) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("vehicles")
          .where("placa", isEqualTo: placa)
          .get();

      setState(() {
        _placaExists = snapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isCheckingPlaca = false;
      });
    }
  }

  _validateSerial(String serial) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("vehicles")
          .where("serial", isEqualTo: serial)
          .get();

      setState(() {
        _serialExists = snapshot.docs.isNotEmpty;
      });
    } finally {
      setState(() {
        isCheckingPlaca = false;
      });
    }
  }

  void _onPlacaFieldFocusLost() async {
    final placa = placaController.text.trim().toLowerCase();

    if (oldPlaca != placa) {
      placaModified = true;
    }

    if (placa.isNotEmpty && placaModified) {
      await _validatePlaca(placa);
    }

    _formKey.currentState!.validate();
  }

  void _onSerialFieldFocusLost() async {
    final serial = serialController.text.trim().toLowerCase();

    if (oldSerial != serial) {
      serialModified = true;
    }

    if (serial.isNotEmpty && serialModified) {
      await _validateSerial(serial);
    }

    _formKey.currentState!.validate();
  }

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
    bool isMedia = false,
  }) async {
    if (_vpController != null) {
      await _vpController!.setVolume(0.0);
    }
    if (context.mounted) {
      if (isMedia) {
        try {
          final List<XFile> pickedFileList = <XFile>[];
          final XFile? media = await _picker.pickMedia(
            maxWidth: 700,
            maxHeight: 700,
            imageQuality: 60,
          );
          if (media != null) {
            pickedFileList.add(media);
            setState(() {
              _mediaFileList = pickedFileList;
            });
          }
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      } else {
        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: source,
            maxWidth: 700,
            maxHeight: 700,
            imageQuality: 60,
          );
          setState(() {
            _setImageFileListFromFile(pickedFile);
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      }
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Subir la imagen a Firebase Storage
      if (_mediaFileList != null && _mediaFileList!.isNotEmpty) {
        final File imageFile = File(_mediaFileList!.first.path);
        final firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref().child(
                "vehicles_images/${DateTime.now().microsecondsSinceEpoch}.jpg");
        final firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
        final firebase_storage.TaskSnapshot storageSnapshot =
            await uploadTask.whenComplete(() => null);
        profileImage = await storageSnapshot.ref.getDownloadURL();

        // Eliminar la imagen anterior si existe
        try {
          if (_vehicleProfileImage != "" &&
              _vehicleProfileImage != profileImage) {
            final firebase_storage.Reference previousImageRef = firebase_storage
                .FirebaseStorage.instance
                .refFromURL(_vehicleProfileImage);
            await previousImageRef.delete();
          }
          // ignore: empty_catches
        } catch (e) {}
      }

      // Obtener el ID del empleado actual
      final String vehicleId = widget.vehicleId;

      // Actualizar los datos del empleado en Firestore
      final vehicleData = {
        "placa": placaController.text.toLowerCase(),
        "serial": serialController.text.toLowerCase(),
        "nombre": nombreController.text,
        "marca": marcaController.text,
        "modelo": modeloController.text,
        "observaciones": observacionesController.text,
        "startTime": intl.DateFormat("yyyy-MM-dd").format(date),
        "activo": isActive,
        "profileImage":
            (profileImage != "") ? profileImage : _vehicleProfileImage,
      };

      await FirebaseFirestore.instance
          .collection("vehicles")
          .doc(vehicleId)
          .update(vehicleData);

      // Mostrar mensaje de éxito y volver a la pantalla anterior
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Éxito'),
            content: const Text('Vehículo modificado exitosamente.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Mostrar mensaje de error
      print(e);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Hubo un error al guardar el vehículo.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void deactivate() {
    if (_vpController != null) {
      _vpController!.setVolume(0.0);
      _vpController!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    placaController.dispose();
    nombreController.dispose();
    marcaController.dispose();
    modeloController.dispose();
    observacionesController.dispose();

    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_vpToBeDisposed != null) {
      await _vpToBeDisposed!.dispose();
    }
    _vpToBeDisposed = _vpController;
    _vpController = null;
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_mediaFileList != null) {
      profileImage = _mediaFileList![0].path;

      final String? mime = lookupMimeType(_mediaFileList![0].path);

      return Semantics(
        label: 'profile_image',
        child: (mime == null || mime.startsWith("image/")
            ? CircleAvatar(
                radius: 100,
                backgroundImage: _getImageProvider(),
              )
            : const Center(
                child: Text("El tipo de imagen no es compatible"),
              )),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return _avatarPlaceholder();
    }
  }

  Widget _avatarPlaceholder() {
    return const CircleAvatar(
      radius: 100,
      backgroundImage: AssetImage("assets/images/vehicle.jpeg"),
    );
  }

  Widget _avatarFirebase(String firebaseImage) {
    return CircleAvatar(
      radius: 100,
      backgroundImage: CachedNetworkImageProvider(firebaseImage),
    );
  }

  Widget _handlePreview() {
    return _previewImages();
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      isVideo = false;
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _mediaFileList = response.files;
        }
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  ImageProvider _getImageProvider() {
    try {
      return FileImage(File(_mediaFileList![0].path));
    } catch (e) {
      return const AssetImage("assets/images/image_error.jpeg");
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    final shouldPop = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("¿Seguro quieres salir?"),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("Salir"),
              ),
            ],
          );
        });

    return shouldPop!;
  }

  bool _getVehicleStatus(bool? vehicleStatus) {
    print("Vehicle status $vehicleStatus");
    if (vehicleStatus != null && vehicleStatus == true) {
      return true;
    }
    return false;
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class _FormDatePicker extends StatefulWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _FormDatePicker({
    required this.date,
    required this.onChanged,
  });

  @override
  State<_FormDatePicker> createState() => _FormDatePickerState();
}

class _FormDatePickerState extends State<_FormDatePicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Fecha de Ingreso',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 3,
            ),
            Text(
              intl.DateFormat.yMd("es").format(widget.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        TextButton(
          child: const Text(
            'Cambiar fecha',
          ),
          onPressed: () async {
            var newDate = await showDatePicker(
              context: context,
              initialDate: widget.date,
              locale: const Locale("es", "ES"),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );

            // Don't change the date if the date picker returns null.
            if (newDate == null) {
              return;
            }

            widget.onChanged(newDate);
          },
        )
      ],
    );
  }
}
