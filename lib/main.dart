import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'စုံထောက်အရာရှိသင်တန်း (၂၀၀)',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF102A43),
        scaffoldBackgroundColor: const Color(0xFF0B192C),
        useMaterial3: true,
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
  List<dynamic> _students = [];
  List<dynamic> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  // JSON ဖိုင်မှ ဒေတာများကို ဖတ်ယူခြင်း
  Future<void> _loadStudentData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/student.json');
      final data = await json.decode(response);
      setState(() {
        _students = data;
        _filteredStudents = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ရှာဖွေမှု (Search) ပြုလုပ်ခြင်း
  void _filterStudents(String query) {
    final filtered = _students.where((student) {
      final name = student['name'].toString().toLowerCase();
      final kathaNo = student['katha_no'].toString().toLowerCase();
      final rank = student['rank'].toString().toLowerCase();
      final input = query.toLowerCase();

      return name.contains(input) ||
          kathaNo.contains(input) ||
          rank.contains(input);
    }).toList();

    setState(() {
      _filteredStudents = filtered;
    });
  }

  // ဖုန်းခေါ်ဆိုရန်
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF102A43),
        elevation: 4,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/app_logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.shield, color: Colors.amber),
            ),
            const SizedBox(width: 10),
            const Text(
              'စုံထောက်အရာရှိသင်တန်း (၂၀၀)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Stack(
              children: [
                Center(
                  child: Opacity(
                    opacity: 0.08,
                    child: Image.asset(
                      'assets/app_logo.png',
                      width: 300,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterStudents,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'အမည် / ကဿအမှတ် / အဆင့် ဖြင့် ရှာရန်',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.amber),
                          filled: true,
                          fillColor: const Color(0xFF1E3A5F),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _filteredStudents.isEmpty
                          ? const Center(
                              child: Text(
                                'အချက်အလက် မရှိပါ။',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = _filteredStudents[index];
                                return Card(
                                  color:
                                      const Color(0xFF1E3A5F).withOpacity(0.8),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: Colors.amber, width: 0.5),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.amber.shade700,
                                      backgroundImage:
                                          AssetImage(student['image']),
                                      onBackgroundImageError: (_, __) {},
                                      child: const Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                                    title: Text(
                                      '${student['katha_no']}. ${student['name']} (${student['rank']})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text('တာဝန်: ${student['dudy']}',
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                        Text('လိပ်စာ: ${student['address']}',
                                            style: const TextStyle(
                                                color: Colors.white70)),
                                        if (student['course']
                                            .toString()
                                            .isNotEmpty)
                                          Text('သင်တန်း: ${student['course']}',
                                              style: const TextStyle(
                                                  color: Colors.white70)),
                                      ],
                                    ),
                                    trailing:
                                        student['phone'].toString().isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.phone,
                                                    color: Colors.greenAccent),
                                                onPressed: () => _makePhoneCall(
                                                    student['phone']),
                                              )
                                            : null,
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
