import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/api_config.dart';

class IncomingFoodDetailPage extends StatefulWidget {
  final String foodId;

  const IncomingFoodDetailPage({Key? key, required this.foodId})
    : super(key: key);

  @override
  _IncomingFoodDetailPageState createState() => _IncomingFoodDetailPageState();
}

class _IncomingFoodDetailPageState extends State<IncomingFoodDetailPage> {
  bool _isLoading = true;
  bool _isAccepting = false;
  Map<String, dynamic>? _foodData;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/receiver/foods/${widget.foodId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200)
        setState(() {
          _foodData = jsonDecode(response.body)['data'];
          _isLoading = false;
        });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptDonation() async {
    setState(() => _isAccepting = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/receiver/foods/${widget.foodId}/accept'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil! Menunggu relawan menjemput donasi."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Refresh dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal mengambil donasi."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0F766E)),
        ),
      );
    if (_foodData == null)
      return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));

    String? fullImageUrl;
    if (_foodData!['photo_url'] != null)
      fullImageUrl =
          "${ApiConfig.baseUrl.replaceAll('/api', '')}/${_foodData!['photo_url']}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Donasi",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: fullImageUrl != null
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fastfood,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.fastfood, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _foodData!['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _foodData!['category'],
                style: const TextStyle(
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              "Jumlah Porsi",
              "${_foodData!['portion']} Porsi",
              Icons.restaurant_menu,
            ),
            _buildDetailRow(
              "Tenggat Waktu",
              DateFormat(
                'EEEE, dd MMM yyyy - HH:mm',
                'id_ID',
              ).format(DateTime.parse(_foodData!['collection_date']).toLocal()),
              Icons.calendar_month,
            ),
            _buildDetailRow(
              "Catatan",
              _foodData!['note'] ?? 'Tidak ada catatan',
              Icons.notes,
            ),
            const SizedBox(height: 40),

            if (_foodData!['status'] == 'available')
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isAccepting ? null : _acceptDonation,
                  child: _isAccepting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Ambil / Terima Donasi",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
