import 'package:equatable/equatable.dart';
import '../entities/step_entry_entity.dart';

class StepEntry extends Equatable {
  final DateTime date;
  final int steps;

  const StepEntry({
    required this.date,
    required this.steps,
  });

  StepEntryEntity toEntity() {
    return StepEntryEntity(
      date: date.toIso8601String(),
      steps: steps,
    );
  }

  static StepEntry fromEntity(StepEntryEntity entity) {
    return StepEntry(
      date: DateTime.parse(entity.date),
      steps: entity.steps,
    );
  }

  @override
  List<Object?> get props => [date, steps];
}