import 'package:equatable/equatable.dart';

class StepEntryEntity extends Equatable {
  final String date;
  final int steps;
  final int goal;  // Add goal field

  const StepEntryEntity({
    required this.date,
    required this.steps,
    this.goal = 10000,  // Default goal
  });

  Map<String, Object?> toDocument() {
    return {
      'date': date,
      'steps': steps,
      'goal': goal,  // Include goal in document
    };
  }

  static StepEntryEntity fromDocument(Map<String, dynamic> doc) {
    return StepEntryEntity(
      date: doc['date'],
      steps: doc['steps'],
      goal: doc['goal'] ?? 10000,  // Read goal with default
    );
  }

  @override
  List<Object?> get props => [date, steps, goal];
}