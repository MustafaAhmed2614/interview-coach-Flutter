// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionResultAdapter extends TypeAdapter<SessionResult> {
  @override
  final int typeId = 0;

  @override
  SessionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionResult(
      id: fields[0] as String,
      role: fields[1] as String,
      interviewType: fields[2] as String,
      difficulty: fields[3] as String,
      date: fields[4] as DateTime,
      questions: (fields[5] as List).cast<String>(),
      transcripts: (fields[6] as List).cast<String>(),
      contentScores: (fields[7] as List).cast<int>(),
      clarityScores: (fields[8] as List).cast<int>(),
      confidenceScores: (fields[9] as List).cast<int>(),
      feedbacks: (fields[10] as List).cast<String>(),
      strongPhrases: (fields[11] as List).cast<String>(),
      weakPhrases: (fields[12] as List).cast<String>(),
      overallScore: fields[13] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SessionResult obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.interviewType)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.questions)
      ..writeByte(6)
      ..write(obj.transcripts)
      ..writeByte(7)
      ..write(obj.contentScores)
      ..writeByte(8)
      ..write(obj.clarityScores)
      ..writeByte(9)
      ..write(obj.confidenceScores)
      ..writeByte(10)
      ..write(obj.feedbacks)
      ..writeByte(11)
      ..write(obj.strongPhrases)
      ..writeByte(12)
      ..write(obj.weakPhrases)
      ..writeByte(13)
      ..write(obj.overallScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
