import 'package:equatable/equatable.dart';
import 'step_entry_entity.dart';

class MyUserEntity extends Equatable {
  final String userId;
  final String email;
  final String name;
  final String picture;
  final List<StepEntryEntity> stepHistory;

  const MyUserEntity({
    required this.userId,
    required this.email,
    required this.name,
    required this.picture,
    this.stepHistory = const [],
  });

  Map<String, Object?> toDocuments() {
    return {
      'userId': userId, 
      'email': email, 
      'name': name, 
      'picture': picture,
      'stepHistory': stepHistory.map((entry) => entry.toDocument()).toList(),
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    final stepHistoryData = doc['stepHistory'] as List<dynamic>?;
    final stepHistory = stepHistoryData != null 
        ? stepHistoryData
            .map((entry) => StepEntryEntity.fromDocument(entry))
            .toList()
        : <StepEntryEntity>[];
            
    return MyUserEntity(
      userId: doc['userId'],
      email: doc['email'],
      name: doc['name'],
      picture: doc['picture'],
      stepHistory: stepHistory,
    );
  }

  @override
  List<Object?> get props => [userId, email, name, picture, stepHistory];
}