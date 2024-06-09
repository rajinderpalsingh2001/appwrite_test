import 'package:appwrite/appwrite.dart' as appwriteClient;
import 'package:appwrite_test/constants/constants.dart';
// import 'package:appwrite/models.dart';
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

  User? loggedInUser;
  bool isLoading = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController.text = "sairish2001@gmail.com";
    passwordController.text = "12345678";
    checkAuth();
  }

  navigateToMyNotes(
      {required appwriteServer.Databases databases,
      required appwriteServer.Users users}) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Notes(
              account: account,
              databases: databases,
              users: users,
            )));
  }

  checkAuth() async {
    try {
      final user = await widget.account.get();
      loggedInUser = user;

      Map<String, dynamic> userAndDatabase = await initializeServerClient();

      navigateToMyNotes(
          databases: userAndDatabase['database'],
          users: userAndDatabase['user']);
    } catch (e) {
      setState(() {
        loggedInUser = null;
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> initializeServerClient() async {
    Jwt jwt = await widget.account.createJWT();

    appwriteServer.Client clientServer = appwriteServer.Client();
    clientServer
        .setEndpoint(Constants.ENDPOINT)
        .setProject(Constants.PROJECT_ID)
        .setKey(Constants.API_KEY)
        .setJWT(jwt.jwt)
        .setSelfSigned(
            status:
                true); // For self signed certificates, only use for development
    final databases = appwriteServer.Databases(clientServer);
    appwriteServer.Users users = appwriteServer.Users(clientServer);

    return {'database': databases, 'user': users};
  }

  Future<void> login(String email, String password) async {
    setState(() {
      isLoading = true;
    });
    try {
      print("called 1");
      await widget.account.createEmailSession(email: email, password: password);
      print("called 2");
      // print(await widget.account.get());
      // final user = await widget.account.get();
      print("called 3");
      // print(user);
      setState(() {
        // loggedInUser = user;
        isLoading = false;
      });
      Map<String, dynamic> userAndDatabase = await initializeServerClient();

      navigateToMyNotes(
          databases: userAndDatabase['database'],
          users: userAndDatabase['user']);
    } catch (e) {
      print(e);
      print("called");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> register(String email, String password, String name) async {
    setState(() {
      isLoading = true;
    });
    await widget.account.create(
        userId: appwriteServer.ID.unique(),
        email: email,
        password: password,
        name: name);
    // await widget.account.create(
    //     userId: ID.unique(), email: email, password: password, name: name);
    await login(email, password);
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
