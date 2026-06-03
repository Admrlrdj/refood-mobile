import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_config.dart';
import '../auth/role_selection_page.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({Key? key}) : super(key: key);

  @override
  _VolunteerDashboardState createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  Map<String, dynamic> _summary = {'active': 0, 'completed': 0};

  List<dynamic> _availableJobs = [];
  String _volunteerName = "Relawan";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/volunteer/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final profileResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/volunteer/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 && profileResponse.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final profileData = jsonDecode(profileResponse.body)['data'];

        setState(() {
          _summary = data['summary'];
          _availableJobs = data['available_jobs'];
          _volunteerName = profileData['name'] ?? "Relawan";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching volunteer dashboard: $e");
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionPage()),
      (route) => false,
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading)
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
        ),
      );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= BANNER UTAMA =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              // Tema Volunteer menggunakan gradiasi warna Biru (Logistik/Pengantaran)
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Siap Mengantar?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.two_wheeler_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Ada yayasan yang sedang menunggu makanan. Mari bantu antarkan donasi mereka hari ini.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1D4ED8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    // Refresh data
                    setState(() => _isLoading = true);
                    _fetchDashboardData();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Refresh Radar",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Text(
            "Statistik Anda",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildSummaryCard(
                count: _summary['active'].toString(),
                label: "Sedang\nDiantar",
                gradientColors: [
                  const Color(0xFFFBBF24),
                  const Color(0xFFD97706),
                ],
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                count: _summary['completed'].toString(),
                label: "Selesai\nDiantar",
                gradientColors: [
                  const Color(0xFF4ADE80),
                  const Color(0xFF16A34A),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text(
            "Panggilan Pengantaran Terdekat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          if (_availableJobs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.radar_rounded, size: 50, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "Belum ada tugas baru.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Semua donasi telah tertangani.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

          ..._availableJobs.map((item) {
            String itemId = item['_id'] is Map
                ? item['_id']['\$oid']
                : item['_id'].toString();
            return _buildJobCard(
              jobId: itemId,
              foodName: item['name'] ?? 'Donasi Makanan',
              portion: item['portion'].toString(),
              imageUrl: item['photo_url'],
              // Data dummy sementara karena tabel kita belum me-load relasi donor/receiver penuh
              donorName: "Lokasi Donatur",
              receiverName: "Lokasi Penerima",
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      const Center(
        child: Text("Halaman Tugas Aktif & Riwayat"),
      ), // TODO: Buat Riwayat Volunteer
      const Center(
        child: Text("Halaman Profil Volunteer"),
      ), // TODO: Buat Profil Volunteer
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, $_volunteerName 🛵",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    "Radar pengantaran aktif",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  onPressed: _logout,
                ),
              ],
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1D4ED8),
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.radar_rounded),
              label: "Radar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: "Tugas",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String count,
    required String label,
    required List<Color> gradientColors,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.95),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET KARTU TUGAS PENGANTARAN (Job Card)
  Widget _buildJobCard({
    required String jobId,
    required String foodName,
    required String portion,
    String? imageUrl,
    required String donorName,
    required String receiverName,
  }) {
    String? fullImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      fullImageUrl = "${ApiConfig.baseUrl.replaceAll('/api', '')}/$imageUrl";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: fullImageUrl != null
                      ? Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fastfood_rounded,
                            color: Colors.blue,
                          ),
                        )
                      : const Icon(Icons.fastfood_rounded, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$portion Porsi",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),

          // RUTE PENGANTARAN
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    size: 16,
                    color: Colors.green,
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jemput di: $donorName",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Antar ke: $receiverName",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // TODO: Fungsi untuk Accept Job (Menerima Pengantaran)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fitur Ambil Tugas sedang dikembangkan!"),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: const Text(
                "Ambil Tugas Ini",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
