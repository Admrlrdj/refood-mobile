import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_config.dart';
import '../auth/role_selection_page.dart';
import 'add_donation_page.dart';
import 'donor_history_page.dart';
import 'donor_profile_page.dart';
import 'donation_detail_page.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({Key? key}) : super(key: key);

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  Map<String, dynamic> _summary = {'waiting': 0, 'active': 0, 'history': 0};
  List<dynamic> _recentActivities = [];
  String _donorName = "Donatur";

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
        Uri.parse('${ApiConfig.baseUrl}/donor/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final profileResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donor/profile'),
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
          _recentActivities = data['recent_activities'];
          _donorName = profileData['name'] ?? "Donatur";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching dashboard: $e");
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => RoleSelectionPage()),
      (route) => false,
    );
  }

  Map<String, dynamic> _getStatusUI(String status) {
    switch (status) {
      case 'available':
        return {"text": "Menunggu Donasi", "color": Colors.blue};
      case 'accepted':
      case 'on_delivery':
        return {"text": "Sedang Diproses", "color": Colors.orange};
      case 'completed':
        return {"text": "Berhasil Disalurkan", "color": Colors.green};
      case 'cancelled':
        return {"text": "Dibatalkan", "color": Colors.red};
      default:
        return {"text": status, "color": Colors.grey};
    }
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0),
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BANNER UTAMA
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF86D538), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Punya makanan berlebih?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Jangan dibuang! Salurkan kepada yayasan dan panti asuhan melalui aplikasi RE-FOOD.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E7D32),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddDonationPage(),
                      ),
                    );
                    _fetchDashboardData();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Donasi Sekarang",
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
            "Ringkasan Anda",
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
                count: _summary['history'].toString(),
                label: "Riwayat",
                gradientColors: [
                  const Color(0xFFFB923C),
                  const Color(0xFFEA580C),
                ],
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                count: _summary['active'].toString(),
                label: "Donasi Aktif",
                gradientColors: [
                  const Color(0xFF4ADE80),
                  const Color(0xFF16A34A),
                ],
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                count: _summary['waiting'].toString(),
                label: "Menunggu\nDonasi",
                gradientColors: [
                  const Color(0xFF60A5FA),
                  const Color(0xFF2563EB),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Aktivitas Terkini",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 1),
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF56AB2F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // LIST AKTIVITAS TERKINI (DENGAN GAMBAR)
          if (_recentActivities.isEmpty)
            const Text(
              "Belum ada aktivitas donasi.",
              style: TextStyle(color: Colors.grey),
            ),

          ..._recentActivities.map((item) {
            var statusInfo = _getStatusUI(item['status']);
            // Mengambil ID string bersih dari format BSON MongoDB
            String itemId = item['_id'] is Map
                ? item['_id']['\$oid']
                : item['_id'].toString();

            return GestureDetector(
              onTap: () async {
                // Navigasi ke Detail
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonationDetailPage(foodId: itemId),
                  ),
                );
                // Refresh dashboard jika ada perubahan/penghapusan
                if (result == true) _fetchDashboardData();
              },
              child: _buildActivityCard(
                title: item['name'],
                status: statusInfo['text'],
                portion: "${item['portion']} Porsi",
                statusColor: statusInfo['color'],
                icon: Icons.fastfood_rounded,
                imageUrl: item['photo_url'],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      DonorHistoryPage(
        onBackPressed: () => setState(() {
          _selectedIndex = 0;
        }),
      ),
      DonorProfilePage(
        onBackPressed: () => setState(() {
          _selectedIndex = 0;
        }),
        onLogout: _logout,
      ),
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
                    "Halo, $_donorName 👋",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    "Mari berbagi makanan hari ini",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) => setState(() {
            _selectedIndex = index;
          }),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Beranda",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: "Riwayat",
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

  // ==========================================
  // WIDGET KARTU AKTIVITAS YANG SUDAH DIOPTIMASI
  // ==========================================
  Widget _buildActivityCard({
    required String title,
    required String status,
    required String portion,
    required Color statusColor,
    required IconData icon,
    String? imageUrl,
  }) {
    // Membentuk URL lengkap gambar dengan menghapus '/api' dari baseUrl lalu menggabungkannya dengan photo_url dari database
    String? fullImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      String serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');
      fullImageUrl = "$serverUrl/$imageUrl";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Row(
        children: [
          // Tampilan Thumbnail Gambar
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(
                0xFFF1F6D2,
              ), // Warna dasar jika gambar tidak ada
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: fullImageUrl != null
                  ? Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                      // Jika gambar gagal diload dari internet, tampilkan icon sebagai cadangan
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(icon, color: const Color(0xFF56AB2F), size: 26),
                    )
                  : Icon(icon, color: const Color(0xFF56AB2F), size: 26),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              portion,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
