// SPDX-License-Identifier: AGPL-3.0-or-later
/*
    Copyright (C) 2021  Equipe EmptyCoffeeCups

    This file is part of NotoriousNote.

    NotoriousNote is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    NotoriousNote is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with NotoriousNote.  If not, see <https://www.gnu.org/licenses/>.
*/

import 'package:flutter/material.dart';
import 'package:notorious_note/models/tag_model.dart';
import 'package:provider/provider.dart';

import '../services/database.dart';
import 'tag_editor.dart';

class TagsPage extends StatefulWidget {
  final Database database;

  const TagsPage({Key key, this.database}) : super(key: key);

  static Future<void> show(BuildContext context, {Database database}) async {
    database = (database == null)
        ? Provider.of<Database>(context, listen: false)
        : database;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TagsPage(database: database),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildContents(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await TagEditor.show(context);
          setState(() {});
        },
        tooltip: "New tag",
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    return FutureBuilder<List<TagModel>>(
      future: widget.database.listTags(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final List<TagModel> items = snapshot.data;
          if (items.isNotEmpty) {
            return ListView.separated(
                itemBuilder: (context, index) => Card(
                    child: InkWell(
                      splashColor: Colors.grey,
                      onTap: () => print("Tag ${items[index].id} selected"),
                      child: Column(
                        children: <Widget>[
                          Text(
                            items[index].name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await widget.database
                                        .deleteTag(items[index].id);
                                    setState(() {});
                                  }),
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    await TagEditor.show(context,
                                        tagModel: items[index]);
                                    setState(() {});
                                  })
                            ],
                          )
                        ],
                      ),
                    )),
                separatorBuilder: (context, index) => Divider(
                  height: 0.5,
                ),
                itemCount: items.length);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text("No tags"), Text("Please add a tag")],
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
