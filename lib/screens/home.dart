import 'package:fileflick/models/file_history.dart';
import 'package:fileflick/screens/file_receive.dart';
import 'package:fileflick/screens/file_send.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final history = FileHistory().history;

    int columnCount = 3;
    if (MediaQuery.of(context).size.width > 800) {
      columnCount = 5;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(
              top: 10),
          child: Center(
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color: Colors.green,
                  size: 45,
                ),
                SizedBox(width: 10),
                Text(
                  'FILEFLICK',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 2,
              child: SizedBox(
                width: 200,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      (ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FileReceivePage()),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        child: const Text('Receive'),
                      )),
                      const SizedBox(height: 5),
                      (ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FileSendPage()),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        child: const Text('Send'),
                      )),
                    ]),
              )),
          Expanded(
            flex: 3,
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'No files transferred yet!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0,
                        5.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnCount,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio:
                            3,
                      ),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.file_present,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    history[index],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
            child: FileHistory()
                    .history
                    .isNotEmpty
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          FileHistory().clearHistory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text(
                        'Clear History',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
