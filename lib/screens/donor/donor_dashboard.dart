import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_config.dart';
import '../auth/role_selection_page.dart';

// Import Halaman Riwayat & Profil
import 'donor_history_page.dart';
import 'donor_profile_page.dart';
// Import Halaman Detail & Tambah
import 'add_donation_page.dart';
import 'donation_detail_page.dart';
import 'yayasan_request_detail_page.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({Key? key}) : super(key: key);

  @override
  _DonorDashboardState createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  // FIX: Inisialisasi dengan nilai default yang aman
  Map<String, dynamic> _summary = {'active': 0, 'completed': 0};
  List<dynamic> _activeDonations = [];
  List<dynamic> _yayasanRequests = [];
  String _donorName = "Donatur";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    // FIX: Set loading true di awal refresh
    if (!mounted) return;
    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      // FIX: Jalankan kedua request secara paralel agar lebih cepat
      final results = await Future.wait([
        http.get(
          Uri.parse('${ApiConfig.baseUrl}/donor/dashboard'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        http.get(
          Uri.parse('${ApiConfig.baseUrl}/donor/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      ]);

      final response = results[0];
      final profileResponse = results[1];

      if (!mounted) return;

      // FIX: Handle dashboard response dulu, profile terpisah (tidak saling blokir)
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // FIX: Null safety berlapis — pastikan setiap level tidak null
        final data = body['data'] as Map<String, dynamic>? ?? {};

        setState(() {
          _summary =
              (data['summary'] as Map<String, dynamic>?) ??
              {'active': 0, 'completed': 0};
          // FIX: Pakai List.from() agar tidak error kalau null
          _activeDonations = List.from(data['active_donations'] ?? []);
          _yayasanRequests = List.from(data['yayasan_requests'] ?? []);
        });
      } else {
        // FIX: Kalau dashboard gagal, tetap tampilkan halaman (data kosong)
        debugPrint(
          'Dashboard error: ${response.statusCode} - ${response.body}',
        );
      }

      // FIX: Profile dihandle terpisah, tidak memblokir dashboard
      if (profileResponse.statusCode == 200) {
        final profileBody = jsonDecode(profileResponse.body);
        final profileData = profileBody['data'] as Map<String, dynamic>? ?? {};
        setState(() {
          _donorName = profileData['name']?.toString() ?? "Donatur";
        });
      }
    } catch (e) {
      // FIX: Tampilkan error tapi tetap keluar dari loading state
      debugPrint("Error fetching donor dashboard: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat data. Coba lagi.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      // FIX: SELALU set isLoading = false, apapun yang terjadi
      if (mounted) setState(() => _isLoading = false);
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
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
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
                      "Ayo Berbagi!",
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
                        Icons.volunteer_activism_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Makanan berlebihmu bisa menjadi berkah untuk mereka yang membutuhkan hari ini.",
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
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddDonationPage(),
                      ),
                    );
                    if (result == true) _fetchDashboardData();
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 20),
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

          // SECTION: DONASI AKTIF ANDA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Donasi Aktif Anda",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: _fetchDashboardData,
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_activeDonations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Belum ada donasi aktif.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            ..._activeDonations.map((item) {
              // FIX: Null-safe ID parsing
              String itemId = '';
              if (item['_id'] is Map) {
                itemId = item['_id']['\$oid']?.toString() ?? '';
              } else {
                itemId = item['_id']?.toString() ?? '';
              }

              return _buildDonationCard(
                foodName: item['name']?.toString() ?? 'Donasi',
                portion: item['portion']?.toString() ?? '0',
                status: item['status']?.toString() ?? 'available',
                imageUrl: item['photo_url']?.toString(),
                onTap: () async {
                  if (itemId.isEmpty) return;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DonationDetailPage(donationId: itemId),
                    ),
                  );
                  if (result == true) _fetchDashboardData();
                },
              );
            }).toList(),

          const SizedBox(height: 12),

          // SECTION: PERMINTAAN YAYASAN
          const Text(
            "Permintaan Yayasan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          if (_yayasanRequests.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 50, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "Belum ada permintaan.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Yayasan di sekitar Anda sedang tercukupi.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._yayasanRequests.map((item) {
              // FIX: Null-safe parsing untuk semua field
              String receiverName = "Yayasan Tidak Diketahui";
              if (item['receiver'] != null &&
                  item['receiver']['name'] != null) {
                receiverName = item['receiver']['name'].toString();
              }
              String portion = item['portion']?.toString() ?? '0';
              String foodName =
                  item['name']?.toString() ?? 'Permintaan Makanan';

              return _buildRequestCard(
                yayasanName: receiverName,
                foodName: foodName,
                portion: portion,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          YayasanRequestDetailPage(requestData: item),
                    ),
                  );
                  if (result == true) _fetchDashboardData();
                },
              );
            }).toList(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      DonorHistoryPage(onBackPressed: () => setState(() => _selectedIndex = 0)),
      DonorProfilePage(
        onBackPressed: () => setState(() => _selectedIndex = 0),
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
                    "Halo, $_donorName",
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
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) => setState(() => _selectedIndex = index),
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

  Widget _buildDonationCard({
    required String foodName,
    required String portion,
    required String status,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    String? fullImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      fullImageUrl = "${ApiConfig.baseUrl.replaceAll('/api', '')}/$imageUrl";
    }

    Color statusColor = Colors.orange;
    String statusText = "Menunggu";

    if (status == 'available' || status == 'waiting_donor') {
      statusColor = Colors.orange;
      statusText = "Menunggu";
    } else if (status == 'accepted') {
      statusColor = Colors.blue;
      statusText = "Akan Dijemput";
    } else if (status == 'on_delivery') {
      statusColor = Colors.purple;
      statusText = "Diperjalanan";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green[50],
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
                          color: Colors.green,
                        ),
                      )
                    : const Icon(Icons.fastfood_rounded, color: Colors.green),
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
                      fontSize: 15,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String yayasanName,
    required String foodName,
    required String portion,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.maps_home_work_rounded,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      yayasanName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Membutuhkan: $foodName",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$portion Porsi",
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onTap,
              child: const Text(
                "Penuhi Request",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
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
