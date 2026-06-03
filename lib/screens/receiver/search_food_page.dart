import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';
import 'incoming_food_detail_page.dart';

class SearchFoodPage extends StatefulWidget {
  const SearchFoodPage({Key? key}) : super(key: key);

  @override
  _SearchFoodPageState createState() => _SearchFoodPageState();
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _allFoods = []; // Menyimpan semua data asli dari database
  List<dynamic> _filteredFoods = []; // Menyimpan data hasil pencarian/filter

  @override
  void initState() {
    super.initState();
    _fetchAvailableFoods(); // Ambil data saat halaman dibuka

    // Menambahkan pendengar (listener) agar setiap kali ada huruf diketik, fungsi filter berjalan
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================
  // FUNGSI 1: MENGAMBIL SEMUA DONASI TERSEDIA
  // ==========================================
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
          _allFoods = data;
          _filteredFoods = data; // Awalnya tampilkan semua
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ==========================================
  // FUNGSI 2: FILTER PENCARIAN REAL-TIME
  // ==========================================
  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredFoods = _allFoods.where((food) {
        // Kita bisa mencari berdasarkan Nama atau Kategori
        String name = (food['name'] ?? '').toLowerCase();
        String category = (food['category'] ?? '').toLowerCase();

        return name.contains(query) || category.contains(query);
      }).toList();
    });
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
          "Cari Donasi Makanan",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ================= SEARCH BAR =================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari Nasi Kotak, Kue, Sayuran...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF0F766E),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController
                                .clear(); // Tombol X untuk hapus teks
                          },
                        )
                      : Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ================= KONTEN HASIL PENCARIAN =================
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0F766E),
                      ),
                    )
                  : _filteredFoods.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? "Belum ada donasi yang tersedia saat ini."
                                : "Tidak menemukan makanan '${_searchController.text}'",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredFoods.length,
                      itemBuilder: (context, index) {
                        var item = _filteredFoods[index];
                        String itemId = item['_id'] is Map
                            ? item['_id']['\$oid']
                            : item['_id'].toString();

                        return _buildSearchCard(
                          title: item['name'],
                          category: item['category'] ?? 'Umum',
                          portion: item['portion'].toString(),
                          imageUrl: item['photo_url'],
                          onTap: () async {
                            // Saat diklik, arahkan ke detail untuk diambil
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    IncomingFoodDetailPage(foodId: itemId),
                              ),
                            );
                            // Refresh data ketika kembali dari detail (jika diambil, item tersebut akan hilang dari daftar)
                            _fetchAvailableFoods();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET KARTU HASIL PENCARIAN
  Widget _buildSearchCard({
    required String title,
    required String category,
    required String portion,
    String? imageUrl,
    required VoidCallback onTap,
  }) {
    String? fullImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      String serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');
      fullImageUrl = "$serverUrl/$imageUrl";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
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
                          color: Color(0xFF0F766E),
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood_rounded,
                        color: Color(0xFF0F766E),
                        size: 28,
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
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.category_rounded,
                        size: 14,
                        color: Color(0xFF0F766E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$portion Porsi",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
