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
import 'package:provider/provider.dart';

import '../common/alert_dialogue.dart';
import '../models/task_model.dart';
import '../services/database.dart';

class TaskEditor extends StatefulWidget {
  final Database database;
  final TaskModel taskModel;

  const TaskEditor({Key key, this.database, this.taskModel}) : super(key: key);

  static Future<void> show(BuildContext context,
      {Database database, TaskModel taskModel}) async {
    database = (database == null)
        ? Provider.of<Database>(context, listen: false)
        : database;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TaskEditor(database: database, taskModel: taskModel),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _TaskEditorState createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool validForm() => _content.isNotEmpty;
  bool _done = false;
  String _content = "";
  // If task is null, we are creating a new one
  @override
  void initState() {
    super.initState();
    if (widget.taskModel != null) {
      _done = widget.taskModel.done == 1;
      _content = widget.taskModel.content;
    }
  }
  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        if (widget.taskModel == null) {
          final TaskModel task =
              TaskModel(done: _done ? 1 : 0 , content: _content);
          await widget.database.createTask(task);
        } else {
          final Map<String, dynamic> updatedMap = widget.taskModel.toMap();
          updatedMap["done"] = _done ? 1 : 0;
          updatedMap["content"] = _content;

          await widget.database.updateTask(TaskModel.fromMap(updatedMap));
        }

        Navigator.of(context).pop();
      } catch (e) {
        print(e);
        CustomAlertDialogue(
          title: "Error",
          content: e.toString(),
          defaultActionText: "OK",
        ).show(context);
      }
    }
  }
  bool _validateAndSaveForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskModel == null ? "New task" : "Edit task"),
      ),
      body: _buildContents(),
    );
  }
  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }
  List<Widget> _buildFormChildren() {
    var checkbox;
    return [
      TextFormField(
        scrollPadding: const EdgeInsets.all(10.0),
        decoration: InputDecoration(
          labelText: "Task content",
        ),

        style: TextStyle(
          fontSize: 22,
        ),

        initialValue: _content,
        validator: (value) {
          _content = value;
          return validForm() ? null : "Title and content can't be both empty";
        },
        autovalidateMode: AutovalidateMode.always,
        onSaved: (value) => _content = value,
      ),
      Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Done",
                style: TextStyle(
                    fontSize: 20
                ),
              ),
              Checkbox(
                  value: _done,
                  onChanged: (value) {
                    setState(() {
                      _done = value;
                    });
                  })
            ],
          ),
      ),
      Padding(
          padding: const EdgeInsets.all(10.0),
      child: TextButton(
          onPressed: _submit,
          child: Text(
            "Save",
            style: TextStyle(
                color: Colors.blue,
                fontSize: 20
            ),
          ))
      )
    ];
  }
}
