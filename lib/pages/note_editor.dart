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
import '../models/note_model.dart';
import '../services/database.dart';

class NoteEditor extends StatefulWidget {
  final Database database;
  final NoteModel noteModel;

  const NoteEditor({Key key, this.database, this.noteModel}) : super(key: key);

  static Future<void> show(BuildContext context,
      {Database database, NoteModel noteModel}) async {
    database = (database == null)
        ? Provider.of<Database>(context, listen: false)
        : database;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            NoteEditor(database: database, noteModel: noteModel),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool validForm() => _title.isNotEmpty || _content.isNotEmpty;

  String _title = "";
  String _content = "";
  final int _invalidTagId = -1;
  int _selectedTagId;
  int _archived = 0;
  bool _archivedCheckbox = false;

  // If note is null, we are creating a new one
  @override
  void initState() {
    super.initState();
    _selectedTagId = _invalidTagId;
    if (widget.noteModel != null) {
      _title = widget.noteModel.title;
      _content = widget.noteModel.content;
      _archived = widget.noteModel.archived;
      _archivedCheckbox = _archived == 1 ? true : false;
      _selectedTagId = widget.noteModel.tag == null
          ? _invalidTagId
          : widget.noteModel.tag.id;
    }
  }

  Future<void> _updateNoteTag(int noteId) async {
    if (_selectedTagId != _invalidTagId) {
      print("Try to tie tag $_selectedTagId to note $noteId");
      await widget.database.tieTagToNote(noteId, _selectedTagId);
    } else if (_selectedTagId != null) {
      print("Try to untie tag $_selectedTagId from note $noteId");
      await widget.database.untieTagFromNote(noteId);
    }
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        if (widget.noteModel == null) {
          final NoteModel note = NoteModel(title: _title, content: _content, archived: _archivedCheckbox ? 1 : 0);
          int noteId = await widget.database.createNote(note);
          await _updateNoteTag(noteId);
        } else {
          NoteModel updatedNote = widget.noteModel.copyWith(archived: _archivedCheckbox ? 1 : 0);
          final Map<String, dynamic> updatedMap = updatedNote.toMap();
          updatedMap["title"] = _title;
          updatedMap["content"] = _content;

          await widget.database.updateNote(NoteModel.fromMap(updatedMap));
          await _updateNoteTag(updatedNote.id);
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
        title: Text(widget.noteModel == null ? "New note" : "Edit note"),
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
      Row(children: [
        _buildTagsDropdown(),
        Container(
          child: Row(children: [
            Checkbox(
                value: _archivedCheckbox,
                onChanged: (bool newValue) {
                  setState(() {
                    _archivedCheckbox = newValue;
                  });
                }),
            Text("Archived"),
          ]),
        )
      ]),
      TextFormField(
        decoration: InputDecoration(labelText: "Note title"),
        initialValue: _title,
        validator: (value) {
          _title = value;
          return validForm() ? null : "Title and content can't be both empty";
        },
        autovalidateMode: AutovalidateMode.always,
        onSaved: (value) => _title = value,
      ),

      Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
          decoration: InputDecoration(labelText: "Note content"),
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

  Widget _buildTagsDropdown() {
    return FutureBuilder<List<TagModel>>(
        future: widget.database.listTags(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            final List<TagModel> items = snapshot.data;
            if (items.isNotEmpty) {
              List<DropdownMenuItem<int>> dropItems =
                  items.map<DropdownMenuItem<int>>((TagModel tag) {
                return DropdownMenuItem(
                  child: Text(tag.name),
                  value: tag.id,
                );
              }).toList();
              dropItems.insert(
                  0,
                  DropdownMenuItem(
                    child: Text("No tag"),
                    value: _invalidTagId,
                  ));
              return DropdownButton(
                  items: dropItems,
                  value: _selectedTagId,
                  onChanged: (int newSelectedValue) {
                    setState(() {
                      _selectedTagId = newSelectedValue;
                    });
                  });
            } else {
              return Text("No tags");
            }
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
