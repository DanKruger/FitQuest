import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:fitquest/data/models/user_model.dart';
import 'package:fitquest/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final GoogleSignIn _googleSignIn;
  User? loggedInUser;
  FirebaseAuth get getAuth => _auth;

  FirebaseAuthService() {
    _initFirebase();
  }

  Future<bool> isLoggedIn() async {
    loggedInUser = _auth.currentUser;
    if (loggedInUser == null) {
      return false;
    }
    return true;
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential cred = await _auth.signInWithCredential(credential);
      User? newUser = cred.user;

      if (newUser?.displayName != null) {
        _saveNewUserInformation(
            newUser,
            UserModel(
              firstName: newUser!.displayName?.split(" ")[0] ?? " User ",
              lastName: newUser.displayName?.split(" ")[1] ?? " User ",
              email: newUser.email ?? " Email ",
              password: "",
              friendRequests: [],
              friends: [],
            ));
      }

      return newUser;
    } catch (e) {
      throw Exception(
          'An error has occurred when trying to sign in with google auth $e');
    }
  }

  Future<User?> registerUser(UserModel payload) async {
    User? newUser;
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: payload.email,
        password: payload.password!,
      );
      newUser = cred.user;
      _saveNewUserInformation(newUser, payload);
    } catch (e) {
      throw Exception("An error occured when trying to register $e");
    }
    return newUser;
  }

  Future<User?> signIn(UserModel payload) async {
    User? signedInUser;
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: payload.email,
        password: payload.password!,
      );
      signedInUser = cred.user;
      Map<String, dynamic>? userInfo =
          (await _getUserInformation(signedInUser)).data();
      await signedInUser?.updateDisplayName(
          "${userInfo?["first_name"]} ${userInfo?["last_name"]}");
      await signedInUser?.reload();
      signedInUser = _auth.currentUser;
    } on Exception catch (e) {
      throw Exception("An error occured when trying to sign in $e");
    } finally {
      loggedInUser = signedInUser;
    }
    return signedInUser;
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Map<String, dynamic> userPreferencesModel(payload) => {
        "first_name": payload.firstName,
        "last_name": payload.lastName,
        "email_address": payload.email
      };

  void _initFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _googleSignIn = GoogleSignIn();
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserInformation(
      User? newUser) async {
    return await _firestore.collection('users').doc(newUser?.uid).get();
  }

  void _saveNewUserInformation(User? newUser, UserModel payload) async {
    var userDoc = await _firestore.collection('users').doc(newUser?.uid).get();
    userDoc.exists
        ? null
        : await _firestore
            .collection('users')
            .doc(newUser?.uid)
            .set(userPreferencesModel(payload));
  }
}
