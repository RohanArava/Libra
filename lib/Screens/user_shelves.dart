import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/main_drawer.dart';
import '../providers/books_provider.dart';
import '../widgets/shelf_book.dart';

class UserShelves extends StatefulWidget {
  const UserShelves({Key key}) : super(key: key);
  static String route = "usrShelves";

  @override
  State<UserShelves> createState() => _UserShelvesState();
}

class _UserShelvesState extends State<UserShelves> {
  var _selected = 1;

  @override
  Widget build(BuildContext context) {
    final books = Provider.of<Books>(context).getUserShelves;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 20, 22, 20),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        selectedFontSize: 18.0,
        currentIndex: _selected,
        onTap: (value) {
          setState(() {
            _selected = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: "Want To Read",
            activeIcon: Icon(Icons.favorite),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.check),
              label: "Have Read",
              activeIcon: Icon(Icons.check_box)),
        ],
      ),
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text(
          "Shelves",
          textScaleFactor: 1.50,
        ),
      ),
      body: books[_selected == 0 ? "wantToRead" : "haveRead"].isEmpty
          ? const Center(
              child: Text(
                "No books added",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ...books[_selected == 0 ? "wantToRead" : "haveRead"]
                      .map((e) => ShelfBook(e: e, key: UniqueKey(),))
                ],
              ),
            ),
    );
  }
}
