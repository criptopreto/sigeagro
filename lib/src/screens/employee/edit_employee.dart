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

class EditEmployee extends StatefulWidget {
  final String employeeId;

  const EditEmployee({super.key, required this.employeeId});

  @override
  State<EditEmployee> createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  final _formKey = GlobalKey<FormState>();
  bool _idcardExists = false;
  FocusNode idcardFocus = FocusNode();
  FocusNode nombresFocus = FocusNode();
  FocusNode apellidosFocus = FocusNode();
  bool isCheckingIdcard = false;

  List<XFile>? _mediaFileList;
  String _employeeProfileImage = "";

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

  final TextEditingController idcardController = TextEditingController();
  final TextEditingController nombresController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController oficioController = TextEditingController();
  final TextEditingController funcionController = TextEditingController();

  final TextEditingController tipoController = TextEditingController();
  final TextEditingController gradoInstruccionController =
      TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController farmController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController tallaCamisaController = TextEditingController();
  final TextEditingController tallaPantalonController = TextEditingController();
  final TextEditingController tallaZapatosController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();

  DateTime date = DateTime.now();
  bool isActive = false;
  String profileImage = "";

  @override
  void initState() {
    super.initState();
    loadEmployeeData();
  }

  void loadEmployeeData() async {
    final employeeDoc = FirebaseFirestore.instance
        .collection("employees")
        .doc(widget.employeeId);

    final employeeSnapshot = await employeeDoc.get();

    if (employeeSnapshot.exists) {
      final employeeData = employeeSnapshot.data() as Map<String, dynamic>;

      idcardController.text = employeeData['idcard'] ?? '';
      nombresController.text = employeeData['nombres'] ?? '';
      apellidosController.text = employeeData['apellidos'] ?? '';
      oficioController.text = employeeData['oficio'] ?? '';
      tipoController.text = employeeData['tipo'] ?? '';
      funcionController.text = employeeData['funcion'] ?? '';
      gradoInstruccionController.text = employeeData['gradoInstruccion'] ?? '';
      direccionController.text = employeeData['direccion'] ?? '';
      farmController.text = employeeData['farm'] ?? '';
      telefonoController.text = employeeData['telefono'] ?? '';
      tallaCamisaController.text = employeeData['tallaCamisa'] ?? '';
      tallaPantalonController.text = employeeData['tallaPantalon'] ?? '';
      tallaZapatosController.text = employeeData['tallaZapatos'] ?? '';
      observacionesController.text = employeeData['observaciones'] ?? '';
      isActive = _getEmployeeStatus(employeeData['activo']);
      _employeeProfileImage = employeeData["profileImage"];

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    void handleCheckBoxState({bool updateState = true}) {
      if (updateState) setState(() {});
    }

    handleCheckBoxState(updateState: false);

    idcardFocus.addListener(
      () => {
        setState(() {
          isCheckingIdcard = true;
        }),
        if (!idcardFocus.hasFocus)
          {_onIdcardFieldFocusLost()}
        else
          {isCheckingIdcard = false}
      },
    );

    nombresFocus.addListener(
      () => _formKey.currentState!.validate(),
    );

    apellidosFocus.addListener(
      () => _formKey.currentState!.validate(),
    );

    return WillPopScope(
      onWillPop: () async {
        bool hasChanges = false;
        hasChanges |= _mediaFileList != null;
        hasChanges |= idcardController.text.isNotEmpty;
        hasChanges |= nombresController.text.isNotEmpty;
        hasChanges |= apellidosController.text.isNotEmpty;
        hasChanges |= oficioController.text.isNotEmpty;
        hasChanges |= funcionController.text.isNotEmpty;
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
          title: const Text('Editar Empleado'),
          backgroundColor: const Color.fromARGB(255, 89, 0, 0),
          foregroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  if (_isLoading) return;
                  setState(() {
                    _isLoading = true;
                  });
                  _saveEmployee();
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
          progressIndicator: const CircularProgressIndicator(
            color: Color.fromARGB(255, 124, 21, 14),
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
                                    if (_employeeProfileImage == "")
                                      _avatarPlaceholder()
                                    else
                                      _avatarFirebase(_employeeProfileImage)
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
                                  controller: idcardController,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Introduzca la cédula de identidad...',
                                    labelStyle: const TextStyle(
                                      color: Color.fromARGB(255, 103, 9, 9),
                                    ),
                                    enabled: false,
                                    labelText: 'Cédula de Identidad',
                                    suffixIcon: (isCheckingIdcard)
                                        ? Transform.scale(
                                            scale: 0.5,
                                            child:
                                                const CircularProgressIndicator(
                                              color: Color.fromARGB(
                                                  255, 123, 20, 13),
                                              strokeWidth: 4,
                                            ),
                                          )
                                        : null,
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(255, 89, 0, 0)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, ingresa la cédula';
                                    }
                                    if (_idcardExists) {
                                      return "La cédula ya está registrada";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.number,
                                  focusNode: idcardFocus,
                                  onEditingComplete: _onIdcardFieldFocusLost,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: nombresController,
                                  decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 103, 9, 9),
                                    ),
                                    hintText: 'Ej.: Pedro Manuel',
                                    labelText: 'Nombres',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(255, 89, 0, 0)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, ingresa por lo menos un nombre';
                                    }
                                    return null;
                                  },
                                  focusNode: nombresFocus,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: apellidosController,
                                  decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                        color: Color.fromARGB(255, 103, 9, 9)),
                                    hintText: 'Ej.: Perez Rodriguez',
                                    labelText: 'Apellidos',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(255, 89, 0, 0)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, ingresa por lo menos un apellido';
                                    }
                                    return null;
                                  },
                                  focusNode: apellidosFocus,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: farmController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej.: San Gonzalo',
                                    labelText: 'Agropecuaria',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                TextFormField(
                                  controller: tipoController,
                                  decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 103, 9, 9),
                                    ),
                                    hintText:
                                        'Ej.: Fijo, Contratado, Temporal u Otro',
                                    labelText: 'Tipo',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(255, 89, 0, 0)),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: gradoInstruccionController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej.: Bachiller',
                                    labelText: 'Grado de Instrucción',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                TextFormField(
                                  controller: telefonoController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej.: 04121234567',
                                    labelText: 'Teléfono',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                TextFormField(
                                  controller: oficioController,
                                  decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 103, 9, 9),
                                    ),
                                    hintText: 'Ej.: Herrero',
                                    labelText: 'Profesión u oficio',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromARGB(255, 89, 0, 0)),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: funcionController,
                                  decoration: const InputDecoration(
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 103, 9, 9),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color.fromARGB(255, 89, 0, 0),
                                      ),
                                    ),
                                    hintText:
                                        'Describa brevemente el trabajo a realizar por el empleado.',
                                    labelText: 'Función dentro de la finca',
                                  ),
                                  maxLines: 5,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: direccionController,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    hintText: 'Dirección domiciliaria.',
                                    labelText: 'Dirección',
                                  ),
                                  maxLines: 5,
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                TextFormField(
                                  controller: tallaCamisaController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej.: M',
                                    labelText: 'Talla Camisa',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                TextFormField(
                                  controller: tallaPantalonController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej.: 32',
                                    labelText: 'Talla Pantalon',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                TextFormField(
                                  controller: tallaZapatosController,
                                  decoration: InputDecoration(
                                    hintText: 'Ej.: 42',
                                    labelText: 'Talla Zapatos',
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                                const SizedBox(
                                  height: 7,
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
                                    Text('¿Empleado está actualmente activo?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                    Switch(
                                      value: isActive,
                                      activeColor: const Color.fromARGB(
                                          255, 176, 28, 17),
                                      onChanged: (enabled) {
                                        setState(() {
                                          isActive = enabled;
                                        });
                                      },
                                    ),
                                  ],
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
                                    hintText: 'Observaciones adicionales.',
                                    labelText: 'Observaciones',
                                  ),
                                  maxLines: 5,
                                ),
                                const SizedBox(
                                  height: 7,
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

  _validateIdcard(String idcard) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("employees")
          .where("idcard", isEqualTo: idcard)
          .get();

      setState(() {
        _idcardExists = snapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isCheckingIdcard = false;
      });
    }
  }

  void _onIdcardFieldFocusLost() async {
    final idcard = idcardController.text.trim();

    if (idcard.isNotEmpty) {
      await _validateIdcard(idcard);
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

  Future<void> _saveEmployee() async {
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
                "employees_images/${DateTime.now().microsecondsSinceEpoch}.jpg");
        final firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
        final firebase_storage.TaskSnapshot storageSnapshot =
            await uploadTask.whenComplete(() => null);
        profileImage = await storageSnapshot.ref.getDownloadURL();

        // Eliminar la imagen anterior si existe
        try {
          if (_employeeProfileImage != "" &&
              _employeeProfileImage != profileImage) {
            final firebase_storage.Reference previousImageRef = firebase_storage
                .FirebaseStorage.instance
                .refFromURL(_employeeProfileImage);
            await previousImageRef.delete();
          }
        } catch (e) {}
      }

      print("profileImage $_employeeProfileImage");

      print("Firebase Image $profileImage");

      // Obtener el ID del empleado actual
      final String employeeId = widget.employeeId;

      // Actualizar los datos del empleado en Firestore
      final employeeData = {
        "idcard": idcardController.text,
        "nombres": nombresController.text,
        "apellidos": apellidosController.text,
        "oficio": oficioController.text,
        "funcion": funcionController.text,
        "gradoInstruccion": gradoInstruccionController.text,
        "direccion": direccionController.text,
        "farm": farmController.text,
        "telefono": telefonoController.text,
        "tallaCamisa": tallaCamisaController.text,
        "tallaPantalon": tallaPantalonController.text,
        "tallaZapatos": tallaZapatosController.text,
        "observaciones": observacionesController.text,
        "tipo": tipoController.text,
        "startTime": intl.DateFormat("yyyy-MM-dd").format(date),
        "activo": isActive,
        "profileImage":
            (profileImage != "") ? profileImage : _employeeProfileImage,
      };

      await FirebaseFirestore.instance
          .collection("employees")
          .doc(employeeId)
          .update(employeeData);

      // Mostrar mensaje de éxito y volver a la pantalla anterior
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Éxito'),
            content: const Text('Empleado modificado exitosamente.'),
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
            content: const Text('Hubo un error al guardar el empleado.'),
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
    idcardController.dispose();
    nombresController.dispose();
    apellidosController.dispose();
    oficioController.dispose();
    funcionController.dispose();

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
      backgroundImage: AssetImage("assets/images/profile_placeholder.png"),
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

  bool _getEmployeeStatus(bool? employeeStatus) {
    print("Employee status $employeeStatus");
    if (employeeStatus != null && employeeStatus == true) {
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
            style: TextStyle(color: Color.fromARGB(255, 135, 20, 12)),
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
