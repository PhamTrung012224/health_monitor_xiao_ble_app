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

  @override
  Future<void> updateStepGoal(String userId, int stepGoal) async {
    try {
      // First, update the user's default goal
      await _firestore.collection('users').doc(userId).update({
        'stepGoal': stepGoal,
      });

      // Also update today's entry with the new goal
      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final todayStr = today.toIso8601String();

      // Get current user data
      final userData = await _firestore.collection('users').doc(userId).get();
      final userEntity =
          MyUserEntity.fromDocument(userData.data() as Map<String, dynamic>);
      final user = MyUser.fromEntity(userEntity);

      // Find today's entry
      final existingEntryIndex = user.stepHistory.indexWhere((entry) =>
          entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day);

      if (existingEntryIndex >= 0) {
        // If today's entry exists, update it with the new goal
        final existingEntry = user.stepHistory[existingEntryIndex];
        final updatedEntry = StepEntry(
          date: existingEntry.date,
          steps: existingEntry.steps,
          goal: stepGoal,
        );

        final updatedHistory = List<StepEntry>.from(user.stepHistory);
        updatedHistory[existingEntryIndex] = updatedEntry;

        await _firestore.collection('users').doc(userId).update({
          'stepHistory': updatedHistory
              .map((entry) => entry.toEntity().toDocument())
              .toList(),
        });
      } else {
        // If no entry for today, create one with 0 steps and the new goal
        final newEntry = StepEntry(
          date: today,
          steps: 0,
          goal: stepGoal,
        );

        final updatedHistory = List<StepEntry>.from(user.stepHistory)
          ..add(newEntry);

        await _firestore.collection('users').doc(userId).update({
          'stepHistory': updatedHistory
              .map((entry) => entry.toEntity().toDocument())
              .toList(),
        });
      }

      log('Updated step goal for $userId to $stepGoal');
    } catch (e) {
      log('Error updating step goal: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStepCount(String userId, int stepCount, bool addToExisting) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      final userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }

      final userEntity =
      MyUserEntity.fromDocument(userDoc.data() as Map<String, dynamic>);

      final user = MyUser.fromEntity(userEntity);
      final currentGoal = user.stepGoal; // Get user's current goal

      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      final existingEntry = user.stepHistory.firstWhere(
            (entry) =>
        entry.date.year == today.year &&
            entry.date.month == today.month &&
            entry.date.day == today.day,
        orElse: () => StepEntry(date: today, steps: 0, goal: currentGoal),
      );

      final newStepCount = addToExisting
          ? existingEntry.steps + stepCount
          : stepCount;

      // Create a new entry with the current goal
      final updatedEntry = StepEntry(
        date: today,
        steps: newStepCount,
        goal: existingEntry.goal != 10000 ? existingEntry.goal : currentGoal, // Keep existing goal if set, otherwise use current
      );

      // Find index of today's entry to update or add it
      final index = user.stepHistory.indexWhere((entry) =>
      entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day);

      final updatedHistory = List<StepEntry>.from(user.stepHistory);
      if (index >= 0) {
        updatedHistory[index] = updatedEntry;
      } else {
        updatedHistory.add(updatedEntry);
      }

      // Update Firebase
      await userDocRef.update({
        'stepHistory': updatedHistory
            .map((entry) => entry.toEntity().toDocument())
            .toList(),
      });

      log('Updated step count for $userId: now $newStepCount steps');
    } catch (e) {
      log('Error updating step count: $e');
      rethrow;
    }
  }
}
