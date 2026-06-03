import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Jika merah, jalankan 'flutter pub add intl'

class AddDonationPage extends StatefulWidget {
  const AddDonationPage({Key? key}) : super(key: key);

  @override
  _AddDonationPageState createState() => _AddDonationPageState();
}

class _AddDonationPageState extends State<AddDonationPage> {
  // Controller untuk field teks (Sesuai dengan collection 'foods')
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _portionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DateTime? _expiredDate;
  TimeOfDay? _expiredTime;

  // Fungsi untuk memunculkan kalender dan jam
  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32), // Hijau utama kalender
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _expiredDate = pickedDate;
          _expiredTime = pickedTime;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _portionController.dispose();
    _addressController.dispose();
    super.dispose();
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
          "Form Donasi Makanan",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SECTION 1: UPLOAD FOTO =================
            const Text("Upload Foto Makanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // TODO: Implementasi image_picker di sini
              },
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8EC), // Hijau sangat pucat
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF86D538).withOpacity(0.5), width: 2),
                  // Catatan: Jika ingin efek garis putus-putus (dashed), bisa pakai package 'dotted_border'
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                      child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF56AB2F), size: 30),
                    ),
                    const SizedBox(height: 12),
                    const Text("Klik untuk upload foto", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                    const SizedBox(height: 4),
                    Text("Format: JPG, PNG (Max 5MB)", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),

            // ================= SECTION 2: INFORMASI MAKANAN =================
            const Text("Informasi Makanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
            const SizedBox(height: 16),
            
            _buildLabel("Nama Makanan"),
            _buildTextField("Cth: Nasi Kotak Ayam Bakar", controller: _nameController),
            
            _buildLabel("Deskripsi Singkat"),
            _buildTextField("Cth: Nasi kotak sisa acara seminar, kondisi masih sangat baik...", controller: _descController, maxLines: 3),
            
            _buildLabel("Jumlah Porsi"),
            _buildTextField("Cth: 15", controller: _portionController, keyboardType: TextInputType.number),
            
            _buildLabel("Waktu Kadaluarsa (Batas Konsumsi)"),
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _expiredDate != null && _expiredTime != null
                          ? "${DateFormat('dd MMM yyyy').format(_expiredDate!)} - ${_expiredTime!.format(context)}"
                          : "Pilih tanggal & waktu",
                      style: TextStyle(
                        color: _expiredDate != null ? Colors.black87 : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: _expiredDate != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const Icon(Icons.access_time_filled_rounded, color: Color(0xFF56AB2F)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ================= SECTION 3: LOKASI PENJEMPUTAN =================
            const Text("Lokasi Penjemputan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
            const SizedBox(height: 16),
            
            _buildLabel("Alamat Lengkap"),
            _buildTextField("Masukkan alamat detail penjemputan", controller: _addressController, maxLines: 2),

            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // TODO: Buka Google Maps / Place Picker untuk set latitude & longitude
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // Hijau terang
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF86D538).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: Color(0xFF2E7D32)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Pilih Titik Lokasi (Maps)",
                        style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF2E7D32), size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ================= TOMBOL SUBMIT =================
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF86D538), Color(0xFF2E7D32)],
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  // TODO: Implement API Post Data Food ke Laravel
                },
                child: const Text("Submit Donasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
    );
  }

  Widget _buildTextField(String hint, {required TextEditingController controller, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }
}