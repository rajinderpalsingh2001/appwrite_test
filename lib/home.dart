import 'package:appwrite/appwrite.dart' as appwriteClient;
import 'package:appwrite_test/constants/constants.dart';
import 'package:dart_appwrite/dart_appwrite.dart' as appwriteServer;
import 'package:appwrite_test/notes.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';

class Home extends StatefulWidget {
  final appwriteClient.Account account;
  Home({required this.account});

  @override
  State<Home> createState() => _HomeState(this.account);
}

class _HomeState extends State<Home> {
  appwriteClient.Account account;
  _HomeState(this.account);

  late appwriteServer.Account accountServer;
  late appwriteServer.Databases databasesServer;
  late appwriteServer.Users usersServer;
  late appwriteServer.Client serverClient;

  User? loggedInUser;
  bool isLoading = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeServerClient();
    emailController.text = "sairish2001@gmail.com";
    passwordController.text = "12345678";
    checkAuth();
  }

  void initializeServerClient() {
    serverClient = appwriteServer.Client()
        .setEndpoint(Constants.ENDPOINT)
        .setProject(Constants.PROJECT_ID)
        .setKey(Constants.API_KEY)
        .setSelfSigned(status: true); // For self-signed certificates, only use for development

    accountServer = appwriteServer.Account(serverClient);
    databasesServer = appwriteServer.Databases(serverClient);
    usersServer = appwriteServer.Users(serverClient);
  }

  void navigateToMyNotes() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Notes(
              account: account,
              databases: databasesServer,
              users: usersServer,
            )));
  }

  Future<void> checkAuth() async {
    try {
      final user = await account.get();
      setState(() {
        loggedInUser = user;
      });
      navigateToMyNotes();
    } catch (e) {
      setState(() {
        loggedInUser = null;
        isLoading = false;
      });
    }
  }

  Future<void> login(String email, String password) async {
    setState(() {
      isLoading = true;
    });
    try {
      await account.createEmailSession(email: email, password: password);
      setState(() {
        isLoading = false;
      });
      navigateToMyNotes();
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> register(String email, String password, String name) async {
    setState(() {
      isLoading = true;
    });
    try {
      await usersServer.create(
          userId: appwriteServer.ID.unique(),
          email: email,
          password: password,
          name: name);
      await login(email, password);
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Appwrite test")),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(loggedInUser != null
                      ? 'Logged in as ${loggedInUser!.name}'
                      : 'Not logged in'),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      login(emailController.text, passwordController.text);
                    },
                    child: Text('Login'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      register(emailController.text, passwordController.text,
                          nameController.text);
                    },
                    child: Text('Register'),
                  ),
                ],
              ));
  }
}
