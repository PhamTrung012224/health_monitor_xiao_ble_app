import 'package:equatable/equatable.dart';

class StepEntryEntity extends Equatable {
  final String date; 
  final int steps;

  const StepEntryEntity({
    required this.date,
    required this.steps,
  });

  Map<String, Object?> toDocument() {
    return {
      'date': date,
      'steps': steps,
    };
  }

  static StepEntryEntity fromDocument(Map<String, dynamic> doc) {
    return StepEntryEntity(
      date: doc['date'],
      steps: doc['steps'],
    );
  }

  @override
  List<Object?> get props => [date, steps];
}