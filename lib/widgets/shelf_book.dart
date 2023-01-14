import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Screens/book_overview.dart';
import '../providers/books_provider.dart';

class ShelfBook extends StatefulWidget {
  const ShelfBook({Key key, this.e}) : super(key: key);
  final MyBook e;
  @override
  State<ShelfBook> createState() => _UserShelfState();
}

class _UserShelfState extends State<ShelfBook> {
  var _deleting = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Container(
            height: 200,
            margin: const EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(BookOverview.route, arguments: widget.e);
              },
              child: GridTile(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(widget.e.imgUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    widget.e.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "by ${widget.e.author}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.e.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _deleting?const Center(child: CircularProgressIndicator(color: Colors.white,),):IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _deleting = true;
                          });
                          Provider.of<Books>(context, listen: false)
                              .addToShelf(widget.e, Shelf.none);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
