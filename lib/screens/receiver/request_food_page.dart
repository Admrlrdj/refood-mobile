import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';

class RequestFoodPage extends StatefulWidget {
  const RequestFoodPage({Key? key}) : super(key: key);

  @override
  _RequestFoodPageState createState() => _RequestFoodPageState();
}

class _RequestFoodPageState extends State<RequestFoodPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _portionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  DateTime? _collectionDate;
  TimeOfDay? _collectionTime;

  File? _imageFile;
  bool _isLoading = false;
  bool _isFetchingAddress = true;

  @override
  void initState() {
    super.initState();
    _fetchReceiverAddress();
  }

  // Mengambil alamat otomatis dari profil Penerima
  Future<void> _fetchReceiverAddress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/receiver/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body)['data'];
        setState(() {
          _addressController.text =
              profileData['address'] ?? 'Alamat belum diatur di profil';
          _isFetchingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _addressController.text = 'Gagal memuat alamat dari profil';
        _isFetchingAddress = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 60),
      ), // Batas waktu butuh
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F766E),
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
          _collectionDate = pickedDate;
          _collectionTime = pickedTime;
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _portionController.text.isEmpty ||
        _collectionDate == null ||
        _collectionTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi semua data wajib!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      DateTime combinedDateTime = DateTime(
        _collectionDate!.year,
        _collectionDate!.month,
        _collectionDate!.day,
        _collectionTime!.hour,
        _collectionTime!.minute,
      );
      String formattedCollectionDate = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(combinedDateTime);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/receiver/foods/request'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['name'] = _nameController.text;
      request.fields['category'] = _categoryController.text;
      request.fields['portion'] = _portionController.text;
      request.fields['collection_date'] = formattedCollectionDate;
      request.fields['note'] = _noteController.text;

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', _imageFile!.path),
        );
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      var response = await http.Response.fromStream(streamedResponse);
      var responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request makanan berhasil dikirim!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Gagal mengirim request"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan jaringan: $e"),
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
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _portionController.dispose();
    _noteController.dispose();
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
          "Request Makanan",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upload Foto Pendukung (Opsional)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE), // Biru pucat khas Receiver
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0F766E).withOpacity(0.5),
                    width: 2,
                  ),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Color(0xFF0F766E),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Klik untuk upload foto",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Cth: Foto panti asuhan/acara",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF0F766E),
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              "Detail Kebutuhan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel("Apa yang Anda butuhkan?"),
            _buildTextField(
              "Cth: Nasi Kotak, Bahan Pokok...",
              controller: _nameController,
            ),

            _buildLabel("Kategori"),
            _buildTextField(
              "Cth: Makanan Berat / Minuman / Mentah",
              controller: _categoryController,
            ),

            _buildLabel("Jumlah Kebutuhan"),
            _buildTextField(
              "Cth: 50",
              controller: _portionController,
              keyboardType: TextInputType.number,
            ),

            _buildLabel("Kapan Dibutuhkan? (Collection Date)"),
            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _collectionDate != null && _collectionTime != null
                          ? "${DateFormat('dd MMM yyyy').format(_collectionDate!)} - ${_collectionTime!.format(context)}"
                          : "Pilih tanggal & waktu",
                      style: TextStyle(
                        color: _collectionDate != null
                            ? Colors.black87
                            : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: _collectionDate != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF0F766E),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            _buildLabel("Alasan / Catatan Kebutuhan"),
            _buildTextField(
              "Cth: Untuk acara buka puasa bersama anak panti...",
              controller: _noteController,
              maxLines: 2,
            ),

            const SizedBox(height: 32),
            const Text(
              "Lokasi Pengiriman",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Relawan akan mengantar bantuan ke alamat profil Anda.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            _isFetchingAddress
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F766E)),
                  )
                : _buildTextField(
                    "Memuat alamat...",
                    controller: _addressController,
                    maxLines: 3,
                    readOnly: true,
                  ),

            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2EA275), Color(0xFF0F766E)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withOpacity(0.3),
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
                onPressed: _isLoading ? null : _submitRequest,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Kirim Request",
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          filled: true,
          fillColor: readOnly ? Colors.grey[200] : Colors.grey[100],
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
