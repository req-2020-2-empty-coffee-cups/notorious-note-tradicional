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
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/database.dart';
import 'task_editor.dart';

class TaskPage extends StatefulWidget {
  final Database database;

  const TaskPage({Key key, this.database}) : super(key: key);

  static Future<void> show(BuildContext context, {Database database}) async {
    database = (database == null)
        ? Provider.of<Database>(context, listen: false)
        : database;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskPage(database: database),
        fullscreenDialog: true,
      ),
    );
  }
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildContents(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await TaskEditor.show(context);
          setState(() {});
        },
        tooltip: "New task",
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    return FutureBuilder<List<TaskModel>>(
      future: widget.database.listTasks(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final List<TaskModel> items = snapshot.data;
          if (items.isNotEmpty) {
            return ListView.separated(
                itemBuilder: (context, index) => Card(
                    child: InkWell(
                      splashColor: Colors.grey,
                      onTap: () => print("Task ${items[index].id} selected"),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              items[index].content,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),

                          ),
                          Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        await widget.database
                                            .deleteTask(items[index].id);
                                        setState(() {});
                                      }),
                                  IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () async {
                                        await TaskEditor.show(context,
                                            taskModel: items[index]);
                                        setState(() {});
                                      }),
                                  Icon(items[index].done == 1 ? Icons.done: Icons.close, color: items[index].done == 1? Colors.green:Colors.red)
                                ],
                              ),

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
                children: <Widget>[Text("No tasks"), Text("Please add a task")],
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
