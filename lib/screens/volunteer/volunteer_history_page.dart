import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';

class VolunteerHistoryPage extends StatefulWidget {
  const VolunteerHistoryPage({Key? key}) : super(key: key);

  @override
  _VolunteerHistoryPageState createState() => _VolunteerHistoryPageState();
}

class _VolunteerHistoryPageState extends State<VolunteerHistoryPage> {
  bool _isLoading = true;
  List<dynamic> _activeJobs = [];
  List<dynamic> _completedJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/volunteer/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _activeJobs = data['active'] ?? [];
          _completedJobs = data['completed'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeJob(String jobId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selesaikan Tugas?"),
        content: const Text(
          "Pastikan makanan telah diserahkan kepada penerima dengan baik.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              final res = await http.post(
                Uri.parse('${ApiConfig.baseUrl}/volunteer/jobs/$jobId/status'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({'status': 'completed'}),
              );
              if (res.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pengantaran Selesai!"),
                    backgroundColor: Colors.green,
                  ),
                );
                _fetchHistory();
              }
            },
            child: const Text(
              "Ya, Selesai",
              style: TextStyle(
                color: Color(0xFF1D4ED8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            "Tugas Saya",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFF1D4ED8),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF1D4ED8),
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Sedang Diantar"),
              Tab(text: "Selesai"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1D4ED8)),
              )
            : TabBarView(
                children: [
                  _buildList(_activeJobs, isActive: true),
                  _buildList(_completedJobs, isActive: false),
                ],
              ),
      ),
    );
  }

  Widget _buildList(List<dynamic> jobs, {required bool isActive}) {
    if (jobs.isEmpty)
      return Center(
        child: Text(
          "Tidak ada data",
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        var item = jobs[index];
        String jobId = item['_id'] is Map
            ? item['_id']['\$oid']
            : item['_id'].toString();
        return _buildJobHistoryCard(item, jobId, isActive);
      },
    );
  }

  Widget _buildJobHistoryCard(
    Map<String, dynamic> item,
    String jobId,
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fastfood_rounded,
                color: Color(0xFF1D4ED8),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['name'] ?? 'Donasi',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive ? Colors.orange[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? "Di Jalan" : "Selesai",
                  style: TextStyle(
                    color: isActive ? Colors.orange[800] : Colors.green[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isActive)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _completeJob(jobId),
                child: const Text(
                  "Selesaikan Pengantaran",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
