import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';
import '../widgets/map_picker_page.dart';

class ReceiverEditProfilePage extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const ReceiverEditProfilePage({Key? key, required this.currentData})
    : super(key: key);

  @override
  _ReceiverEditProfilePageState createState() =>
      _ReceiverEditProfilePageState();
}

class _ReceiverEditProfilePageState extends State<ReceiverEditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _picController;
  late TextEditingController _capacityController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.currentData['name'] ?? '',
    );
    _picController = TextEditingController(
      text: widget.currentData['pic_name'] ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.currentData['capacity_people']?.toString() ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.currentData['phone'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.currentData['address'] ?? '',
    );
  }

  // ==========================================
  // FUNGSI: MEMANGGIL MAP PICKER ASLI
  // ==========================================
  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerPage()),
    );

    if (result != null) {
      setState(() {
        if (result is Map) {
          _addressController.text = result['address']?.toString() ?? '';
        } else {
          _addressController.text = result.toString();
        }
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/receiver/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': _nameController.text,
              'pic_name': _picController.text,
              'capacity_people': int.tryParse(_capacityController.text) ?? 0,
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
        Navigator.pop(context, true);
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
            _buildLabel("Nama Yayasan / Instansi"),
            _buildTextField(
              "Cth: Panti Asuhan Kasih Bunda",
              controller: _nameController,
            ),

            _buildLabel("Nama PIC (Penanggung Jawab)"),
            _buildTextField("Cth: Budi Santoso", controller: _picController),

            _buildLabel("Kapasitas Orang"),
            _buildTextField(
              "Cth: 50",
              controller: _capacityController,
              keyboardType: TextInputType.number,
            ),

            _buildLabel("No. WhatsApp"),
            _buildTextField(
              "Cth: 081234567890",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),

            _buildLabel("Alamat Lengkap"),

            // TOMBOL PILIH DARI MAPS
            GestureDetector(
              onTap: _openMapPicker,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFE0F2FE,
                  ), // Background Biru Pucat (Teal tone)
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0F766E).withOpacity(0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.map_rounded, color: Color(0xFF0F766E)),
                    SizedBox(width: 12),
                    Text(
                      "Pilih dari Peta (Maps)",
                      style: TextStyle(
                        color: Color(0xFF0F766E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF0F766E),
                    ),
                  ],
                ),
              ),
            ),

            // TEXTFIELD ALAMAT
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
