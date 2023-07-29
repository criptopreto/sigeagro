import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseAuthService {
  late BehaviorSubject<User?> _userSubject;
  Stream<User?> get signedInStream => _userSubject.stream;
  User? get currentUser => _userSubject.valueOrNull;

  FirebaseAuthService() {
    _userSubject = BehaviorSubject<
        User?>(); // Establecer el valor inicial del BehaviorSubject
    _userSubject.add(FirebaseAuth.instance.currentUser);
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _userSubject.add(user);
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _userSubject.close();
  }
}

class FirebaseAuthScope extends InheritedWidget {
  final FirebaseAuthService authService;

  const FirebaseAuthScope({
    Key? key,
    required this.authService,
    required Widget child,
  }) : super(key: key, child: child);

  static FirebaseAuthService of(BuildContext context) {
    final FirebaseAuthScope? scope =
        context.dependOnInheritedWidgetOfExactType<FirebaseAuthScope>();
    assert(scope != null, 'No FirebaseAuthScope found in context');
    return scope!.authService;
  }

  @override
  bool updateShouldNotify(FirebaseAuthScope oldWidget) =>
      authService != oldWidget.authService;
}
