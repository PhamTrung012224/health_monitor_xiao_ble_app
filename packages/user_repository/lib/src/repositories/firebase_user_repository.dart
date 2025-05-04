import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  FirebaseUserRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser;
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: myUser.email, password: password);
      myUser = myUser.copyWith(userId: user.user!.uid);
      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocuments());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String> uploadPicture(String path, String userId) async {
    try {
      File imageFile = File(path);
      Reference firebaseStoreRef =
          FirebaseStorage.instance.ref().child('$userId/PP/${userId}_lead');
      await firebaseStoreRef.putFile(imageFile);
      String url = await firebaseStoreRef.getDownloadURL();
      await usersCollection.doc(userId).update({'picture': url});
      return url;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> getUserData(String userId) async {
    try {
      return usersCollection.doc(userId).get().then((value) =>
          MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> editUsername(String userId, String newUsername) async {
    try {
      return usersCollection.doc(userId).update({"name": newUsername});
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Future<void> updateStepCount(String userId, int stepCount) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userEntity =
          MyUserEntity.fromDocument(userDoc.data() as Map<String, dynamic>);

      final user = MyUser.fromEntity(userEntity);

      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      final existingEntry = user.stepHistory.firstWhere(
        (entry) =>
            entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day,
        orElse: () => StepEntry(date: today, steps: 0),
      );

      final newStepCount = existingEntry.steps + stepCount;

      final updatedUser = user.addStepEntry(today, newStepCount);

      await userDocRef.update({
        'stepHistory': updatedUser.stepHistory
            .map((entry) => entry.toEntity().toDocument())
            .toList(),
      });

      log('Updated step count for $userId: now $newStepCount steps');
    } catch (e) {
      log('Error updating step count: $e');
      rethrow;
    }
  }

  @override
  Future<List<StepEntry>> getStepHistory(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userEntity =
          MyUserEntity.fromDocument(userDoc.data() as Map<String, dynamic>);

      final user = MyUser.fromEntity(userEntity);

      return user.stepHistory;
    } catch (e) {
      log('Error getting step history: $e');
      rethrow;
    }
  }

  @override
  Future<int> getTotalSteps(String userId) async {
    try {
      final history = await getStepHistory(userId);
      int totalSteps = 0;
      for (var entry in history) {
        totalSteps += entry.steps;
      }
      return totalSteps;
    } catch (e) {
      log('Error calculating total steps: $e');
      rethrow;
    }
  }

//   @override
//   Future<double> getAverageSteps(String userId) async {
//     try {
//       final history = await getStepHistory(userId);
//       if (history.isEmpty) {
//         return 0;
//       }

//       int totalSteps = 0;
//       for (var entry in history) {
//         totalSteps += entry.steps;
//       }

//       return totalSteps / history.length;
//     } catch (e) {
//       log('Error calculating average steps: $e');
//       rethrow;
//     }
//   }
}
