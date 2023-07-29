import "package:flutter/material.dart";
import "package:jobix/src/components/theme_helper.dart";
import "package:jobix/src/widgets/header_widget.dart";
import "package:loading_overlay/loading_overlay.dart";

class Credentials {
  final String email;
  final String password;

  Credentials(this.email, this.password);
}

class LoginPage extends StatefulWidget {
  final ValueChanged<Credentials> onSignIn;

  const LoginPage({required this.onSignIn, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool kDebugMode = true;
  final double _headerHeight = 250;
  bool _isShowPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        progressIndicator: const CircularProgressIndicator(),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: _headerHeight,
                child: HeaderWidget(_headerHeight, true,
                    Icons.login_rounded), //let's create a common header widget
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: const EdgeInsets.fromLTRB(
                      20, 10, 20, 10), // This will be the login form
                  child: Column(
                    children: [
                      const Text(
                        'SIGEAGRO',
                        style: TextStyle(
                            fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Inicia sesión en tu cuenta',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              decoration:
                                  ThemeHelper().inputBoxDecorationShaddow(),
                              child: _commonTextField(
                                  "Correo", _emailController,
                                  validator: _emailValidator),
                            ),
                            const SizedBox(height: 15.0),
                            Container(
                              child: _commonTextField(
                                  "Contraseña", _passwordController,
                                  validator: _passwordValidator,
                                  isSuffixIconShow: true,
                                  showText: _isShowPassword),
                            ),
                            const SizedBox(height: 15.0),
                            Container(
                              decoration:
                                  ThemeHelper().buttonBoxDecoration(context),
                              child: ElevatedButton(
                                style: ThemeHelper().buttonStyle(),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(40, 10, 40, 10),
                                  child: Text(
                                    'Iniciar Sesion'.toUpperCase(),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                  });
                                  widget.onSignIn(Credentials(
                                      _emailController.text,
                                      _passwordController.text));

                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _commonTextField(String hintText, TextEditingController controller,
      {required String? Function(String?)? validator,
      bool showText = true,
      bool isSuffixIconShow = false}) {
    return TextFormField(
      controller: controller,
      cursorColor: const Color.fromARGB(255, 89, 0, 0),
      validator: validator,
      obscureText: !showText,
      onChanged: (val) {
        final trimVal = val.trim();
        if (val != trimVal) {
          setState(() {
            controller.text = trimVal;
            controller.selection = TextSelection.fromPosition(
                TextPosition(offset: trimVal.length));
          });
        }
      },
      decoration: ThemeHelper().textInputDecoration(hintText),
    );
  }

  String? _emailValidator(String? inputVal) {
    if (inputVal == null || inputVal.isEmpty) {
      return "Introduce un email válido";
    }
    final RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(_emailController.text)) {
      return "Email inválido";
    }
    return null;
  }

  String? _passwordValidator(String? inputVal) {
    if (inputVal == null || inputVal.isEmpty) return "Introduce la contraseña";
    if (inputVal.length < 6) return "Contraseña incorrecta";
    return null;
  }
}


/* void _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed("/home");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Center(
        child: Text("Usuario o contraseña inválidos"),
      )));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  } */