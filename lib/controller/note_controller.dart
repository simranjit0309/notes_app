import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../model/note_model.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NoteController extends GetxController{

  var allNotes = List<NoteModel>.empty(growable: true).obs;
  var sharedPrefNotes = List<NoteModel>.empty(growable: true).obs;
  var firebaseNotes = List<NoteModel>.empty(growable: true).obs;
  late QuerySnapshot querySnapshot;
  late SharedPreferences prefs;
  var isLoading = false.obs;

  String? getFirebaseUserId(){
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser?.uid.toString();
  }

  bool isUserLoggedIn(){
    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser!=null;
  }

  void signOut() async {
    final googleSignIn = GoogleSignIn();
    FirebaseAuth.instance.signOut().then((_) async => {
      firebaseNotes.clear(),
      //To show the google sign in sheet again.
      //If the below line is not added,
      //it will sign in the user with previously selected email id
      //whenever user sign's in again
       await googleSignIn.signOut(),
      showSnackbar('Sign out successful',false),
      getNotes()
    });
  }

  Future<void> getNotes() async {
    isLoading.value = true;
    final String? notes = prefs.getString('notes');
    if(notes!=null && notes != "") {
      //fetching all shared preference notes
      final List<NoteModel> noteModel = NoteModel.decode(notes);
      sharedPrefNotes.clear();
      sharedPrefNotes.addAll(noteModel);
    }

    //fetching all notes from firebase
    if(isUserLoggedIn()) {
      String? uid = getFirebaseUserId();
      if(uid!=null){
        FirebaseFirestore.instance.collection(uid).orderBy("asc");
        CollectionReference user = FirebaseFirestore.instance.collection(uid);
        querySnapshot = await user.get();
        List<Map<String, dynamic>?> documentData = querySnapshot.docs.map((e) => e.data() as Map<String, dynamic>?).toList();
        firebaseNotes.clear();
        for (int i = 0; i < documentData.length; i++) {
          firebaseNotes.add(NoteModel(id: documentData[i]!['noteId'],
              note: documentData[i]!['note'],
              dateTime: documentData[i]!['dateTime'],
              heading: documentData[i]!['heading']));
        }
      }
    }
    allNotes.clear();
    allNotes.addAll(sharedPrefNotes);
    allNotes.addAll(firebaseNotes);

    //sorting notes according to latest dates
    allNotes.sort((date1,date2){
      var aDate = date1.dateTime;
      var bDate = date2.dateTime;
      return bDate.compareTo(aDate);
    });
    isLoading.value = false;
  }

  Future<void> editUpdateNote(String editedNote,String heading,NoteModel note) async{
    String? uid = getFirebaseUserId();
    if(uid !=null && firebaseNotes.isNotEmpty){
      List<String> docIds = querySnapshot.docs.map((doc) => doc.id).toList();
      for(int i = 0 ; i < firebaseNotes.length;i++){
        if(note.id == firebaseNotes[i].id){
          firebaseNotes[i].note = editedNote;
          FirebaseFirestore.instance.collection(uid).doc(docIds[i]).update({
            'note':editedNote,
            'heading':heading
          }).then((value) => print("updated note")).catchError((error)=>showSnackbar("Something went wrong",true));
          Get.back(result: true);
        }
      }
    }

    for(int i = 0 ; i < sharedPrefNotes.length;i++){
      if(note.id == sharedPrefNotes[i].id){
        sharedPrefNotes[i].note = editedNote;
        sharedPrefNotes[i].heading = heading;
        prefs.setString('notes', NoteModel.encode(sharedPrefNotes));
        Get.back(result: true);
      }
    }

  }

  Future<void> deleteNote(NoteModel note) async{
    String? uid =getFirebaseUserId();
    if(uid !=null && firebaseNotes.isNotEmpty){
      List<String> docIds = querySnapshot.docs.map((doc) => doc.id).toList();

      for(int i = 0 ; i < firebaseNotes.length;i++){
        if(note.id == firebaseNotes[i].id){
          FirebaseFirestore.instance
              .collection(uid)
              .doc(docIds[i])
              .delete();
          Get.back(result: true);
        }
      }
    }
    for(int i = 0 ; i < sharedPrefNotes.length;i++){
      if(note.id == sharedPrefNotes[i].id){
        sharedPrefNotes.removeAt(i);
         prefs.setString('notes', NoteModel.encode(sharedPrefNotes));
        Get.back(result: true);
      }
    }

  }

  Future<void> addNote(String note,String heading) async {
   if(note.isNotEmpty || heading.isNotEmpty){
     // Encode and store data in SharedPreferences
     sharedPrefNotes.add(NoteModel(id: randomAlphaNumeric(5), note: note, dateTime: DateFormat('dd-MM-yyyy – hh:mm').format(DateTime.now()),heading:heading));

     prefs.setString('notes', NoteModel.encode(sharedPrefNotes));
     final String? musicsString = prefs.getString('notes');

     final List<NoteModel> noteModel = NoteModel.decode(musicsString!);
     sharedPrefNotes.addAll(noteModel);
     Get.back(result: true);
   }

  }

  Future googleLogin(bool isSignin) async{
    if(isUserLoggedIn()){
      return;
    }
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,);
      await FirebaseAuth.instance.signInWithCredential(credential).then((userCredential) {
        if (userCredential.user != null) {
          showSnackbar('Sign in successful',false);
          if(isSignin){
            getNotes();
          }else {
            addNotesToFirebase();
          }
        }
      });
    } catch (e) {
      showSnackbar("Something went wrong",true);
    }
  }

  Future<void> addNotesToFirebase() async {
    if(isUserLoggedIn()){
      try{
        String? uid = getFirebaseUserId();
        if(uid !=null && sharedPrefNotes.isNotEmpty){
          CollectionReference user = FirebaseFirestore.instance.collection(uid);
          for(int i = 0; i < sharedPrefNotes.length;i++){
            user.add({'note':sharedPrefNotes[i].note,
              'noteId':sharedPrefNotes[i].id,
              'dateTime':sharedPrefNotes[i].dateTime,
              'heading':sharedPrefNotes[i].heading,
            });
            prefs.setString('notes', '');
          }
          sharedPrefNotes.clear();
          getNotes();
        }
      } catch (error) {
        showSnackbar("Something went wrong",true);
      }
    }else{
      googleLogin(false);
    }

  }

  void showSnackbar(String message,bool isError){
    GetSnackBar(
        messageText: Text(message,
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isError?Colors.red:Colors.green,
        snackPosition: SnackPosition.BOTTOM)
        .show();
  }
}