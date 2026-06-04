import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';

class EditDonationPage extends StatefulWidget {
  final Map<String, dynamic> donationData;

  const EditDonationPage({Key? key, required this.donationData})
    : super(key: key);

  @override
  _EditDonationPageState createState() => _EditDonationPageState();
}

class _EditDonationPageState extends State<EditDonationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers untuk Form
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _portionController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    // Pre-fill data (Isi otomatis kolom dengan data sebelumnya)
    _nameController = TextEditingController(
      text: widget.donationData['name']?.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.donationData['category']?.toString() ?? 'Umum',
    );
    _portionController = TextEditingController(
      text: widget.donationData['portion']?.toString() ?? '',
    );
    _noteController = TextEditingController(
      text: widget.donationData['note']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _portionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Ambil ID yang kebal dari format MongoDB
    var rawId = widget.donationData['id'] ?? widget.donationData['_id'];
    String donationId = rawId is Map
        ? rawId['\$oid'].toString()
        : rawId.toString();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/donor/foods/$donationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json', // PENTING untuk kirim data JSON
        },
        body: jsonEncode({
          'name': _nameController.text,
          'category': _categoryController.text,
          'portion': _portionController.text,
          'note': _noteController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Donasi berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Kembali & lempar nilai 'true' agar Dashboard ter-refresh
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal: ${errorData['message'] ?? 'Terjadi kesalahan'}",
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Terjadi kesalahan koneksi"),
          backgroundColor: Colors.red,
        ),
      );
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
          "Edit Donasi",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _isLoading ? null : _updateDonation,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Anda hanya bisa mengubah detail donasi yang berstatus 'Menunggu'.",
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildInputLabel("Nama Makanan"),
              TextFormField(
                controller: _nameController,
                decoration: _inputStyle(
                  "Misal: Nasi Goreng Spesial",
                  Icons.fastfood_rounded,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama makanan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel("Kategori"),
                        TextFormField(
                          controller: _categoryController,
                          decoration: _inputStyle(
                            "Misal: Makanan Berat",
                            Icons.category_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel("Jumlah Porsi"),
                        TextFormField(
                          controller: _portionController,
                          keyboardType: TextInputType.number,
                          decoration: _inputStyle(
                            "Misal: 10",
                            Icons.restaurant_rounded,
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Porsi wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildInputLabel("Catatan Khusus (Opsional)"),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: _inputStyle(
                  "Beri tahu informasi tambahan terkait kondisi makanan, kepedasan, dll.",
                  Icons.notes_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
      ),
    );
  }
}
