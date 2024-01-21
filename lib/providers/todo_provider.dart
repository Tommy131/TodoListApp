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
 * @LastEditTime : 2024-01-20 22:28:15
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// providers/todo_provider.dart
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:todo_list_app/main.dart';

import 'package:todo_list_app/models/task.dart';
import 'package:todo_list_app/models/category.dart';
import 'package:todo_list_app/providers/json_driver.dart';

class TodoProvider extends ChangeNotifier {
  late JsonDriver _todoList;
  late String selectedCategory = Application.defaultCategory.name;

  // ignore: prefer_final_fields
  Map<String, Category> _categories = {};
  // ignore: prefer_final_fields
  List<Task> _tasks = [];

  /// Load categories before tasks during initialization
  TodoProvider() {
    Application.debug('创建默认分类中...');
    _categories[Application.defaultCategory.name] = Application.defaultCategory;
    Application.debug('默认分类创建完成.');
    _loadTodoList();
  }

  List<Task> get filteredTasks {
    return _tasks
        .where((task) => task.category.name == selectedCategory)
        .toList();
  }

  List<Task> get tasks {
    return _tasks;
  }

  Map<String, Category> get categories {
    return _categories;
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveData();
    notifyListeners();
  }

  void toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    _saveData();
    notifyListeners();
  }

  void toggleTaskImportance(Task task) {
    task.isImportant = !task.isImportant;
    _saveData();
    notifyListeners();
  }

  void updateTaskDetails(Task task, {String? title}) {
    task.updateTaskDetails(title: title);
    _saveData();
    notifyListeners();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    _saveData();
    notifyListeners();
  }

  void changeCategory(String newCategory) {
    selectedCategory = newCategory;
    notifyListeners();
    Application.debug('当前分类: $selectedCategory');
  }

  void addCategory(Category category) {
    _categories[category.name] = category;
    _saveData();
    notifyListeners();
  }

  void deleteCategoryWithName(String categoryName) {
    categoryName = categoryName;
    if (categoryName != Application.defaultCategory.name &&
        _categories.containsKey(categoryName)) {
      // 删除分类
      _categories.remove(categoryName);

      // 开始循环修改待办事项分类
      int pointer = 0;
      for (Task task in _tasks) {
        if (task.category.name == categoryName) {
          task.category = Application.defaultCategory;
          _tasks[pointer] = task;
        }
        pointer++;
      }

      // 修复默认选中分类
      if (selectedCategory == categoryName) {
        changeCategory(Application.defaultCategory.name);
      }

      // 保存数据并通知监听器
      _saveData();

      notifyListeners();
    }
  }

  void deleteCategory(Category category) {
    deleteCategoryWithName(category.name);
  }

  void _loadTodoList() {
    String savePath = '${Directory.current.path}/userData';

    try {
      Application.debug('加载分类中...');
      Map<String, dynamic> list = Application.settings['categories']['list'];

      _categories.addAll(Map.fromEntries(
        list.entries
            .where(
              (entry) => entry.key != Application.defaultCategory.name,
            )
            .map(
              (entry) => MapEntry(entry.key, Category.fromJson(entry.value)),
            ),
      ));
      Application.debug('分类加载完成.');

      Application.debug('加载待办清单中...');
      _todoList = JsonDriver('todoList', savePath: savePath);
      for (var category in _todoList.data.entries) {
        for (int i = 0; i < category.value.length; i++) {
          dynamic taskData = category.value[i];
          _tasks.add(Task(
              title: taskData['title'],
              category: _categories[taskData['category']]!,
              creationDate: DateTime.parse(
                taskData['creationDate'],
              )));
        }
      }
      Application.debug('待办清单加载完成.');
    } catch (e) {
      mainLogger.warning('[ERROR] 初始化待办清单时出错: $e');
    }
  }

  void _saveData() {
    Application.debug('正在保存分类数据...');
    JsonDriver settings = Application.userSettings();
    Map<dynamic, dynamic> list = Application.settings['categories']['list'];

    list = Map.fromEntries(
      _categories.entries
          .where(
            (entry) => entry.key != Application.defaultCategory.name,
          )
          .map(
            (entry) => MapEntry(entry.key, entry.value.toJson()),
          ),
    );

    settings.data['categories']['list'] = list;
    settings.writeData(settings.data);

    Application.debug('正在保存待办清单数据...');
    Map<String, dynamic> saveList = {};
    for (var key in {Application.defaultCategory.name, ...list.keys}) {
      saveList[key] = _tasks
          .where((Task task) => key == task.category.name)
          .map((Task task) => task.toJson())
          .toList();
    }
    _todoList.writeData(saveList);
    Application.debug('操作成功完成.');
  }
}