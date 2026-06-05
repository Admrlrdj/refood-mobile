import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api_config.dart';

class JobDetailPage extends StatefulWidget {
  final String jobId;

  const JobDetailPage({Key? key, required this.jobId}) : super(key: key);

  @override
  _JobDetailPageState createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic> _jobData = {};

  // 0 = Belum Diambil, 1 = Menuju Donatur, 2 = Menuju Yayasan, 3 = Selesai
  int _currentPhase = 0;

  @override
  void initState() {
    super.initState();
    _fetchJobDetail();
  }

  Future<void> _fetchJobDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Cek apakah relawan sudah memencet "Makanan Diambil" secara lokal
    bool isPickedUp = prefs.getBool('job_${widget.jobId}_picked') ?? false;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/volunteer/jobs/${widget.jobId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        int phase = 0;

        if (data['status'] == 'accepted')
          phase = 0;
        else if (data['status'] == 'on_delivery')
          phase = isPickedUp ? 2 : 1;
        else if (data['status'] == 'completed')
          phase = 3;

        setState(() {
          _jobData = data;
          _currentPhase = phase;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptJob() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/volunteer/jobs/${widget.jobId}/accept'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentPhase = 1; // Ubah langsung ke Fase 1 (Menuju Donatur)
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tugas berhasil diambil! Segera menuju ke Donatur."),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsPickedUp() async {
    // Simpan status lokal bahwa makanan sudah di tangan relawan
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('job_${widget.jobId}_picked', true);

    setState(() {
      _currentPhase = 2; // Pindah Peta ke Fase 2 (Menuju Yayasan)
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Makanan berhasil diambil! Lanjutkan perjalanan ke Yayasan.",
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _completeJob() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selesaikan Tugas?"),
        content: const Text(
          "Pastikan makanan telah diserahkan dengan aman ke pihak Yayasan Penerima.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
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
                    '${ApiConfig.baseUrl}/volunteer/jobs/${widget.jobId}/status',
                  ),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                  },
                  body: {'status': 'completed'},
                );

                if (response.statusCode == 200) {
                  // Hapus cache lokal
                  await prefs.remove('job_${widget.jobId}_picked');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Luar biasa! Tugas pengantaran selesai."),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true); // Auto-Refresh Dashboard
                } else {
                  setState(() => _isLoading = false);
                }
              } catch (e) {
                setState(() => _isLoading = false);
              }
            },
            child: const Text(
              "Ya, Selesai!",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi Ajaib untuk Buka Google Maps
  Future<void> _openGoogleMaps(String address) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tidak dapat membuka Maps. Pastikan aplikasi Google Maps terinstal.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );

    final foodName = _jobData['name'] ?? '-';
    final portion = _jobData['portion']?.toString() ?? '0';
    final donorName = _jobData['donor']?['name'] ?? 'Donatur';
    final donorAddress =
        _jobData['donor']?['address'] ?? 'Alamat Donatur Belum Lengkap';
    final receiverName = _jobData['receiver']?['name'] ?? 'Yayasan';
    final receiverAddress =
        _jobData['receiver']?['address'] ?? 'Alamat Yayasan Belum Lengkap';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          "Detail Pengantaran",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),

      // BOTTOM NAVBAR ACTIONS BERDASARKAN FASE
      bottomNavigationBar: _buildBottomAction(donorAddress, receiverAddress),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFORMASI MAKANAN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delivery_dining_rounded,
                      color: Colors.white,
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
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Total: $portion Porsi",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              "Rute Pengantaran (Map Route)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // VISUALISASI MAP ROUTE
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _buildRouteTimeline(
                donorName,
                donorAddress,
                receiverName,
                receiverAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LOGIKA RUTE PETA BERDASARKAN FASE
  Widget _buildRouteTimeline(
    String dName,
    String dAddress,
    String rName,
    String rAddress,
  ) {
    if (_currentPhase == 0 || _currentPhase == 1) {
      // FASE 1: LOKASI RELAWAN -> DONATUR
      return Column(
        children: [
          _buildNode(
            title: "Lokasi Anda Saat Ini",
            subtitle: "Bersiap menuju titik jemput",
            icon: Icons.my_location_rounded,
            color: Colors.blue,
            isActive: true,
          ),
          _buildLine(isActive: _currentPhase == 1),
          _buildNode(
            title: "Titik Jemput: $dName",
            subtitle: dAddress,
            icon: Icons.storefront_rounded,
            color: Colors.orange,
            isActive: _currentPhase == 1,
          ),
          _buildLine(isActive: false),
          _buildNode(
            title: "Tujuan: $rName",
            subtitle: rAddress,
            icon: Icons.maps_home_work_rounded,
            color: Colors.grey,
            isActive: false,
          ),
        ],
      );
    } else {
      // FASE 2 & 3: DONATUR -> YAYASAN PENERIMA
      return Column(
        children: [
          _buildNode(
            title: "Titik Jemput: $dName",
            subtitle: "Makanan telah diambil",
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            isActive: false,
          ),
          _buildLine(isActive: true, color: Colors.green),
          _buildNode(
            title: "Posisi Makanan (Anda)",
            subtitle: "Dalam perjalanan ke yayasan",
            icon: Icons.local_shipping_rounded,
            color: Colors.blue,
            isActive: true,
          ),
          _buildLine(isActive: _currentPhase >= 2),
          _buildNode(
            title: "Tujuan: $rName",
            subtitle: rAddress,
            icon: Icons.maps_home_work_rounded,
            color: Colors.purple,
            isActive: _currentPhase >= 2,
          ),
        ],
      );
    }
  }

  Widget _buildNode({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? color : Colors.grey, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isActive ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isActive ? Colors.grey.shade700 : Colors.grey,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLine({required bool isActive, Color color = Colors.blue}) {
    return Container(
      margin: const EdgeInsets.only(left: 19, top: 8, bottom: 8),
      height: 30,
      width: 2,
      color: isActive ? color : Colors.grey.shade200,
    );
  }

  // LOGIKA TOMBOL BOTTOM SHEET (AMBIL, BUKA MAPS, SELESAI)
  Widget? _buildBottomAction(String dAddress, String rAddress) {
    if (_currentPhase == 0) {
      return _bottomContainer(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
          ),
          onPressed: _acceptJob,
          child: const Text(
            "Ambil Tugas Ini",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else if (_currentPhase == 1) {
      return _bottomContainer(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map_rounded),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade800,
                  side: BorderSide(color: Colors.blue.shade800),
                ),
                onPressed: () => _openGoogleMaps(dAddress),
                label: const Text("Buka Rute Map ke Donatur"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                ),
                onPressed: _markAsPickedUp,
                child: const Text(
                  "Makanan Telah Diambil",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_currentPhase == 2) {
      return _bottomContainer(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map_rounded),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: const BorderSide(color: Colors.purple),
                ),
                onPressed: () => _openGoogleMaps(rAddress),
                label: const Text("Buka Rute Map ke Yayasan"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _completeJob,
                child: const Text(
                  "Selesaikan Pengantaran",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return null; // Fase 3 (Completed) tidak ada tombol
  }

  Widget _bottomContainer(Widget child) {
    return Container(
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
      child: child,
    );
  }
}
