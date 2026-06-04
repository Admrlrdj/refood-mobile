import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';

class DonationDetailPage extends StatefulWidget {
  final String donationId;

  const DonationDetailPage({Key? key, required this.donationId})
    : super(key: key);

  @override
  _DonationDetailPageState createState() => _DonationDetailPageState();
}

class _DonationDetailPageState extends State<DonationDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic> _donationData = {};

  @override
  void initState() {
    super.initState();
    _fetchDonationDetail();
  }

  Future<void> _fetchDonationDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donor/foods/${widget.donationId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _donationData = jsonDecode(response.body)['data'] ?? {};
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error detail donasi: $e");
    }
  }

  Future<void> _deleteDonation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Donasi?"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus atau membatalkan donasi makanan ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kembali"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              final res = await http.delete(
                Uri.parse(
                  '${ApiConfig.baseUrl}/donor/foods/${widget.donationId}',
                ),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                },
              );

              if (res.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Donasi berhasil dibatalkan"),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context, true); // Pulang ke dashboard & refresh
              }
            },
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    final foodName = _donationData['name'] ?? 'Donasi Makanan';
    final portion = _donationData['portion']?.toString() ?? '0';
    final description = _donationData['description'] ?? 'Tidak ada deskripsi.';
    final status = _donationData['status'] ?? 'pending';
    final imageUrl = _donationData['photo_url'];

    String? fullImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
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
          "Detail Donasi Anda",
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
            // IMAGE CONTAINER
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
                          Icons.fastfood_rounded,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood_rounded,
                        size: 50,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // INFO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    foodName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$portion Porsi",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    "Status Donasi",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    "Deskripsi Makanan",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            if (status == 'available' || status == 'waiting_donor')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _deleteDonation,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Batalkan Donasi Ini",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
