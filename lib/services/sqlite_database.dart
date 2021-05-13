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

import 'package:notorious_note/models/task_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/note_model.dart';
import '../models/tag_model.dart';
import 'database.dart';

class SQLiteDatabase implements Database {
  static final Database instance = SQLiteDatabase._();

  sqflite.Database db;

  SQLiteDatabase._();

  @override
  Future<int> init() async {
    int result = -1;
    if (db == null) {
      db = await sqflite.openDatabase("database.db");
      await db.execute("PRAGMA foreign_keys = ON;");
      await db.execute("""
CREATE TABLE IF NOT EXISTS notes(
	id INTEGER PRIMARY KEY,
	title TEXT DEFAULT NULL,
	content TEXT DEFAULT NULL,
	creation TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
	archived INTEGER NOT NULL DEFAULT 0,
	CHECK(title IS NOT NULL OR content IS NOT NULL),
	CHECK(title != '' OR content != ''),
	CHECK(typeof(archived) = 'integer'));
""");
      await db.execute("""
CREATE TABLE IF NOT EXISTS tags(
	id INTEGER PRIMARY KEY,
	name TEXT DEFAULT NULL,
	CHECK(name IS NOT NULL AND name != ''));
""");
      await db.execute("""
CREATE TABLE IF NOT EXISTS note_tags(
	note_id INTEGER NOT NULL,
	tag_id INTEGER NOT NULL,
	PRIMARY KEY (note_id, tag_id),
	FOREIGN KEY (note_id) REFERENCES notes(id)
	ON DELETE CASCADE ON UPDATE NO ACTION,
	FOREIGN KEY (tag_id) REFERENCES tags(id)
	ON DELETE CASCADE ON UPDATE NO ACTION);
""");

      await db.execute("""
      CREATE TABLE IF NOT EXISTS tasks(
      id INTEGER PRIMARY KEY,
      content TEXT DEFAULT NULL,
      done INTEGER DEFAULT 0,
      creation TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      CHECK(typeof(done) = 'integer'),
      CHECK(content != ''),
      CHECK(content IS NOT NULL));
      """);

      result = 0;
      return result;
    }
    result = (db == null) ? -1 : 0;
    return result;
  }

  @override
  Future<void> createNote(NoteModel noteModel) async {
    Map<String, dynamic> noteMap = noteModel.toMap();
    noteMap.remove("id");
    noteMap.remove("creation");
    noteMap.remove("archived");
    print("try to insert $noteMap");
    await db.insert("notes", noteMap);
  }

  @override
  Future<NoteModel> readNote(int id) async {
    final List<Map<String, Object>> result =
        await db.query("notes", where: "id = ?", whereArgs: [id]);
    if (result.isEmpty)
      return null;
    else
      return NoteModel.fromMap(result[0]);
  }

  @override
  Future<void> updateNote(NoteModel noteModel) async {
    Map<String, dynamic> noteMap = noteModel.toMap();
    noteMap.remove("creation");
    print("try to insert $noteMap");
    await db
        .update("notes", noteMap, where: "id = ?", whereArgs: [noteModel.id]);
  }

  @override
  Future<void> deleteNote(int id) async {
    await db.delete("notes", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<void> deleteTag() {
    // TODO: implement deleteTag
    throw UnimplementedError();
  }

  @override
  Future<void> getTagsFromNote() {
    // TODO: implement getTagsFromNote
    throw UnimplementedError();
  }

  @override
  Future<void> createTag(TagModel tagModel) {
    // TODO: implement createTag
    throw UnimplementedError();
  }

  @override
  Future<List<NoteModel>> listNotes() async {
    List<Map<String, dynamic>> results =
        await db.rawQuery("SELECT * FROM notes");
    print("Notes $results");
    return results
        .map((Map<String, dynamic> map) => NoteModel.fromMap(map))
        .toList();
  }

  @override
  Future<List<TagModel>> listTags() {
    // TODO: implement listTags
    throw UnimplementedError();
  }

  @override
  Future<TagModel> readTag() {
    // TODO: implement readTag
    throw UnimplementedError();
  }

  @override
  Future<void> tieTagToNote() {
    // TODO: implement tieTagToNote
    throw UnimplementedError();
  }

  @override
  Future<void> updateTag() {
    // TODO: implement updateTag
    throw UnimplementedError();
  }



  @override
  Future<List<TaskModel>> listTasks() async {
    List<Map<String, dynamic>> results =
    await db.rawQuery("SELECT * FROM tasks");
    print("task $results");
    return results
        .map((Map<String, dynamic> map) => TaskModel.fromMap(map))
        .toList();
  }


  @override
  Future<TaskModel> readTask( int id) {
    // TODO: implement readTag
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(TaskModel taskModel) async {
    Map<String, dynamic> taskMap = taskModel.toMap();
    taskMap.remove("creation");
    print("try to insert $taskMap");
    await db
        .update("tasks", taskMap, where: "id = ?", whereArgs: [taskModel.id]);
  }

  @override
  Future<void> deleteTask(int id) async{
    await db.delete("tasks", where: "id = ?", whereArgs: [id]);
  }




  @override
  Future<void> createTask(TaskModel taskModel) async{
    Map<String, dynamic> taskMap = taskModel.toMap();
    taskMap.remove("id");
    taskMap.remove("creation");
    print("trey to insert $taskMap");
    await db.insert("tasks", taskMap);

  }
}

