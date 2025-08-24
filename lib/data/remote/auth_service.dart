import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import '../../services/firebase_messaging_service.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();
  
  // Get current user
  User? get currentUser => _firebaseService.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _firebaseService.authStateChanges;
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _firebaseService.signInWithEmailAndPassword(email, password);
    final fcmToken = await _messagingService.getCurrentToken();
    await _firebaseService.createOrUpdateUserDocument(
      credential.user!, 
      provider: 'email',
      fcmToken: fcmToken,
    );
    return credential;
  }
  
  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    final credential = await _firebaseService.createUserWithEmailAndPassword(email, password);
    final fcmToken = await _messagingService.getCurrentToken();
    await _firebaseService.createOrUpdateUserDocument(
      credential.user!, 
      displayName: displayName,
      provider: 'email',
      fcmToken: fcmToken,
    );
    return credential;
  }
  
  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    final credential = await _firebaseService.signInWithGoogle();
    final user = credential.user!;
    final fcmToken = await _messagingService.getCurrentToken();
    
    // Check if user document exists
    final exists = await _firebaseService.userDocumentExists(user.email!);
    if (!exists) {
      // Create new user document for social signup
      await _firebaseService.createOrUpdateUserDocument(
        user,
        displayName: user.displayName,
        photoURL: user.photoURL,
        provider: 'google',
        fcmToken: fcmToken,
      );
    } else {
      // Update existing user document for social login
      await _firebaseService.createOrUpdateUserDocument(
        user,
        displayName: user.displayName,
        photoURL: user.photoURL,
        provider: 'google',
        fcmToken: fcmToken,
      );
    }
    
    return credential;
  }
  
  // Apple Sign In
  Future<UserCredential> signInWithApple() async {
    final credential = await _firebaseService.signInWithApple();
    final user = credential.user!;
    final fcmToken = await _messagingService.getCurrentToken();
    
    // Check if user document exists
    final exists = await _firebaseService.userDocumentExists(user.email!);
    if (!exists) {
      // Create new user document for social signup
      await _firebaseService.createOrUpdateUserDocument(
        user,
        displayName: user.displayName ?? 'Apple User',
        photoURL: user.photoURL,
        provider: 'apple',
        fcmToken: fcmToken,
      );
    } else {
      // Update existing user document for social login
      await _firebaseService.createOrUpdateUserDocument(
        user,
        displayName: user.displayName ?? 'Apple User',
        photoURL: user.photoURL,
        provider: 'apple',
        fcmToken: fcmToken,
      );
    }
    
    return credential;
  }
  
  // Sign out
  Future<void> signOut() async {
    await _firebaseService.signOut();
  }
  
  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    await _firebaseService.updateUserProfile(displayName: displayName, photoURL: photoURL);
  }
  
  // Get user model from Firebase user
  Future<UserModel?> getUserModel() async {
    final user = currentUser;
    if (user == null) return null;
    
    final userDoc = await _firebaseService.getUserDocument(user.uid);
    if (userDoc == null) return null;
    
    return UserModel.fromJson(userDoc);
  }
}
