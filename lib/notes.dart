import 'package:appwrite/appwrite.dart' as appwriteClient;
import 'package:appwrite_test/add_note.dart';
import 'package:appwrite_test/constants/constants.dart';
import 'package:appwrite_test/home.dart';
import 'package:appwrite_test/model/note.dart';
import 'package:flutter/material.dart';
import 'package:dart_appwrite/dart_appwrite.dart' as appwriteServer;

class Notes extends StatefulWidget {
  final appwriteClient.Account account;
  final appwriteServer.Databases databases;
  final appwriteServer.Users users;
  const Notes(
      {required this.account, required this.databases, required this.users});

  @override
  State<Notes> createState() =>
      _NotesState(this.account, this.databases, this.users);
}

class _NotesState extends State<Notes> {
  appwriteServer.Databases databases;
  appwriteClient.Account account;
  appwriteServer.Users users;
  _NotesState(this.account, this.databases, this.users);
  bool isLoading = true;
  List<Note>? notes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNotes();
  }

  getNotes() async {
    setState(() {
      isLoading = true;
    });
    notes?.clear();
    try {
      final documents = await databases.listDocuments(
        // databaseId: '653cbdc6623ebdfda8fa',
        databaseId: Constants.DATABASE_ID,
        collectionId: Constants.NOTES_COLLECTION_ID,
        // queries: [Query.equal('title', 'description')]
      );
      for (var doc in documents.documents) {
        Map<String, dynamic> mp = doc.toMap()["data"];
        Note note = Note(title: mp["title"], description: mp["description"]);
        notes?.add(note);
      }
      setState(() {
        notes;
      });
    } on appwriteServer.AppwriteException catch (e) {
      print(e);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> logout() async {
    await widget.account.deleteSession(sessionId: 'current');
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Home(
              account: account,
            )));
  }

  Future<void> addNotesWithLoadTesting(
      int numberOfNotes, String collectionId, String collectionName) async {
    List<dynamic> allDocs = [];
    try {
      for (int i = 0; i < numberOfNotes; i++) {
        final document = await databases.createDocument(
            databaseId: Constants.DATABASE_ID,
            collectionId: collectionId,
            documentId: appwriteServer.ID.unique(),
            data: {
              "title": "Test Title ${i.toString()}",
              "description": "Description ${i.toString()}"
            });
        print(document.$id);
        allDocs.add(document);
      }
      print(allDocs.length);
      print("Docs added to appwrite");
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text("Added ${numberOfNotes} Note"),
              ));
    } on appwriteServer.AppwriteException catch (e) {
      print("----Eception Occured-----: ${collectionName}");
      print("Total documents created are");
      print(allDocs.length);
      print(e);
      print("----Eception Occured-----: ${collectionName}");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("My Notes"), actions: [
          IconButton(
              onPressed: () {
                logout();
              },
              icon: Icon(Icons.logout))
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AddNote(databases: databases)));
            getNotes();
          },
          child: Icon(Icons.add),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: notes?.length,
                        itemBuilder: (context, index) {
                          Note note = notes![index];
                          return ListTile(
                            title: Text(note.getTitle!),
                            subtitle: Text(note.getDescription),
                          );
                        }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(
                        onPressed: () {
                          addNotesWithLoadTesting(
                              1000, Constants.NOTES_COLLECTION_ID, "notes");
                        },
                        child: Text("Load test to Notes"),
                      ),

                      MaterialButton(
                        onPressed: () {
                          addNotesWithLoadTesting(
                              1000, Constants.ORDERS_COLLECTION_ID, "orders");
                        },
                        child: Text("Load test to orders"),
                      )
                    ],
                  )
                ],
              ));
  }
}
