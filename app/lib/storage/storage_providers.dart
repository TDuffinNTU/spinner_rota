import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spinner_rota/storage/spinner_entry.dart';

part 'storage_providers.g.dart';

@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  AppStateNotifier();

  @override
  FutureOr<AppState> build() => const AppState(
        title: 'None',
        currentMeister: -1,
        entries: [],
        savePath: 'savePath',
      );

  void saveData() {
    throw UnimplementedError();
  }

  /// Opens the file dialog and loads the CSV data from within.
  ///
  /// [hasMetaRow] is used to flag whether the first row of the CSV file is
  /// a "meta row" which contains useful data in the following schema:
  ///
  /// `title,currentMeister`
  ///
  /// * title: The title of the next screen (eg. 'Squad A sprint master!')
  /// * currentMeister: the currently selected meister as an index into the following list.
  ///
  /// **Warning:** This scheme is liable to change! Though I will try to do this additively so reduce breaking changes.
  Future<void> loadData(bool hasMetaRow) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) {
        throw Exception('Picker closed without selecting anything!');
      }

      final String path = result.files.single.path!;
      final input = File(path).openRead();
      final List<List<dynamic>> fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(eol: '\n'))
          .toList();

      // Whether we parse first row as metadata.
      String title = 'Spin to Win!';
      int currentMeister = -1;

      if (hasMetaRow) {
        hasMetaRow = true;
        title = fields[0][0];
        currentMeister = min(fields[0][1], fields.length - 2);
        fields.removeAt(0);
      }

      if (fields.length <= 1 + (hasMetaRow ? 1 : 0)) {
        throw Exception('At least 2 entries are needed for the spinner!');
      }

      state = AsyncData(AppState(
        title: title,
        currentMeister: currentMeister,
        entries: fields.map((e) => SpinnerEntry.fromCsv(e)).toList(),
        savePath: path,
      ));
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

/// The state of the spinner app as a mega-singleton.
class AppState {
  const AppState({
    required this.title,
    required this.currentMeister,
    required this.entries,
    required this.savePath,
  });

  final String savePath;
  final String title;
  final int currentMeister;
  final List<SpinnerEntry> entries;
}
