import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';
import 'incoming_food_detail_page.dart';
import 'receiver_dashboard.dart'; // Untuk Hard Reload

class SearchFoodPage extends StatefulWidget {
  const SearchFoodPage({Key? key}) : super(key: key);

  @override
  _SearchFoodPageState createState() => _SearchFoodPageState();
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  bool _isLoading = true;
  List<dynamic> _availableFoods = [];

  @override
  void initState() {
    super.initState();
    _fetchAvailableFoods();
  }

  Future<void> _fetchAvailableFoods() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/receiver/foods/available'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _availableFoods = data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptDonationDirectly(
    Map<String, dynamic> item,
    String itemId,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ambil Donasi?"),
        content: Text(
          "Anda akan mengklaim donasi ${item['name']}. Relawan akan segera diarahkan untuk menjemputnya.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString('auth_token');

              try {
                final response = await http.post(
                  Uri.parse(
                    '${ApiConfig.baseUrl}/receiver/foods/$itemId/accept',
                  ),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                  },
                );

                if (response.statusCode == 200) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Donasi berhasil diambil!"),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // HARD RESTART: Balik ke Dashboard agar data ter-refresh
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReceiverDashboard(),
                    ),
                    (route) => false,
                  );
                } else {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal mengambil donasi."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                setState(() => _isLoading = false);
              }
            },
            child: const Text(
              "Ya, Ambil",
              style: TextStyle(
                color: Color(0xFF0F766E),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cari Makanan Tersedia",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F766E)),
            )
          : _availableFoods.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchAvailableFoods,
              color: const Color(0xFF0F766E),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _availableFoods.length,
                itemBuilder: (context, index) {
                  var item = _availableFoods[index];
                  var rawId = item['id'] ?? item['_id'];
                  String itemId = rawId != null
                      ? (rawId is Map
                            ? rawId['\$oid'].toString()
                            : rawId.toString())
                      : '';
                  String foodName =
                      item['name']?.toString() ?? 'Donasi Makanan';
                  String portion = item['portion']?.toString() ?? '0';

                  return _buildAvailableFoodCard(
                    title: foodName,
                    portion: "$portion Porsi",
                    imageUrl: item['photo_url']?.toString(),
                    onDetail: () async {
                      if (itemId.isEmpty) return;
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              IncomingFoodDetailPage(foodId: itemId),
                        ),
                      );
                      if (result == true) _fetchAvailableFoods();
                    },
                    onAccept: () => _acceptDonationDirectly(item, itemId),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Belum Ada Makanan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Saat ini belum ada donatur yang membagikan\nmakanan di sekitar Anda.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableFoodCard({
    required String title,
    required String portion,
    String? imageUrl,
    required VoidCallback onDetail,
    required VoidCallback onAccept,
  }) {
    String? fullImg;
    if (imageUrl != null && imageUrl.isNotEmpty)
      fullImg = "${ApiConfig.baseUrl.replaceAll('/api', '')}/$imageUrl";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.05),
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
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: fullImg != null
                      ? Image.network(
                          fullImg,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fastfood_rounded,
                            color: Color(0xFF0F766E),
                          ),
                        )
                      : const Icon(
                          Icons.fastfood_rounded,
                          color: Color(0xFF0F766E),
                        ),
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
                    const SizedBox(height: 4),
                    Text(
                      "Tersedia: $portion",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0F766E)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onDetail,
                  child: const Text(
                    "Detail",
                    style: TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onAccept,
                  child: const Text(
                    "Ambil Donasi",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
