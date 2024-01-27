/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2024-01-19 00:55:40
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2024-01-26 23:35:31
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// screens/widget_test_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:todolist_app/main.dart';

class WidgetTestScreen extends StatefulWidget {
  const WidgetTestScreen({super.key});

  @override
  State<WidgetTestScreen> createState() => _WidgetTestState();
}

class _WidgetTestState extends State<WidgetTestScreen> {
  @override
  Widget build(BuildContext context) {
    return isDebugMode
        ? Center(
            child: ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(
                    msg: "This is Center Short Toast",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue.shade500, // 设置按钮文本颜色
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // 设置按钮圆角
                ),
              ),
              child: const Text('Try It!'),
            ),
          )
        : const Center(
            child: Text('Nothing to do :)'),
          );
  }
}
