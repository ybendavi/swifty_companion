import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'views/second_view.dart'; //

void handleResponse(http.Response response) {
  if (response.statusCode == 200) return;

  switch (response.statusCode) {
    case 201:
      throw Exception('Error 201 : User not found.');
    case 400:
      throw Exception('Errror 400 : Bad request.');
    case 401:
      throw Exception('Error 401 : Unauthorized.');
    case 403:
      throw Exception('Error 403 : Forbidden.');
    case 404:
      throw Exception('Error 404 : Page or resource is not found.');
    case 422:
      throw Exception('Error 422 : Unprocessable entity.');
    case 500:
      throw Exception('Error 500 : We have a problem with our server. Please try again later.');
    default:
      throw Exception('Error : Unknown error.');
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); 
  runApp(const MyApp());
}

Future<dynamic> searchLogin(String login, BuildContext context) async {
  var secret = dotenv.env['CLIENT_SECRET'];
  var endpoint = dotenv.env['ENDPOINT'];
  var search = '?login=$login'.trim();
  endpoint = endpoint! + search;

  try {
    print('requesting $endpoint');
    final response = await http.get(Uri.parse(endpoint), headers: {
      'Content-Type': 'application/json',
      'X-API-KEY': secret!,
    }).timeout(const Duration(seconds: 5));

    handleResponse(response);
    final jsonBody = json.decode(response.body);
    final userData = {
      "login": jsonBody['user']['login'],
      "email": jsonBody['user']['email'],
      "mobile": jsonBody['user']['phone'],
      "wallet": jsonBody['user']['wallet'],
      "image": jsonBody['user']['image_url'],
      "skills": jsonBody['skills'],
      "projects": jsonBody['projects'],
    };
    for (var project in userData['projects']) {
      print(project['name']);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailView(userData: userData),
      ),
    );

    return null; // Pas d'Error
  }
   catch (e) {
    if (e.toString().startsWith('TimeoutException')) {
      return 'Server did not respond. Please try again.';
    }
    final regex = RegExp(r'OS Error: ([^,]+)');
    final match = regex.firstMatch(e.toString());
    final errorMsg = match != null ? match.group(1) : e.toString().split(':').last.trim();
    print('Error réseau : $e');
    print('satus code ${e.hashCode}');
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
  bool isLoading = false;

  Future<void> handleSearch() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    final result = await searchLogin(controller.text, context);
    setState(() {
    isLoading = false;
    errorMessage = result is String ? result : '';
    });
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
            if (isLoading == false)
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
            if (isLoading)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

