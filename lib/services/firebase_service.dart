import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
  
  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('User creation failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Add document to Firestore
  Future<DocumentReference> addDocument(
    String collection, 
    Map<String, dynamic> data,
  ) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Failed to add document: $e');
    }
  }

  // Get documents from Firestore
  Future<QuerySnapshot> getDocuments(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }

  // Update document in Firestore
  Future<void> updateDocument(
    String collection, 
    String documentId, 
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  // Delete document from Firestore
  Future<void> deleteDocument(
    String collection, 
    String documentId,
  ) async {
    try {
      await _firestore
          .collection(collection)
          .doc(documentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // Listen to real-time updates
  Stream<QuerySnapshot> streamDocuments(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Get user-specific documents
  Future<QuerySnapshot> getUserDocuments(
    String collection, 
    String userId,
  ) async {
    try {
      return await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .get();
    } catch (e) {
      throw Exception('Failed to get user documents: $e');
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Apple Sign In
  Future<UserCredential> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }

  // Create or update user document
  Future<void> createOrUpdateUserDocument(User user, {
    String? displayName,
    String? photoURL,
    String? provider,
    String? fcmToken,
  }) async {
    try {
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.displayName ?? 'User',
        'photoURL': photoURL ?? user.photoURL,
        'provider': provider ?? 'email',
        'fcmToken': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isEmailVerified': user.emailVerified,
        'phoneNumber': user.phoneNumber,
        'notificationSettings': {
          'pushEnabled': true,
          'emailEnabled': true,
          'smsEnabled': false,
          'inAppEnabled': true,
        },
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Check if user document exists
  Future<bool> userDocumentExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get user document
  Future<Map<String, dynamic>?> getUserDocument(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }
  
  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
      
      if (currentUser != null) {
        await createOrUpdateUserDocument(
          currentUser!,
          displayName: displayName,
          photoURL: photoURL,
        );
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}
