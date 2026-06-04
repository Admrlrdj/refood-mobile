import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_config.dart';
import '../auth/role_selection_page.dart';
import 'search_food_page.dart';
import 'request_food_page.dart';
import 'incoming_food_detail_page.dart';
import 'request_food_detail_page.dart';
import 'receiver_history_page.dart';
import 'receiver_profile_page.dart';

class ReceiverDashboard extends StatefulWidget {
  const ReceiverDashboard({Key? key}) : super(key: key);

  @override
  _ReceiverDashboardState createState() => _ReceiverDashboardState();
}

class _ReceiverDashboardState extends State<ReceiverDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  // FIX: Inisialisasi dengan nilai default yang aman
  Map<String, dynamic> _summary = {
    'received': 0,
    'on_delivery': 0,
    'requests': 0,
  };

  List<dynamic> _incomingFoods = [];
  // List<dynamic> _recentRequests = [];
  List<dynamic> _activeRequests = [];
  String _receiverName = "Yayasan";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      // FIX: Jalankan secara paralel
      final results = await Future.wait([
        http.get(
          Uri.parse('${ApiConfig.baseUrl}/receiver/dashboard'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        http.get(
          Uri.parse('${ApiConfig.baseUrl}/receiver/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      ]);

      final response = results[0];
      final profileResponse = results[1];

      if (!mounted) return;

      // FIX: Handle dashboard response dengan null safety berlapis
      if (response.statusCode == 200 && profileResponse.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final profileData = jsonDecode(profileResponse.body)['data'];

        setState(() {
          // PASTIKAN KEY JSON INI SAMA
          _incomingFoods = data['incoming_foods'] ?? [];
          _activeRequests = data['active_requests'] ?? [];
          _receiverName = profileData['name'] ?? "Yayasan";

          if (data['summary'] != null) {
            _summary = data['summary'];
          } else {
            // (Opsional) Hitung manual jika backend belum mengirim object 'summary'
            _summary = {
              'received': _incomingFoods
                  .where((e) => e['status'] == 'completed')
                  .length,
              'on_delivery': _incomingFoods
                  .where(
                    (e) =>
                        e['status'] == 'on_delivery' ||
                        e['status'] == 'accepted',
                  )
                  .length,
              'requests': _activeRequests.length,
            };
          }
          
          _isLoading = false;
        });
      } else {
        debugPrint(
          'Dashboard error: ${response.statusCode} - ${response.body}',
        );
      }

      // FIX: Profile dihandle terpisah, tidak memblokir data dashboard
      if (profileResponse.statusCode == 200) {
        final profileBody = jsonDecode(profileResponse.body);
        final profileData = profileBody['data'] as Map<String, dynamic>? ?? {};
        setState(() {
          _receiverName = profileData['name']?.toString() ?? "Yayasan";
        });
      }
    } catch (e) {
      debugPrint("Error fetching receiver dashboard: $e");
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
      // FIX: SELALU set isLoading = false apapun yang terjadi
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

  Map<String, dynamic> _getStatusUI(String status) {
    switch (status) {
      case 'available':
        return {"text": "Tersedia", "color": Colors.blue};
      case 'waiting_donor':
        return {"text": "Menunggu Donatur", "color": Colors.orange};
      case 'accepted':
      case 'on_delivery':
        return {"text": "Sedang Diantar", "color": Colors.amber};
      case 'completed':
        return {"text": "Selesai", "color": Colors.green};
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
          child: CircularProgressIndicator(color: Color(0xFF0F766E)),
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
                colors: [Color(0xFF2EA275), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Butuh Bantuan Makanan?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Cari donasi yang tersedia di sekitar Anda atau ajukan permintaan kebutuhan makanan.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F766E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchFoodPage(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Cari",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RequestFoodPage(),
                            ),
                          );
                          _fetchDashboardData();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.campaign_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Request",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // RINGKASAN PENERIMAAN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ringkasan Penerimaan",
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
                  color: Color(0xFF0F766E),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildSummaryCard(
                count: (_summary['received'] ?? 0).toString(),
                label: "Diterima",
                gradientColors: [
                  const Color(0xFF4ADE80),
                  const Color(0xFF16A34A),
                ],
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                count: (_summary['on_delivery'] ?? 0).toString(),
                label: "Diperjalanan",
                gradientColors: [
                  const Color(0xFF60A5FA),
                  const Color(0xFF2563EB),
                ],
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                count: (_summary['requests'] ?? 0).toString(),
                label: "Request",
                gradientColors: [
                  const Color(0xFFFB923C),
                  const Color(0xFFEA580C),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // MAKANAN MASUK TERKINI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Makanan Masuk Terkini",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchFoodPage(),
                  ),
                ),
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2EA275),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_incomingFoods.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Belum ada donasi makanan terbaru di sekitar Anda.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ..._incomingFoods.map((item) {
              var statusInfo = _getStatusUI(
                item['status']?.toString() ?? 'available',
              );
              // FIX: Null-safe ID parsing
              String itemId = '';
              if (item['_id'] is Map) {
                itemId = item['_id']['\$oid']?.toString() ?? '';
              } else {
                itemId = item['_id']?.toString() ?? '';
              }

              return GestureDetector(
                onTap: () async {
                  if (itemId.isEmpty) return;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          IncomingFoodDetailPage(foodId: itemId),
                    ),
                  );
                  if (result == true) _fetchDashboardData();
                },
                child: _buildActivityCard(
                  title: item['name']?.toString() ?? 'Makanan',
                  status: statusInfo['text'],
                  portion: "${item['portion'] ?? '0'} Porsi",
                  statusColor: statusInfo['color'],
                  icon: Icons.fastfood_rounded,
                  imageUrl: item['photo_url']?.toString(),
                ),
              );
            }).toList(),

          const SizedBox(height: 32),

          // AKTIVITAS REQUEST MAKANAN
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Aktivitas Request Makanan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Lihat Semua",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2EA275),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_activeRequests.isEmpty) // <-- UBAH DI SINI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Anda belum mengajukan request makanan apapun.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ..._activeRequests.map((item) {
              // <-- UBAH DI SINI JUGA
              var statusInfo = _getStatusUI(
                item['status']?.toString() ?? 'waiting_donor',
              );
              // FIX: Null-safe ID parsing
              String itemId = '';
              if (item['_id'] is Map) {
                itemId = item['_id']['\$oid']?.toString() ?? '';
              } else {
                itemId = item['_id']?.toString() ?? '';
              }

              return GestureDetector(
                onTap: () async {
                  if (itemId.isEmpty) return;
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RequestFoodDetailPage(foodId: itemId),
                    ),
                  );
                  if (result == true) _fetchDashboardData();
                },
                child: _buildActivityCard(
                  title: item['name']?.toString() ?? 'Request',
                  status: statusInfo['text'],
                  portion: "${item['portion'] ?? '0'} Porsi",
                  statusColor: statusInfo['color'],
                  icon: Icons.campaign_rounded,
                  imageUrl: item['photo_url']?.toString(),
                ),
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
      ReceiverHistoryPage(
        onBackPressed: () => setState(() => _selectedIndex = 0),
      ),
      ReceiverProfilePage(
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
                    "Halo, $_receiverName",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    "Temukan bantuan untuk yayasan Anda",
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
          selectedItemColor: const Color(0xFF0F766E),
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

  Widget _buildActivityCard({
    required String title,
    required String status,
    required String portion,
    required Color statusColor,
    required IconData icon,
    String? imageUrl,
  }) {
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
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: fullImageUrl != null
                  ? Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(icon, color: const Color(0xFF0F766E), size: 26),
                    )
                  : Icon(icon, color: const Color(0xFF0F766E), size: 26),
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
