import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> currentData; // Menerima data profil saat ini

  const EditProfilePage({Key? key, required this.currentData})
    : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _restaurantController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mengisi form dengan data dari database
    _nameController = TextEditingController(text: widget.currentData['name']);
    _restaurantController = TextEditingController(
      text: widget.currentData['restaurant_name'] ?? '',
    );
    _phoneController = TextEditingController(text: widget.currentData['phone']);
    _addressController = TextEditingController(
      text: widget.currentData['address'],
    );
  }

  // ==========================================
  // FUNGSI: SIMULASI MEMILIH DARI MAPS
  // ==========================================
  Future<void> _openMapPicker() async {
    // Menampilkan Bottom Sheet sebagai simulasi Google Maps
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Pilih Titik Lokasi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Mockup Peta (Nanti diganti package google_maps_flutter)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://www.google.com/maps/d/thumbnail?mid=1v-T6tYFwJ-D4-3k2Cj_w5A_6mEw&hl=en",
                      ),
                      fit: BoxFit.cover,
                      opacity: 0.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.location_on, size: 50, color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tombol Konfirmasi Lokasi Peta
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    // MENGISI ALAMAT OTOMATIS BERDASARKAN TITIK PETA
                    setState(() {
                      _addressController.text =
                          "Jl. Raya Pajajaran No.1, RT.04/RW.11, Babakan, Kecamatan Bogor Tengah, Kota Bogor, Jawa Barat 16128";
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Gunakan Lokasi Ini",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // FUNGSI: UPDATE PROFIL KE LARAVEL
  // ==========================================
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/donor/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': _nameController.text,
              'restaurant_name': _restaurantController.text,
              'phone': _phoneController.text,
              'address': _addressController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Mengirim parameter 'true' agar halaman sebelumnya me-refresh data
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Gagal update profil"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nama PIC"),
            _buildTextField("Cth: Budi Santoso", controller: _nameController),

            _buildLabel("Nama Restoran/Toko"),
            _buildTextField(
              "Cth: Warung Nasi Budi",
              controller: _restaurantController,
            ),

            _buildLabel("No. WhatsApp"),
            _buildTextField(
              "Cth: 081234567890",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),

            _buildLabel("Alamat Lengkap"),
            // Tombol Maps
            GestureDetector(
              onTap: _openMapPicker,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF86D538).withOpacity(0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.map_rounded, color: Color(0xFF2E7D32)),
                    SizedBox(width: 12),
                    Text(
                      "Pilih dari Peta (Maps)",
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
            ),
            // Textfield Alamat (Bisa diketik manual, atau otomatis terisi dari Maps)
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Atau ketik alamat detail secara manual...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Perubahan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
