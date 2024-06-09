import 'package:appwrite/appwrite.dart' as appwriteClient;
import 'package:appwrite_test/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:dart_appwrite/dart_appwrite.dart' as appwriteServer;

class AddNote extends StatefulWidget {
  final appwriteServer.Databases databases;
  const AddNote({ required this.databases});

  @override
  State<AddNote> createState() => _AddNoteState(this.databases);
}

class _AddNoteState extends State<AddNote> {
   appwriteServer.Databases databases;
  _AddNoteState( this.databases);
  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    Future<void> addNote(String title, String description) async {
      try {
        final document = await databases.createDocument(
            databaseId: Constants.DATABASE_ID,
            collectionId: Constants.NOTES_COLLECTION_ID,
            documentId: appwriteServer.ID.unique(),
            data: {
              "title": titleController.text,
              "description": descriptionController.text
            });
        print(document);
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text("Added Note"),
                ));
      }catch (e) {
        print(e);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Add Note"),
        ),
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  addNote(titleController.text, descriptionController.text);
                },
                child: Text('Add Note'),
              ),
            ],
          ),
        ));
  }
}
