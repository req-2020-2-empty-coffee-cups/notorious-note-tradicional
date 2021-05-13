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

import '../common/alert_dialogue.dart';
import '../services/database.dart';

class TagEditor extends StatefulWidget {
  final Database database;
  final TagModel tagModel;

  const TagEditor({Key key, this.database, this.tagModel}) : super(key: key);

  static Future<void> show(BuildContext context,
      {Database database, TagModel tagModel}) async {
    database = (database == null)
        ? Provider.of<Database>(context, listen: false)
        : database;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TagEditor(database: database, tagModel: tagModel),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _TagEditorState createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool validForm() => _name.isNotEmpty;

  String _name = "";

  // If note is null, we are creating a new one
  @override
  void initState() {
    super.initState();
    if (widget.tagModel != null) {
      _name = widget.tagModel.name;
    }
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        if (widget.tagModel == null) {
          final TagModel tag = TagModel(name: _name);
          await widget.database.createTag(tag);
        } else {
          final Map<String, dynamic> updatedMap = widget.tagModel.toMap();
          updatedMap["name"] = _name;

          await widget.database.updateTag(TagModel.fromMap(updatedMap));
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
        title: Text(widget.tagModel == null ? "New tag" : "Edit tag"),
        actions: <Widget>[
          TextButton(
              onPressed: _submit,
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ))
        ],
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
    return [
      TextFormField(
        decoration: InputDecoration(labelText: "Tag name"),
        initialValue: _name,
        validator: (value) {
          _name = value;
          return validForm() ? null : "Name can't be empty";
        },
        autovalidateMode: AutovalidateMode.always,
        onSaved: (value) => _name = value,
      ),
    ];
  }
}
