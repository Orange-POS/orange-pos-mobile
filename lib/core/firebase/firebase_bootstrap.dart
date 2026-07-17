import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap();

  Future<void> initialize() async {
    await Firebase.initializeApp();
  }
}
