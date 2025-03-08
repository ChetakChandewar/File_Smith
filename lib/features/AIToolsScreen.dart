import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AIToolsScreen extends StatefulWidget {
  const AIToolsScreen({super.key});

  @override
  State<AIToolsScreen> createState() => _AIToolsScreenState();
}

class _AIToolsScreenState extends State<AIToolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedIndex;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = null;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Tools'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search AI Tools',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('tools').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  final tools = snapshot.data?.docs.where((tool) {
                    final data = tool.data() as Map<String, dynamic>;
                    final name = (data['name'] as String).toLowerCase();
                    final keywords = (data['keywords'] as List<dynamic>)
                        .cast<String>()
                        .map((keyword) => keyword.toLowerCase())
                        .toList();

                    final query = _searchQuery.toLowerCase();

                    return name.contains(query) ||
                        keywords.any((keyword) => keyword.contains(query));
                  }).toList() ?? [];

                  return ListView.builder(
                    itemCount: tools.length,
                    itemBuilder: (context, index) {
                      final toolData = tools[index].data() as Map<String, dynamic>;
                      final isSelected = _selectedIndex == index;

                      return Column(
                        children: [
                          Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  _selectedIndex = isSelected ? null : index;
                                });
                              },
                              leading: Text(
                                toolData['name'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () async {
                                  final Uri url = Uri.parse(toolData['link']);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Could not launch link'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Open'),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(toolData['description']),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
