import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _faqs = [
    {
      "question": "What is the purpose of this app?",
      "answer":
          "This app helps farmers manage their crops more effectively by providing personalized recommendations.",
    },
    {
      "question": "How do I enter data?",
      "answer":
          "You can enter data by navigating to the Data Entry page and filling out the optional fields.",
    },
    {
      "question": "How do I reset my password?",
      "answer":
          "You can reset your password by clicking on 'Forgot Password' on the login page.",
    },
  ];

  // Initialize _isExpanded as a list of booleans with the same length as the FAQs
  List<bool> _isExpanded = [];
  List<Map<String, String>> _filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    // Fill the _isExpanded list with false values based on the number of FAQs
    _isExpanded = List.filled(_faqs.length, false);
    // Initialize filtered FAQs to show all FAQs initially
    _filteredFaqs = List.from(_faqs);

    // Add listener to the search controller
    _searchController.addListener(_filterFaqs);
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaqs =
          _faqs.where((faq) {
            return faq['question']!.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _toggleExpansion(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFaqs);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the dashboard
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for topics or questions',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // FAQs Header
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // FAQ List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredFaqs.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(_filteredFaqs[index]['question']!),
                          trailing: IconButton(
                            icon: Icon(
                              _isExpanded[index]
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            onPressed: () => _toggleExpansion(index),
                          ),
                        ),
                        if (_isExpanded[index])
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _filteredFaqs[index]['answer']!,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Contact Support Header
            const SizedBox(height: 20),
            const Text(
              'Contact Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Support Email
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('ndombotadiwanashe@gmail.com'),
            ),
            // Phone Number
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('+263 71 212 6579'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
