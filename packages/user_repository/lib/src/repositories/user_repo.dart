import 'package:firebase_auth/firebase_auth.dart';

import '../../user_repository.dart';

abstract class UserRepository {
  Stream<User?> get user;

  Future<void> signIn(String email, String password);

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> setUserData(MyUser user);

  Future<MyUser> getUserData(String userId);

  Future<String> uploadPicture(String path, String userId);

  Future<void> editUsername(String userId, String newUsername);

  Future<void> logOut();
}