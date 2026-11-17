import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER
  Future<User?> register({
    required String name,
    required String kelas,
    required String email,
    required String password,
  }) async {
    try {
      // Membuat akun menggunakan Firebase Authentication
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // Membuat data profil pengguna
        UserModel userModel = UserModel(
          userId: user.uid,
          name: name,
          email: email,
          kelas: kelas,
          createdAt: DateTime.now(),
        );

        // Menyimpan profil ke Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // LOGIN
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Mengambil pengguna yang sedang login
  User? get currentUser => _auth.currentUser;

  // Memantau perubahan status login
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}