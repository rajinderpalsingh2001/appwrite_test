import 'package:appwrite_test/constants/constants.dart';
import 'package:appwrite_test/home.dart';
import 'package:dart_appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart' as appwriteClient;
import 'package:dart_appwrite/dart_appwrite.dart' as appwriteServer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //server

  appwriteClient.Client clientClient = appwriteClient.Client();
  clientClient
      // .setEndpoint('https://cloud.appwrite.io/v1')
      .setEndpoint(Constants.ENDPOINT)
      // .setProject('651c61f620a661ac4c23')
      .setProject(Constants.PROJECT_ID)
      .setSelfSigned(status: true);
  appwriteClient.Account account = appwriteClient.Account(clientClient);

  runApp(MyApp(account: account));
}

class MyApp extends StatelessWidget {
  appwriteClient.Account account;
  MyApp({required this.account});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Appwrite test",
      home: Home(
        account: account,
      ),
    );
  }
}
