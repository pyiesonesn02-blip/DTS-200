import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const DTSPhonebookApp());
}

class DTSPhonebookApp extends StatelessWidget {
  const DTSPhonebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DTS-200 Phonebook',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),
      ),
      home: const StudentListScreen(),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<dynamic> _allStudents = [];
  List<dynamic> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final String response = await rootBundle.loadString('assets/student.json');
    final data = await json.decode(response);
    setState(() {
      _allStudents = data;
      _filteredStudents = data;
    });
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _allStudents;
      } else {
        _filteredStudents = _allStudents.where((student) {
          final name = student['name']?.toString().toLowerCase() ?? '';
          final rank = student['rank']?.toString().toLowerCase() ?? '';
          final serial =
              student['serial_number']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) ||
              rank.contains(searchLower) ||
              serial.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/app_logo.png',
                height: 32,
                errorBuilder: (c, o, s) =>
                    const Icon(Icons.security, color: Colors.amber)),
            const SizedBox(width: 10),
            const Text(
              'စုံထောက်အရာရှိသင်တန်း (၂၀၀)',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Watermark Background Logo
          Center(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/app_logo.png',
                width: 280,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterStudents,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'အမည် / ကသသအမှတ် / အဆင့် ဖြင့် ရှာ...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: const Icon(Icons.search, color: Colors.amber),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.amber),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.amber, width: 2),
                    ),
                  ),
                ),
              ),

              // Student List
              Expanded(
                child: _filteredStudents.isEmpty
                    ? const Center(
                        child: Text('အချက်အလက် မရှိပါ။',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          final String imagePath = student['image'] ?? '';
                          final String phone = student['phone'] ?? '';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            color: const Color(0xFF1E293B).withOpacity(0.85),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  // Profile Picture Box (လူပုံ ပျောက်စေရန် နေရာလွတ် သို့မဟုတ် CircleAvatar အလွတ်ဖြင့် ထားထားသည်)
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        Colors.amber.shade900.withOpacity(0.4),
                                    backgroundImage: imagePath.isNotEmpty
                                        ? AssetImage(imagePath)
                                        : null,
                                    child: imagePath.isEmpty
                                        ? Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                                color: Colors.amber,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),

                                  // Student Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${student['id'] ?? index + 1}. ${student['name'] ?? ''} (${student['rank'] ?? ''})',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('တာဝန်: ${student['duty'] ?? '-'}',
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13)),
                                        Text(
                                            'လိပ်စာ: ${student['address'] ?? '-'}',
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13)),
                                        if (student['batch'] != null)
                                          Text('သင်တန်း: ${student['batch']}',
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13)),
                                      ],
                                    ),
                                  ),

                                  // Call Button
                                  if (phone.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.phone_in_talk,
                                          color: Colors.tealAccent),
                                      onPressed: () => _makePhoneCall(phone),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
