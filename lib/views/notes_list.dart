import 'package:flutter/material.dart';
import '../controller/note_controller.dart';
import '../model/note_model.dart';
import 'package:get/get.dart';

import 'notes.dart';

class NotesList extends StatelessWidget {
  final TextEditingController controller = TextEditingController();
  final allNotes = List<NoteModel>.empty(growable: true).obs;
  final NoteController noteController = Get.find();

  NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    noteController.getNotes();
    return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10.0,10.0,0.0,10.0),
                height: 55,
                color:const Color(0xffF4D35E),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notes App',style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),),
                    const Spacer(),
                    InkWell(
                      onTap: (){
                        if(noteController.sharedPrefNotes.isEmpty){
                          noteController.showSnackbar('No notes to sync',false);
                        }else {
                          noteController.addNotesToFirebase();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.cloud_done_sharp,
                            color: Color(0xff0D3B66),
                            size: 30.0,
                          ),
                         Obx((){
                           return  Positioned(
                             right: 0,
                             bottom: 0,
                             child: Visibility(
                               visible: noteController.sharedPrefNotes.isNotEmpty,
                               child: Container(
                                 width: 12,
                                 height: 12,
                                 decoration: BoxDecoration(
                                     color:Colors.orange[900],
                                     borderRadius: const BorderRadius.all(Radius.circular(20))),
                                 child: Text(noteController.sharedPrefNotes.length.toString(),
                                   textAlign: TextAlign.center,
                                   style: const TextStyle(fontSize: 8,color: Colors.black),
                                 ),
                               ),
                             ),
                           );
                         })
                        ],
                      ),
                    ),
                    PopupMenuButton<int>(
                      initialValue: 1,
                      // Callback that sets the selected popup menu item.
                      onSelected: (_) {
                       if(noteController.isUserLoggedIn()){
                         noteController.signOut();
                       }else{
                         noteController.googleLogin(true);
                       }
                      },
                      itemBuilder: (_) =>[
                         PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset("assets/images/google.png",height: 20,width: 20,),
                              Text(noteController.isUserLoggedIn()?'Sign Out':'Sign In'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(10.0),
                    height: Get.height,
                    child: Obx(() {
                      return noteController.isLoading.value?const Center(child: CircularProgressIndicator(),):Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              itemCount: noteController.allNotes.length,
                              itemBuilder: (ctx, index) => InkWell(
                                onTap: () async {
                                  final result =
                                  await Get.to(Notes(false,noteController.allNotes[index],));
                                  if (result != null && result) {
                                    noteController.getNotes();
                                  }
                                },
                                child: Container(
                                 padding: const EdgeInsets.all(4.0),
                                  decoration: const BoxDecoration(
                                      color: Color(0xffFAF0CA),
                                      borderRadius: BorderRadius.all(Radius.circular(10))),
                                  child: GridTile(
                                    child: noteController.allNotes[index].heading.isNotEmpty?
                                    RichText(
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black,),
                                        children: <TextSpan>[
                                          TextSpan(text: "${noteController.allNotes[index].heading}\n", style: const TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
                                          TextSpan(text: noteController.allNotes[index].note,style:const TextStyle(fontSize: 16.0),),
                                        ],
                                      ),
                                    ):
                                    Text(
                                      noteController.allNotes[index].note,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 16.0,color: Colors.black,fontWeight: FontWeight.bold),
                                      maxLines: 4,
                                    ),
                                  ),
                                ),
                              ),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                            ),
                          ),
                        ],
                      );
                    })),
              ),
            ],
          ),
        ),
        floatingActionButton:FloatingActionButton(
          onPressed: () async {
            final result = await Get.to(Notes(true));
            if (result != null && result) {
              noteController.getNotes();
            }
          },
          backgroundColor: Color(0xff0D3B66),
          child: const Icon(Icons.add),
        )

    );
  }
}
