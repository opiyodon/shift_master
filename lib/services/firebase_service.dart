import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shift_master/services/firestore_service.dart';

class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Register user
  Future<User?> register(String email, String password,
      {required String firstName, required String lastName}) async {
    try {
      // Check if user already exists
      bool userExists = await _firestoreService.checkUserExists(email);
      if (userExists) {
        throw Exception('User already exists');
      }

      UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user in Firestore
      await _firestoreService.createUser(
        userCredential.user!.uid,
        email,
        firstName,
        lastName,
      );

      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Login user
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await auth.signInWithCredential(credential);

      // Check if user exists in Firestore, if not, create a new user
      bool userExists =
          await _firestoreService.checkUserExists(userCredential.user!.email!);
      if (!userExists) {
        await _firestoreService.createUser(
          userCredential.user!.uid,
          userCredential.user!.email!,
          userCredential.user!.displayName?.split(' ').first ?? '',
          userCredential.user!.displayName?.split(' ').last ?? '',
        );
      }

      return userCredential.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Logout user
  Future<void> logout() async {
    await auth.signOut();
    await _googleSignIn.signOut();
    // Add LinkedIn logout if necessary
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return auth.currentUser != null;
  }
}
