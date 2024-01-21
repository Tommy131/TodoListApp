/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2024-01-19 00:57:02
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2024-01-20 01:02:39
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// models/task.dart

import 'package:todo_list_app/models/category.dart';

class Task {
  String title;
  Category category;
  DateTime creationDate;
  bool isCompleted;
  bool isImportant;

  Task({
    required this.title,
    required this.category,
    required this.creationDate,
    this.isCompleted = false,
    this.isImportant = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      category: Category.fromJson(json),
      creationDate: DateTime.parse(json['creationDate']),
      isCompleted: json['isCompleted'],
      isImportant: json['isImportant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category.name,
      'creationDate': creationDate.toIso8601String(),
      'isCompleted': isCompleted,
      'isImportant': isImportant,
    };
  }

  void updateTaskDetails({
    String? title,
    bool? isCompleted,
    bool? isImportant,
  }) {
    this.title = title ?? this.title;
    this.isCompleted = isCompleted ?? this.isCompleted;
    this.isImportant = isImportant ?? this.isImportant;
  }
}