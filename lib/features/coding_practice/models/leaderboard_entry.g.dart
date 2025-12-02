// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaderboardEntryAdapter extends TypeAdapter<LeaderboardEntry> {
  @override
  final int typeId = 1;

  @override
  LeaderboardEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaderboardEntry(
      studentId: fields[0] as String,
      studentName: fields[1] as String,
      totalScore: fields[2] as int,
      problemsSolved: fields[3] as int,
      title: fields[4] as String,
      funnyNote: fields[5] as String,
      lastActivity: fields[6] as DateTime,
      languageStats: (fields[7] as Map).cast<String, int>(),
      averageScore: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, LeaderboardEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.studentId)
      ..writeByte(1)
      ..write(obj.studentName)
      ..writeByte(2)
      ..write(obj.totalScore)
      ..writeByte(3)
      ..write(obj.problemsSolved)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.funnyNote)
      ..writeByte(6)
      ..write(obj.lastActivity)
      ..writeByte(7)
      ..write(obj.languageStats)
      ..writeByte(8)
      ..write(obj.averageScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
