import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../Screens/lists.dart';
import '../Screens/user_shelves.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 20, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 80,
          ),
          SizedBox(height:60.0,child: Image.asset('assets/inApp.png')),
          const SizedBox(
            height: 30.0,
          ),
          const Text(
            "Libra",
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
          const Divider(
            indent: 20,
            endIndent: 20,
            color: Color.fromARGB(255, 62, 62, 62),
          ),
          GestureDetector(
            onTap: () {
                  Navigator.of(context).pushReplacementNamed(ListScreen.route);
                },
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text("All Titles"),
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.white)), onPressed: () {
                  Navigator.of(context).pushReplacementNamed(ListScreen.route);
                },
              ),
            ),
          ),
          GestureDetector(
            onTap:  () {
              Navigator.of(context).pushReplacementNamed(UserShelves.route);
            },
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.collections_bookmark),
                label: const Text("My Shelves"),
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.white)), onPressed: () {
              Navigator.of(context).pushReplacementNamed(UserShelves.route);
            },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/');
                  Provider.of<Auth>(context, listen: false).logout();
                }
                ,
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Log Out"),
                style: const ButtonStyle(
                    foregroundColor: MaterialStatePropertyAll(Colors.white)), onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/');
                  Provider.of<Auth>(context, listen: false).logout();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
