import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/api_config.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';

class DonorProfilePage extends StatefulWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onLogout;

  const DonorProfilePage({
    Key? key,
    required this.onBackPressed,
    required this.onLogout,
  }) : super(key: key);

  @override
  _DonorProfilePageState createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // MENGAMBIL DATA PROFIL DARI BACKEND LARAVEL
  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donor/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _profileData = jsonDecode(response.body)['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal bergabung
    String joinDate = "Memuat...";
    if (_profileData['created_at'] != null) {
      DateTime parsedDate = DateTime.parse(
        _profileData['created_at'],
      ).toLocal();
      joinDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(parsedDate);
      // Catatan: Jika error 'id_ID', hapus parameter 'id_ID' dan biarkan default.
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF86D538), Color(0xFF14532D)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
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
                          "Profil",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // NAMA & FOTO
                  const SizedBox(height: 10),
                  Text(
                    _profileData['username'] ?? "Donatur",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.blueGrey,
                          child: Icon(
                            Icons.person,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // TOMBOL MENUJU HALAMAN EDIT PROFIL
                  GestureDetector(
                    onTap: () async {
                      // Menunggu halaman edit ditutup, jika 'true' maka fetch ulang data profil
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfilePage(currentData: _profileData),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          _isLoading = true;
                        });
                        _fetchProfile(); // Refresh Data
                      }
                    },
                    child: const Text(
                      "Edit Profil",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // KONTEN BODY (Putih)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // KARTU DATA PROFIL DARI DATABASE
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Data Profil",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildProfileRow(
                                    "Status Akun",
                                    _profileData['is_verified'] == true
                                        ? "Terverifikasi"
                                        : "Menunggu Verifikasi",
                                  ),
                                  const SizedBox(height: 12),
                                  _buildProfileRow(
                                    "Nama PIC",
                                    _profileData['name'] ?? '-',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildProfileRow(
                                    "Restoran/Toko",
                                    _profileData['restaurant_name'] ?? '-',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildProfileRow(
                                    "No. HP",
                                    _profileData['phone'] ?? '-',
                                  ),
                                  const SizedBox(height: 12),
                                  _buildProfileRow(
                                    "Alamat",
                                    _profileData['address'] ?? '-',
                                    isLongText: true,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildProfileRow("Bergabung", joinDate),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildMenuCard(
                              icon: Icons.settings_rounded,
                              title: "Pengaturan",
                              onTap: () async {
                                // Navigasi ke halaman Settings
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingsPage(
                                      currentUsername:
                                          _profileData['username'] ?? '',
                                    ),
                                  ),
                                );
                                // Jika pengaturan berhasil disimpan (result == true), refresh data profil
                                if (result == true) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _fetchProfile();
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildMenuCard(
                              icon: Icons.privacy_tip_rounded,
                              title: "Privasi Akun",
                            ),
                            const SizedBox(height: 40),

                            // TOMBOL SIGN OUT
                            Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF86D538),
                                    Color(0xFF4CAF50),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: widget.onLogout,
                                child: const Text(
                                  "Sign Out",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileRow(
    String label,
    String value, {
    bool isLongText = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            maxLines: isLongText ? 3 : 1,
            overflow: isLongText ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap, // Menambahkan fungsi onTap agar bisa diklik
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
