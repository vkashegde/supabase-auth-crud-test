import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:suppa_fluttr/pages/home_page.dart';
import 'package:suppa_fluttr/pages/start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Load Env
  await dotenv.load();
  String supabase_url = dotenv.env['SUPABASE_URL'] ?? '';
  String supabase_key = dotenv.env['SUPABASE_KEY'] ?? '';
  await Supabase.initialize(url: supabase_url, anonKey: supabase_key);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  User? _user;

  @override
  void initState() {
    super.initState();
    _getAuth();
  }

  Future<void> _getAuth() async {
    setState(() {
      _user = supabase.auth.currentUser;
    });

    supabase.auth.onAuthStateChange.listen((event) {
      setState(() {
        _user = event.session?.user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ? StartPage() : HomePage();
  }
}
