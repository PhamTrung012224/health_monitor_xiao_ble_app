import 'package:equatable/equatable.dart';
import '../entities/entities.dart';
import 'step_entry.dart';

class MyUser extends Equatable {
  final String userId;
  final String email;
  final String name;
  final String picture;
  final List<StepEntry> stepHistory;
  final int stepGoal;

  const MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.picture,
    this.stepHistory = const [],
    this.stepGoal = 10000,
  });

  static const empty = MyUser(userId: '', email: '', name: '', picture: '');

  MyUser copyWith({
    String? userId,
    String? email,
    String? name,
    String? picture,
    List<StepEntry>? stepHistory,
    int? stepGoal,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      stepHistory: stepHistory ?? this.stepHistory,
      stepGoal: stepGoal ?? this.stepGoal,
    );
  }

  MyUser addStepEntry(DateTime date, int steps) {
    final updatedHistory = List<StepEntry>.from(stepHistory);

    final index = updatedHistory.indexWhere((entry) =>
        entry.date.year == date.year &&
        entry.date.month == date.month &&
        entry.date.day == date.day);

    if (index >= 0) {
      updatedHistory[index] = StepEntry(date: date, steps: steps);
    } else {
      updatedHistory.add(StepEntry(date: date, steps: steps));
    }

    return copyWith(stepHistory: updatedHistory);
  }

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      name: name,
      picture: picture,
      stepHistory: stepHistory.map((entry) => entry.toEntity()).toList(),
      stepGoal: stepGoal,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      name: entity.name,
      picture: entity.picture,
      stepHistory: entity.stepHistory
          .map((entry) => StepEntry.fromEntity(entry))
          .toList(),
      stepGoal: entity.stepGoal,
    );
  }

  @override
  List<Object?> get props => [userId, email, name, picture, stepHistory,stepGoal];
}
