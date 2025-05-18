import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation History'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              // TODO: Implement filtering
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(value: 'all', child: Text('All')),
                  const PopupMenuItem(
                    value: 'device',
                    child: Text('From Device'),
                  ),
                  const PopupMenuItem(value: 'link', child: Text('From Link')),
                ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 0, // TODO: Replace with actual history items
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              title: const Text('Translation Title'),
              subtitle: Text(
                'Translated on ${DateTime.now().toString().split(' ')[0]}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.download),
                              title: const Text('Download'),
                              onTap: () {
                                // TODO: Implement download
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text('Share'),
                              onTap: () {
                                // TODO: Implement share
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text('Delete'),
                              onTap: () {
                                // TODO: Implement delete
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              onTap: () {
                // TODO: Navigate to translation details
              },
            ),
          );
        },
      ),
    );
  }
}
