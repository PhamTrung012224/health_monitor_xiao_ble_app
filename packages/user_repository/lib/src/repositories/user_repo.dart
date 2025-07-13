import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';



abstract class UserRepository {
  Stream<User?> get user;
  
  // Authentication methods
  Future<void> signIn(String email, String password);

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> logOut();

  // User data methods
  Future<void> setUserData(MyUser user);

  Future<MyUser> getUserData(String userId);

  Future<String> uploadPicture(String path, String userId);

  Future<void> editUsername(String userId, String newUsername);


  // Step tracking methods
  Future<List<StepEntry>> getStepHistory(String userId);

  Future<int> getTotalSteps(String userId);

  Future<void> updateStepCount(String userId, int stepCount, bool addToExisting);

  Future<void> updateStepGoal(String userId, int stepGoal);


}