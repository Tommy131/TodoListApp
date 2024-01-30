// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, depend_on_referenced_packages

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
 * @LastEditTime : 2024-01-30 01:08:27
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
// screens/json_import_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:todolist_app/main.dart';

class JsonImportExportScreen extends StatefulWidget {
  const JsonImportExportScreen({Key? key}) : super(key: key);

  @override
  _JsonImportExportScreenState createState() => _JsonImportExportScreenState();
}

class _JsonImportExportScreenState extends State<JsonImportExportScreen> {
  static final String savePath = Application.userSettings().savePath;

  TextEditingController jsonController = TextEditingController();
  bool isJsonValid = true;
  List<String> jsonFiles = [];
  String? selectedFilePath;

  @override
  void initState() {
    super.initState();
    _loadJsonFiles();
  }

  void _loadJsonFiles() async {
    try {
      jsonFiles.clear();
      Directory directory = Directory(savePath);
      List<FileSystemEntity> files = directory.listSync();

      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          jsonFiles.add(file.path);
        }
      }
      setState(() {});
    } catch (e) {
      Application.debug('Error loading JSON files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdownButton(),
            const SizedBox(height: 10),
            _buildElevatedButton('Import JSON', _importJson),
            const SizedBox(height: 10),
            _buildElevatedButton('Export JSON', _exportJson),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: isJsonValid
                    ? _buildHighlightedJson()
                    : const Text(
                        'Invalid JSON!',
                        style: TextStyle(color: Colors.red),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton() {
    return DropdownButton<String>(
      value: selectedFilePath,
      isExpanded: true,
      onChanged: (String? newValue) {
        setState(() {
          selectedFilePath = newValue;
          _loadSelectedFile();
        });
      },
      items: jsonFiles.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildElevatedButton(String text, Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  void _loadSelectedFile() async {
    try {
      if (selectedFilePath != null) {
        String jsonContent = await File(selectedFilePath!).readAsString();
        jsonController.text = jsonContent;
        _validateJson();
      }
    } catch (e) {
      Application.debug('Error loading selected file: $e');
    }
  }

  void _importJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        initialDirectory: savePath,
        allowedExtensions: ['json'],
      );

      if ((result == null) || (selectedFilePath == null)) {
        _sendBottomMessage(
            message: selectedFilePath == null
                ? 'Please at least pick one file to export!'
                : 'Process cancelled.');
        return;
      }

      File file = File(result.files.single.path!);
      String jsonContent = await file.readAsString();
      jsonController.text = jsonContent;
      _validateJson();

      if (isJsonValid) {
        UI.showConfirmationDialog(
          context,
          confirmMessage: 'Overwrite the file : $selectedFilePath?',
          onCall: () async {
            await File(selectedFilePath!).writeAsString(jsonContent);
            _sendBottomMessage(
                message: 'JSON data imported to file: ${file.toString()}');
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error importing JSON'),
      ));
    }
  }

  void _exportJson() async {
    try {
      if (isJsonValid) {
        String jsonString = jsonController.text;
        if (jsonFiles.isEmpty) {
          _sendBottomMessage(message: 'Invalid Json Data!');
          return;
        }
        if (selectedFilePath != null) {
          String basename = path.basename(selectedFilePath!);
          String? result = await FilePicker.platform.saveFile(
            dialogTitle: 'Save file to:',
            fileName: 'exported_$basename.json',
            type: FileType.custom,
            allowedExtensions: ['json'],
          );

          if (result == null) {
            _sendBottomMessage();
            return;
          }

          await File(result).writeAsString(jsonString);
          _sendBottomMessage(message: 'JSON data exported to file: $result');
        } else {
          _sendBottomMessage(
              message: 'Please at least pick one file to export!');
        }
      }
    } catch (e) {
      _sendBottomMessage(message: 'Error exporting JSON!');
    }
  }

  Widget _buildHighlightedJson() {
    try {
      dynamic jsonData = jsonDecode(jsonController.text);
      // String formattedJson = jsonEncode(jsonData);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String prettyPrintedJson = encoder.convert(jsonData);
      return HighlightView(
        prettyPrintedJson,
        language: 'json',
        theme: githubTheme,
        padding: const EdgeInsets.all(10),
        textStyle: const TextStyle(fontSize: 12),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  void _validateJson() {
    try {
      jsonDecode(jsonController.text);
      setState(() {
        isJsonValid = true;
      });
    } catch (e) {
      setState(() {
        isJsonValid = false;
      });
    }
  }

  void _sendBottomMessage({String message = 'Process cancelled.'}) {
    UI.showBottomSheet(
      context: context,
      message: message,
    );
  }
}
