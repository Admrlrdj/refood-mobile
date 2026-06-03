import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../core/api_config.dart';

class ReceiverHistoryPage extends StatefulWidget {
  final VoidCallback onBackPressed;
  const ReceiverHistoryPage({Key? key, required this.onBackPressed})
    : super(key: key);

  @override
  _ReceiverHistoryPageState createState() => _ReceiverHistoryPageState();
}

class _ReceiverHistoryPageState extends State<ReceiverHistoryPage> {
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
        Uri.parse('${ApiConfig.baseUrl}/receiver/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        Map<String, List<dynamic>> tempMap = {};

        for (var item in data) {
          DateTime date = DateTime.parse(item['updated_at']).toLocal();
          String formattedDate = DateFormat('dd MMMM yyyy').format(date);
          if (!tempMap.containsKey(formattedDate)) tempMap[formattedDate] = [];
          tempMap[formattedDate]!.add(item);
        }

        List<Map<String, dynamic>> finalGroupedList = [];
        tempMap.forEach(
          (key, value) => finalGroupedList.add({"date": key, "items": value}),
        );

        setState(() {
          _groupedHistory = finalGroupedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
          colors: [Color(0xFF2EA275), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
                          color: Color(0xFF0F766E),
                        ),
                      )
                    : _groupedHistory.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada riwayat penerimaan/request.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _groupedHistory.length,
                        itemBuilder: (context, index) {
                          final group = _groupedHistory[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group["date"],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...group["items"].asMap().entries.map((entry) {
                                  var item = entry.value;
                                  var statusInfo = _getStatusUI(item['status']);
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            item['donor_id'] == null
                                                ? Icons.campaign_rounded
                                                : Icons.fastfood_rounded,
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
                                      if (entry.key !=
                                          group["items"].length - 1)
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
