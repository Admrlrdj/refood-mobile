import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../core/api_config.dart';

class DonorHistoryPage extends StatefulWidget {
  final VoidCallback onBackPressed;

  const DonorHistoryPage({Key? key, required this.onBackPressed})
    : super(key: key);

  @override
  _DonorHistoryPageState createState() => _DonorHistoryPageState();
}

class _DonorHistoryPageState extends State<DonorHistoryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _groupedHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donor/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];

        // Mengelompokkan data berdasarkan tanggal
        Map<String, List<dynamic>> tempMap = {};

        for (var item in data) {
          // Parse tanggal dari MongoDB
          DateTime date = DateTime.parse(item['created_at']).toLocal();
          String formattedDate = DateFormat(
            'dd MMMM yyyy',
          ).format(date); // cth: 15 Maret 2026

          if (!tempMap.containsKey(formattedDate)) {
            tempMap[formattedDate] = [];
          }
          tempMap[formattedDate]!.add(item);
        }

        // Konversi map menjadi list sesuai dengan UI
        List<Map<String, dynamic>> finalGroupedList = [];
        tempMap.forEach((key, value) {
          finalGroupedList.add({"date": key, "items": value});
        });

        setState(() {
          _groupedHistory = finalGroupedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching history: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Translasi status warna
  Map<String, dynamic> _getStatusUI(String status) {
    switch (status) {
      case 'available':
        return {"text": "Menunggu Donasi", "color": Colors.blue};
      case 'accepted':
      case 'on_delivery':
        return {"text": "Sedang Diantar", "color": Colors.orange};
      case 'completed':
        return {"text": "Berhasil", "color": Colors.green};
      case 'cancelled':
        return {"text": "Gagal", "color": Colors.red};
      default:
        return {"text": status, "color": Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF86D538), Color(0xFF56AB2F)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: widget.onBackPressed,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Riwayat",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // LIST KONTEN
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2E7D32),
                        ),
                      )
                    : _groupedHistory.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada riwayat donasi.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _groupedHistory.length,
                        itemBuilder: (context, index) {
                          final group = _groupedHistory[index];
                          final date = group["date"];
                          final items = group["items"] as List<dynamic>;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                ...items.asMap().entries.map((entry) {
                                  int itemIndex = entry.key;
                                  var item = entry.value;
                                  var statusInfo = _getStatusUI(item['status']);

                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.fastfood_rounded,
                                            color: Colors.black87,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              item["name"],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                statusInfo["text"],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  color: statusInfo["color"],
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "${item['portion']} Porsi",
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (itemIndex != items.length - 1)
                                        const Divider(
                                          height: 32,
                                          thickness: 1,
                                          color: Color(0xFFEEEEEE),
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
