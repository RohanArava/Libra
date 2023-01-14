import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './Screens/book_overview.dart';
import './Screens/signupscr.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';
import 'Screens/lists.dart';
import 'Screens/user_shelves.dart';
import 'providers/books_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(MyApp()),
  );
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Books>(
            create: (context) => Books({}, null, null),
            update: (context, value, previous) => Books(
                previous == null ? {} : previous.items ?? {},
                value.userId,
                value.token))
      ],
      child: Consumer<Auth>(
        builder: (context, value, _) => MaterialApp(
          home: value.isAuth
              ? Consumer<Books>(
                  builder: (context, value1, _) => const ListScreen())
              : FutureBuilder(
                  future: value.tryAutoLogin(),
                  builder: (context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const Scaffold()
                          : SignUpScr()),
          theme: ThemeData(
            primaryColorDark: Colors.black,
            primaryColorLight: const Color.fromARGB(255, 12, 12, 12),
            scaffoldBackgroundColor: const Color.fromARGB(255, 15, 15, 15),
            appBarTheme: const AppBarTheme(
                color: Color.fromARGB(255, 20, 22, 20),
                titleTextStyle: TextStyle(color: Colors.white)),
          ),
          routes: {
            ListScreen.route: (context) => const ListScreen(),
            BookOverview.route: (context) => const BookOverview(),
            UserShelves.route: (context) => const UserShelves(),
          },
        ),
      ),
    );
  }
}
