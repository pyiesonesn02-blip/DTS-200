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
    final data = json.decode(response);
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
          final kathaNo = student['katha_no']?.toString().toLowerCase() ?? '';
          final phone = student['phone']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) ||
              rank.contains(searchLower) ||
              serial.contains(searchLower) ||
              kathaNo.contains(searchLower) ||
              phone.contains(searchLower);
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
                    hintText: 'အမည် / ကသသအမှတ် / ဖုန်း / အဆင့် ဖြင့် ရှာ...',
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
                          final String phone =
                              student['phone'] ?? 'ဖုန်းနံပါတ် မရှိပါ';
                          final String duty = student['dudy'] ??
                              student['duty'] ??
                              student['position'] ??
                              student['job'] ??
                              '-';
                          final String address =
                              student['address'] ?? student['location'] ?? '-';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            color: const Color(0xFF1E293B).withOpacity(0.85),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: Colors.amber.withOpacity(0.3)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              leading: CircleAvatar(
                                radius: 26,
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
                              title: Text(
                                '${student['id'] ?? index + 1}. ${student['name'] ?? ''} (${student['rank'] ?? ''})',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('တာဝန်: $duty',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13)),
                                    Text('လိပ်စာ: $address',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentDetailScreen(
                                        student: student, index: index),
                                  ),
                                );
                              },
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

// ==========================================
// လူတစ်ယောက်ချင်းစီအတွက် သီးသန့်ပေါ်မည့် Detail Screen
// ==========================================
class StudentDetailScreen extends StatelessWidget {
  final dynamic student;
  final int index;

  const StudentDetailScreen(
      {super.key, required this.student, required this.index});

  @override
  Widget build(BuildContext context) {
    final String imagePath = student['image'] ?? '';
    final String name = student['name'] ?? 'အမည်မသိ';
    final String rank = student['rank'] ?? '';
    final String phone = student['phone'] ?? 'ဖုန်းနံပါတ် မရှိပါ';
    final String duty = student['dudy'] ??
        student['duty'] ??
        student['position'] ??
        student['job'] ??
        '-';
    final String address = student['address'] ?? student['location'] ?? '-';
    final String kathaNo =
        student['katha_no'] ?? student['id']?.toString() ?? '${index + 1}';
    final String course = student['course'] ?? '၂၀၀';

    Future<void> makePhoneCall(String phoneNumber) async {
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$name ၏ အချက်အလက်',
            style: const TextStyle(color: Colors.amber, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.amber.shade900.withOpacity(0.4),
                  backgroundImage:
                      imagePath.isNotEmpty ? AssetImage(imagePath) : null,
                  child: imagePath.isEmpty
                      ? Text(
                          kathaNo,
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              rank,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.badge, 'ကသသအမှတ်', kathaNo),
                    const Divider(color: Colors.white12),
                    _buildDetailRow(Icons.work, 'တာဝန်', duty),
                    const Divider(color: Colors.white12),
                    _buildDetailRow(Icons.location_on, 'လိပ်စာ', address),
                    const Divider(color: Colors.white12),
                    _buildDetailRow(Icons.school, 'သင်တန်းအမှတ်စဉ်', course),
                    const Divider(color: Colors.white12),
                    _buildDetailRow(Icons.phone, 'ဖုန်းနံပါတ်', phone),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (phone != 'ဖုန်းနံပါတ် မရှိပါ' && phone.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => makePhoneCall(phone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.phone_in_talk, color: Colors.white),
                  label: const Text(
                    'ဖုန်းခေါ်ဆိုမည်',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white60, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
