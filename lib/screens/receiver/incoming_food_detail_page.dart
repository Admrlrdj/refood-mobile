import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  Map<String, dynamic> _foodData = {};

  @override
  void initState() {
    super.initState();
    _fetchFoodDetail();
  }

  Future<void> _fetchFoodDetail() async {
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

      if (response.statusCode == 200) {
        setState(() {
          _foodData = jsonDecode(response.body)['data'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptDonation() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ambil Donasi?"),
        content: Text(
          "Anda akan mengklaim donasi ${_foodData['name'] ?? 'ini'} sebanyak ${_foodData['portion'] ?? '0'} porsi. Relawan akan segera diarahkan untuk menjemput dan mengantarnya ke tempat Anda.",
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
                    '${ApiConfig.baseUrl}/receiver/foods/${widget.foodId}/accept',
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
                      content: Text(
                        "Berhasil! Donasi sedang diproses oleh Relawan.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true); // Kembali & Memicu Refresh
                } else {
                  final err = jsonDecode(response.body);
                  if (mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Gagal: ${err['message']}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Terjadi kesalahan jaringan"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
    if (_isLoading)
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0F766E)),
        ),
      );

    final foodName = _foodData['name']?.toString() ?? '-';
    final portion = _foodData['portion']?.toString() ?? '0';
    final note = _foodData['note']?.toString() ?? 'Tidak ada catatan tambahan.';
    final donorName = _foodData['donor'] != null
        ? _foodData['donor']['name']
        : 'Donatur';
    final status = _foodData['status']?.toString() ?? 'available';

    String collectionDateStr = "-";
    var rawDate = _foodData['collection_date'];
    if (rawDate != null) {
      try {
        DateTime parsedDate = (rawDate is Map && rawDate.containsKey('\$date'))
            ? DateTime.parse(rawDate['\$date'].toString()).toLocal()
            : DateTime.parse(rawDate.toString()).toLocal();
        collectionDateStr =
            "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        collectionDateStr = rawDate.toString();
      }
    }

    final imageUrl = _foodData['photo_url'];
    String? fullImageUrl;
    if (imageUrl != null && imageUrl.toString().isNotEmpty) {
      fullImageUrl = "${ApiConfig.baseUrl.replaceAll('/api', '')}/$imageUrl";
    }

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
          "Detail Makanan Masuk",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),

      // TOMBOL AMBIL DONASI HANYA MUNCUL JIKA STATUS MASIH 'AVAILABLE'
      bottomNavigationBar: status == 'available'
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _acceptDonation,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Ambil Donasi Ini",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            )
          : null,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      color: Color(0xFF0F766E),
                      size: 30,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Dari: $donorName",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Informasi Makanan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildDetailRow("Porsi Tersedia", "$portion Porsi"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  _buildDetailRow("Batas Waktu", collectionDateStr),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  _buildDetailRow("Catatan", note, isLong: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (fullImageUrl != null) ...[
              const Text(
                "Foto Makanan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.fastfood_rounded,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLong = false}) {
    return Row(
      crossAxisAlignment: isLong
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
