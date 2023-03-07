import 'package:meta/meta.dart';
import 'dart:convert';

class NoteModel {

  String note,id,dateTime,heading;


  NoteModel({
    required this.id,
    required this.note,
    required this.dateTime,
    required this.heading
  });

  factory NoteModel.fromJson(Map<String, dynamic> jsonData) {
    return NoteModel(
        id: jsonData['id'],
        note: jsonData['note'],
        dateTime: jsonData['dateTime'] ?? '',
        heading: jsonData['heading']??''

    );
  }

  static Map<String, dynamic> toMap(NoteModel noteModel) => {
    'id': noteModel.id,
    'note': noteModel.note,
    'dateTime':noteModel.dateTime,
    'heading':noteModel.heading
  };

  static String encode(List<NoteModel> musics) => json.encode(
    musics
        .map<Map<String, dynamic>>((music) => NoteModel.toMap(music))
        .toList(),
  );

  static List<NoteModel> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<NoteModel>((item) => NoteModel.fromJson(item))
          .toList();
}