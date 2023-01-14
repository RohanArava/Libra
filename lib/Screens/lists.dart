import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/books_provider.dart';
import '../widgets/main_drawer.dart';
import 'book_overview.dart';
import 'package:share/share.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key key}) : super(key: key);
  static String route = 'listscr';
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  var _done = false;
  List<Future<void>> fetch = [];
  List<String> lists;
  var _hasNet = true;
  Future<void> _hasNetFuture;
  OverlayEntry alertd;
  @override
  void initState() {
    _hasNetFuture = hasNetwork();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_done && _hasNet) {
      lists = Provider.of<Books>(context).lists;
      try {
        for (var element in lists) {
          fetch.add(Provider.of<Books>(context, listen: false)
              .fetchAndSetCategoryBooks(element));
        }
        _done = !_done;
      } catch (error) {
        //
      }
    }
    super.didChangeDependencies();
  }

  Future<void> share(String title, String link) async {
    Share.share(
      link,
      subject: title,
    );
  }

  Future<void> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      _hasNet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      return;
    } on SocketException catch (_) {
      _hasNet = false;
      return;
    }
  }

  Widget alert(MyBook book) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          elevation: 20,
          backgroundColor: Colors.black,
          content: Overview(book: book, link: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<Books>(context).items;
    void addToShelf(MyBook book) {
      var radio = book.shelf;
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              backgroundColor: const Color.fromARGB(250, 15, 15, 15),
              titleTextStyle: const TextStyle(color: Colors.white),
              title: const Text(
                "Add to Shelf",
                textAlign: TextAlign.center,
              ),
              actions: [
                Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        radio == Shelf.none
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: Colors.white,
                      ),
                      title: const Text("None",
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() {
                          radio = Shelf.none;
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        radio == Shelf.haveRead
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: Colors.white,
                      ),
                      title: const Text("Have Read",
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() {
                          radio = Shelf.haveRead;
                        });
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        radio == Shelf.wantToRead
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: Colors.white,
                      ),
                      title: const Text("Want To Read",
                          style: TextStyle(color: Colors.white)),
                      onTap: () {
                        setState(() {
                          radio = Shelf.wantToRead;
                        });
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Provider.of<Books>(context, listen: false)
                        .addToShelf(book, radio);
                  },
                  child: const Text(
                    "Done ",
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          );
        },
      );
    }

    return FutureBuilder(
      future: _hasNetFuture,
      builder: (context, snapshot) => Scaffold(
        drawer: const MainDrawer(),
        drawerEnableOpenDragGesture: true,
        drawerEdgeDragWidth: 80.0,
        appBar: AppBar(
          title: const Text(
            "Libra ",
            textScaleFactor: 2,
          ),
        ),
        body: !_hasNet
            ? Center(
                child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(ListScreen.route);
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ))
            : ListView.builder(
                itemCount: lists.length,
                itemExtent: 280.0,
                itemBuilder: (context, index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("  ${lists[index]}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20)),
                    SizedBox(
                      height: 250,
                      width: double.maxFinite,
                      child: FutureBuilder(
                        future: fetch[index],
                        builder: (context, snapshot) => snapshot
                                    .connectionState !=
                                ConnectionState.done
                            ? Column()
                            : items[lists[index]] == null
                                ? Column()
                                : ListView.builder(
                                    itemExtent: 150,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: items[lists[index]].length,
                                    itemBuilder: (context, index2) {
                                      return Container(
                                        margin: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 8,
                                              child: GestureDetector(
                                                onLongPressEnd: (_) {
                                                  alertd?.remove();
                                                  alertd = null;
                                                },
                                                onLongPress: () {
                                                  if (alertd != null) {
                                                    alertd.remove();
                                                    alertd = null;
                                                  }
                                                  alertd = OverlayEntry(
                                                      builder: (context) =>
                                                          alert(items[
                                                                  lists[index]]
                                                              [index2]));
                                                  Overlay.of(context)
                                                      .insert(alertd);
                                                },
                                                onTap: () {
                                                  if (alertd != null) {
                                                    alertd.remove();
                                                    alertd = null;
                                                  }
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          BookOverview.route,
                                                          arguments: items[
                                                                  lists[index]]
                                                              [index2]);
                                                },
                                                child: GridTile(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                        items[lists[index]]
                                                                [index2]
                                                            .imgUrl,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      if (alertd != null) {
                                                        alertd.remove();
                                                        alertd = null;
                                                      }
                                                      share(
                                                          items[lists[index]]
                                                                  [index2]
                                                              .title,
                                                          items[lists[index]]
                                                                  [index2]
                                                              .amazonUrl);
                                                    },
                                                    icon: const Icon(
                                                      Icons.share,
                                                      color: Colors.white,
                                                    )),
                                                IconButton(
                                                    onPressed: () {
                                                      if (alertd != null) {
                                                        alertd.remove();
                                                        alertd = null;
                                                      }
                                                      addToShelf(
                                                          items[lists[index]]
                                                              [index2]);
                                                    },
                                                    icon: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                    ))
                                              ],
                                            )),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
