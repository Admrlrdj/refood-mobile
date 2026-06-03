import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';

class EditRequestPage extends StatefulWidget {
  final Map<String, dynamic> foodData;

  const EditRequestPage({Key? key, required this.foodData}) : super(key: key);

  @override
  _EditRequestPageState createState() => _EditRequestPageState();
}

class _EditRequestPageState extends State<EditRequestPage> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _portionController;
  late TextEditingController _noteController;

  DateTime? _collectionDate;
  TimeOfDay? _collectionTime;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodData['name']);
    _categoryController = TextEditingController(
      text: widget.foodData['category'],
    );
    _portionController = TextEditingController(
      text: widget.foodData['portion'].toString(),
    );
    _noteController = TextEditingController(text: widget.foodData['note']);

    DateTime parsedDate = DateTime.parse(
      widget.foodData['collection_date'],
    ).toLocal();
    _collectionDate = parsedDate;
    _collectionTime = TimeOfDay.fromDateTime(parsedDate);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _collectionDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 60),
      ), // Batas butuh lebih lama
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Mengubah warna tema DatePicker menjadi hijau receiver
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
        initialTime: _collectionTime ?? TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _collectionDate = pickedDate;
          _collectionTime = pickedTime;
        });
      }
    }
  }

  Future<void> _updateRequest() async {
    setState(() => _isLoading = true);

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

      // Extract ID secara aman dari objek BSON MongoDB
      String id = widget.foodData['_id'] is Map
          ? widget.foodData['_id']['\$oid']
          : widget.foodData['_id'];

      // --- MENGUBAH URL API SESUAI DENGAN ROUTES RECEIVER ---
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/receiver/foods/request/$id'),
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

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request berhasil diupdate!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal mengupdate request"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Request", // Mengubah teks header
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
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFE0F2FE,
                  ), // Warna background foto disesuaikan
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(
                      0xFF0F766E,
                    ).withOpacity(0.5), // Warna border disesuaikan
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
                    ? const Center(
                        child: Text(
                          "Ganti Foto (Opsional)",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F766E),
                          ), // Warna disesuaikan
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 32),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Apa yang Anda butuhkan?",
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: "Kategori",
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _portionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Jumlah Kebutuhan Porsi",
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${DateFormat('dd MMM yyyy').format(_collectionDate!)} - ${_collectionTime!.format(context)}",
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Alasan / Catatan",
                filled: true,
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF0F766E,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : _updateRequest,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Perubahan",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
