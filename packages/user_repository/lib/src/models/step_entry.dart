import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';


class StepEntry extends Equatable {
  final DateTime date;
  final int steps;
  final int goal;  // Add goal field

  const StepEntry({
    required this.date,
    required this.steps,
    this.goal = 10000,  // Default goal
  });

  StepEntryEntity toEntity() {
    return StepEntryEntity(
      date: date.toIso8601String(),
      steps: steps,
      goal: goal,
    );
  }

  static StepEntry fromEntity(StepEntryEntity entity) {
    return StepEntry(
      date: DateTime.parse(entity.date),
      steps: entity.steps,
      goal: entity.goal,
    );
  }

  @override
  List<Object?> get props => [date, steps, goal];
}