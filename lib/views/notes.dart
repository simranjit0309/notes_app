
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/note_controller.dart';
import '../model/note_model.dart';


class Notes extends StatelessWidget{

  String noteText = "";
  late TextEditingController controller;
  late TextEditingController headingText;
  NoteModel? note;
  bool isAddNote = false;
  var allNotes = List<NoteModel>.empty(growable: true);
  var sharedPrefNotes = List<NoteModel>.empty(growable: true);
  var lists = List<NoteModel>.empty(growable: true);
  late List<Object?> allData;
  NoteController noteController = Get.find();

  Notes(this.isAddNote,[this.note]){
    controller = TextEditingController(text: note?.note);
    headingText = TextEditingController(text: note?.heading??'');
  }


  @override
  Widget build(BuildContext context) {
   return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: ()async {
            if(isAddNote){
              noteController.addNote(controller.text,headingText.text);
              return true;
            }else{
              noteController.editUpdateNote(controller.text,headingText.text, note!);
              return true;
            }
          },
          child: Container(
          color: const Color(0xffFAF0CA),
            child: Column(
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                  child: Row(
                    children: [
                     InkWell(child: const Icon(Icons.arrow_back),onTap: (){
                       Get.back();
                     },),
                      const Spacer(),
                      InkWell(
                        onTap: (){
                         FlutterShare.share(title: 'Notes APP',text: note!.heading.isNotEmpty?"${note!.heading}\n${note!.note}":note!.note);
                        },
                        child: const Icon(Icons.share,),
                      ),
                      const SizedBox(width: 5.0,),
                      InkWell(
                        onTap: (){
                          noteController.deleteNote(note!);
                        },
                        child: const Icon(Icons.delete,),
                      ),
                      const SizedBox(width: 5.0,),
                      InkWell(
                        onTap: () async {
                          noteController.addNote(controller.text,headingText.text);
                        },
                          child: const Icon(Icons.add))
                    ],
                  ),),
                 const SizedBox(height: 10.0,),
                 Container(
                   padding: const EdgeInsets.fromLTRB(8.0,0.0,8.0,0.0),
                   height: 40,
                   alignment: Alignment.centerLeft,
                   child: Text(note!=null?note!.dateTime:DateFormat('dd-MM-yyyy – hh:mm').format(DateTime.now())),
                 ),
                 Container(
                   padding: const EdgeInsets.fromLTRB(8.0,0.0,8.0,0.0),
                  height: 50,
                  child:  TextField(
                    maxLines: 1,
                    controller: headingText,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                        hintText: "Enter Heading",
                      counterText: "",
                    ),
                    maxLength: 30,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //Text('test')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0,0.0,8.0,8.0),
                          child: TextField(controller: controller,
                            maxLines: 2000,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }

}