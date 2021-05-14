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

import '../models/note_model.dart';
import '../models/tag_model.dart';
import '../models/task_model.dart';

abstract class Database {
  Future<int> init();

  Future<int> createNote(NoteModel noteModel);
  Future<NoteModel> readNote(int id);
  Future<void> updateNote(NoteModel noteModel);
  Future<void> deleteNote(int id);

  Future<List<NoteModel>> listNotes();
  Future<List<NoteModel>> listArchivedNotes();

  Future<int> createTag(TagModel tagModel);
  Future<TagModel> readTag(int id);
  Future<void> updateTag(TagModel tagModel);
  Future<void> deleteTag(int id);

  Future<List<TagModel>> listTags();

  Future<void> tieTagToNote(int noteId, int tagId);
  Future<void> untieTagFromNote(int noteId);
  Future<TagModel> getTagFromNote(int noteId);
  Future<void> createTask(TaskModel taskModel);
  Future<TaskModel> readTask(int id);
  Future<void> updateTask(TaskModel taskModel);
  Future<void> deleteTask(int id);
  Future<List<TaskModel>> listTasks();
}
