import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:notes_app/views/notes_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controller/note_controller.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NoteController noteController = Get.put(NoteController());
  noteController.prefs = await SharedPreferences.getInstance();

  runApp( GetMaterialApp(
    theme: ThemeData(fontFamily: 'roboto'),
    debugShowCheckedModeBanner: false,
    home: NotesList(),
  ));
}
