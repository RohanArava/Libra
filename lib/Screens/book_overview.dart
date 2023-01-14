import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/books_provider.dart';

class BookOverview extends StatefulWidget {
  const BookOverview({Key key}) : super(key: key);
  static String route = "BookOverview";
  @override
  State<BookOverview> createState() => _BookOverviewState();
}

class _BookOverviewState extends State<BookOverview> {
  @override
  Widget build(BuildContext context) {
    MyBook book = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
            title: Text(
          book.title,
          textScaleFactor: 1.5,
        )),
        body: Overview(
          book: book,
          link: true,
        ));
  }
}

class Overview extends StatelessWidget {
  const Overview({Key key, this.book, this.link = true}) : super(key: key);
  final MyBook book;
  final bool link;
  void visitAmazon(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Container(
            alignment: Alignment.center,
            width: size.width * 0.6,
            height: size.width * 0.9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(book.imgUrl, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(
          height: 30.0,
        ),
        Text(
          "New York Times Rank: ${book.rank}",
          style: const TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        if(link)const SizedBox(
          height: 30.0,
        ),
        if(link)Text(
          book.description,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          "by ${book.author}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        if (link)
          const SizedBox(
            height: 30.0,
          ),
        if (link)
          TextButton(
              onPressed: () {
                visitAmazon(book.amazonUrl);
              },
              child: const Text("See on amazon...")),
      ],
    ));
  }
}
