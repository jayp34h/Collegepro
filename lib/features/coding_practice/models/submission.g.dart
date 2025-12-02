// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubmissionAdapter extends TypeAdapter<Submission> {
  @override
  final int typeId = 0;

  @override
  Submission read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Submission(
      id: fields[0] as String,
      studentId: fields[1] as String,
      questionId: fields[2] as String,
      code: fields[3] as String,
      language: fields[4] as String,
      languageId: fields[5] as int,
      executionResult: fields[6] as String,
      status: fields[7] as String,
      score: fields[8] as int,
      feedback: fields[9] as String,
      suggestion: fields[10] as String,
      timestamp: fields[11] as DateTime,
      isCorrect: fields[12] as bool,
      executionTime: fields[13] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Submission obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.questionId)
      ..writeByte(3)
      ..write(obj.code)
      ..writeByte(4)
      ..write(obj.language)
      ..writeByte(5)
      ..write(obj.languageId)
      ..writeByte(6)
      ..write(obj.executionResult)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.score)
      ..writeByte(9)
      ..write(obj.feedback)
      ..writeByte(10)
      ..write(obj.suggestion)
      ..writeByte(11)
      ..write(obj.timestamp)
      ..writeByte(12)
      ..write(obj.isCorrect)
      ..writeByte(13)
      ..write(obj.executionTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
