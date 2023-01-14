import 'dart:convert';
import 'package:flutter/foundation.dart';
import "package:http/http.dart" as http;
import 'package:libra/models/network_exception.dart';

enum Shelf { none, haveRead, wantToRead }

class MyBook {
  final String author;
  final String iSBN;
  final String title;
  final String imgUrl;
  final int rank;
  final String description;
  final String amazonUrl;
  Shelf shelf;
  MyBook(this.iSBN, this.title, this.imgUrl, this.rank, this.description,
      this.amazonUrl, this.author,
      {this.shelf = Shelf.none});
}

class Books with ChangeNotifier {
  // ignore: prefer_final_fields
  Map<String, List<MyBook>> _items;
  String userId;
  String token;
  Map<String, List<MyBook>> userShelves = {"wantToRead": [], "haveRead": []};
  Map<String, List<MyBook>> get getUserShelves {
    return {...userShelves};
  }

  var _done = false;

  final List<String> _lists = [
    "Young Adult",
    "Business Books",
    "Education",
    "Humor",
    "Hardcover Fiction",
    "Hardcover Nonfiction",
    "Audio Fiction",
    "Audio Nonfiction",
    "Culture",
  ];
  Books(this._items, this.userId, this.token);
  Map<String, List<MyBook>> get items {
    return {..._items};
  }

  List<String> get lists {
    return [..._lists];
  }

  Future<void> fetchUserShelves() async {
    final url = Uri.parse(
        "https://libra-366812-default-rtdb.firebaseio.com/$userId/shelves.json?auth=$token");
    try {
      final shelves = await http.get(url);
      final userShelvesMap = json.decode(shelves.body) as Map<String, dynamic>;
      if (userShelvesMap == null) {
        if (userShelvesMap == null) {
          userShelves = {"wantToRead": [], "haveRead": []};
          notifyListeners();
          return;
        }
      }
      userShelvesMap.forEach((key, value) {
        List<MyBook> list = [];
        (value as Map<String, dynamic>).forEach((key1, value1) {
          list.add(MyBook(
              key1,
              value1['title'],
              value1['imgUrl'],
              value1['rank'],
              value1['description'],
              value1['amazonUrl'],
              value1['author'],
              shelf: key == "wantToRead" ? Shelf.wantToRead : Shelf.haveRead));
        });
        userShelves[key] = list;
      });
      notifyListeners();
    } catch (error) {
      throw NetworkException(
          message: "Something went wrong at fetchUserShelves");
    }
  }

  Future<void> fetchAndSetCategoryBooks(String listName) async {
    try {
      if (!_done) {
        fetchUserShelves();
        _done = !_done;
      }
      Uri uri = Uri.parse(
          "https://api.nytimes.com/svc/books/v3/lists/current/$listName.json?api-key=bN980dl0Z9QqZoDfFL2KXLtYY8pvurLF");
      final books = await http.get(uri);

      Map<String, dynamic> decodedBooks = json.decode(books.body);
      if (decodedBooks != null && decodedBooks['results'] != null) {
        _items.addAll({
          listName:
              (decodedBooks['results']['books'] as List<dynamic>).map((e) {
            var shelf = Shelf.none;
            if (userShelves['wantToRead']
                .any((val) => e['primary_isbn13'] == val.iSBN)) {
              shelf = Shelf.wantToRead;
            } else if (userShelves['haveRead']
                .any((val) => e['primary_isbn13'] == val.iSBN)) {
              shelf = Shelf.haveRead;
            }
            return MyBook(
              e['primary_isbn13'],
              e['title'],
              e['book_image'] ??
                  'https://bookstoreromanceday.org/wp-content/uploads/2020/08/book-cover-placeholder.png',
              e['rank'],
              e['description'],
              e['amazon_product_url'],
              e['author'],
              shelf: shelf,
            );
          }).toList()
        });
      }
      notifyListeners();
    } catch (error) {
      throw NetworkException(
          message: "Something went wrong at fetchAndSetCategoryBooks");
    }
  }

  Future<void> addToShelf(MyBook book, Shelf shelf) async {
    if (book.shelf == shelf) return;
    try {
      if (shelf == Shelf.none) {
        final urld = Uri.parse(
            "https://libra-366812-default-rtdb.firebaseio.com/$userId/shelves/${book.shelf.name}/${book.iSBN}.json?auth=$token");
        await http.delete(urld);
        fetchUserShelves();
        notifyListeners();
        return;
      }
      if (book.shelf != Shelf.none) {
        final urld = Uri.parse(
            "https://libra-366812-default-rtdb.firebaseio.com/$userId/shelves/${book.shelf.name}/${book.iSBN}.json?auth=$token");
        await http.delete(urld);
      }
      final url = Uri.parse(
          "https://libra-366812-default-rtdb.firebaseio.com/$userId/shelves/${shelf.name}/${book.iSBN}.json?auth=$token");
      await http.put(url,
          body: json.encode({
            'title': book.title,
            'imgUrl': book.imgUrl,
            'rank': book.rank,
            'description': book.description,
            'amazonUrl': book.amazonUrl,
            'author': book.author,
          }));
      book.shelf = shelf;
      fetchUserShelves();
      notifyListeners();
    } catch (error) {
      throw NetworkException(message: "Something went wrong while adding to shef");
    }
  }
}
