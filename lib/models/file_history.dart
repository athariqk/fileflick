class FileHistory {
  static final FileHistory _instance = FileHistory._internal();

  factory FileHistory() => _instance;

  FileHistory._internal();

  final List<String> _history = [];

  List<String> get history => List.unmodifiable(_history);

  void addFiles(List<String> fileNames) {
    _history.addAll(fileNames.where((name) => !_history.contains(name)));
  }

  void clearHistory() {
    _history.clear();
  }
}
