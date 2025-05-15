import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'views/second_view.dart'; //
Future main() async {
  runApp(const MyApp());
}

Future<dynamic> searchLogin(String login, BuildContext context) async {
  await dotenv.load(fileName: ".env");
  var secret = dotenv.env['CLIENT_SECRET'];
  var endpoint = dotenv.env['ENDPOINT'];
  var search = '?login=$login'.trim();
  endpoint = endpoint! + search;

  try {
    print('requesting $endpoint');
    final response = await http.get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'X-API-KEY': secret!,
    }).timeout(const Duration(seconds: 3));

    print('status code ${response.statusCode}');

    final jsonBody = json.decode(response.body);
    if (response.statusCode != 200) {

      print('response body ${json.decode(response.body)}');
      return jsonBody['error'] ?? 'Une erreur est survenue.';
    }

    final userData = {
      "login": jsonBody['user']['login'],
      "email": jsonBody['user']['email'],
      "mobile": jsonBody['user']['phone'],
      "wallet": jsonBody['user']['wallet'],
      "image": jsonBody['user']['image_url'],
      "skills": jsonBody['skills'],
      "projects": jsonBody['projects'],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailView(userData: userData),
      ),
    );

    return null; // Pas d'erreur
  } catch (e) {
    final regex = RegExp(r'OS Error: ([^,]+)');
    final match = regex.firstMatch(e.toString());
    final errorMsg = match != null ? match.group(1) : e.toString();
    print('Erreur réseau : $e');
    return errorMsg;
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swifty Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 1, 9)),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController controller = TextEditingController();
  String errorMessage = '';

  Future<void> handleSearch() async {
    final result = await searchLogin(controller.text, context);
    if (result is String) {
      // Une erreur est survenue
      setState(() {
        errorMessage = result;
      });
    } else {
      setState(() {
        errorMessage = '';
      });
    }
  }
  @override
Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter a login',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: handleSearch,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: handleSearch,
                child: const Text('Search Login'),
              ),
            const SizedBox(height: 10),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

