import 'package:flutter/material.dart';
import 'package:notorious_note/pages/notes_page.dart';
import 'package:notorious_note/pages/tags_page.dart';
import 'package:notorious_note/pages/test_page.dart';
import 'package:notorious_note/services/database.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BottomNavigatorPageItem> _pageArray = <BottomNavigatorPageItem>[];
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    _buildPageList(context);
    print("Size of list is ${_pageArray.length}");
    return Scaffold(
      appBar: _pageArray[_pageIndex].pageAppBar,
      body: Builder(
        builder: (_) {
          return _pageArray[_pageIndex].pageObject;
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _pageArray.map((item) => item.pageBarItem).toList(),
        currentIndex: _pageIndex,
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }

  void _buildPageList(BuildContext context) {
    _pageArray = [
      BottomNavigatorPageItem(
          pageObject: NotesPage(
              database: Provider.of<Database>(context, listen: false)),
          pageAppBar: AppBar(
            title: Text("Notes"),
          ),
          pageBarItem:
              BottomNavigationBarItem(icon: Icon(Icons.note), label: "Notes")),
      BottomNavigatorPageItem(
          pageObject: TagsPage(
            database: Provider.of<Database>(context, listen: false),
          ),
          pageAppBar: AppBar(title: Text("Tags")),
          pageBarItem: BottomNavigationBarItem(
          icon: Icon(Icons.tag), label: "Tags")),
    ];
  }
}

class BottomNavigatorPageItem {
  final Widget pageObject;
  final AppBar pageAppBar;
  final BottomNavigationBarItem pageBarItem;

  BottomNavigatorPageItem(
      {@required this.pageObject,
      @required this.pageAppBar,
      @required this.pageBarItem})
      : assert(pageObject != null),
        assert(pageAppBar != null),
        assert(pageBarItem != null);
}
