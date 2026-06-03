import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_config.dart';
import '../widgets/map_picker_page.dart';
import 'login_page.dart';

class RegisterVolunteerPage extends StatefulWidget {
  const RegisterVolunteerPage({Key? key}) : super(key: key);

  @override
  _RegisterVolunteerPageState createState() => _RegisterVolunteerPageState();
}

class _RegisterVolunteerPageState extends State<RegisterVolunteerPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List<String> _vehicleOptions = [
    'Motor',
    'Mobil',
    'Sepeda',
    'Tidak Ada',
  ];
  String _selectedVehicle = 'Motor';

  bool _isLoading = false;
  bool _obsPassword = true;
  bool _obsConfirm = true;

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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap pilih lokasi atau isi alamat!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/register/volunteer'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': _usernameController.text,
              'email': _emailController.text,
              'password': _passwordController.text,
              'password_confirmation': _confirmPasswordController.text,
              'name': _nameController.text,
              'phone': _phoneController.text,
              'vehicle': _selectedVehicle,
              'address': _addressController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil! Silakan login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Registrasi gagal"),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Daftar Relawan",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Mari bergabung menjadi pahlawan pangan dan antarkan kebaikan.",
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),

              _buildLabel("Informasi Akun"),
              _buildTextField("Username", controller: _usernameController),
              _buildTextField(
                "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              _buildPasswordField(
                "Password",
                controller: _passwordController,
                isObscure: _obsPassword,
                onToggle: () => setState(() => _obsPassword = !_obsPassword),
              ),
              _buildPasswordField(
                "Konfirmasi Password",
                controller: _confirmPasswordController,
                isObscure: _obsConfirm,
                onToggle: () => setState(() => _obsConfirm = !_obsConfirm),
              ),

              const SizedBox(height: 16),
              _buildLabel("Data Diri & Kendaraan"),
              _buildTextField("Nama Lengkap", controller: _nameController),
              _buildTextField(
                "No. Handphone",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 8),
              const Text(
                "Kendaraan Utama",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedVehicle,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
                    items: _vehicleOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => _selectedVehicle = newValue!),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildLabel("Alamat Domisili"),
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
              _buildTextField(
                "Ketik alamat detail...",
                controller: _addressController,
                maxLines: 3,
              ),

              const SizedBox(height: 40),
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
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Daftar Sekarang",
                          style: TextStyle(
                            fontSize: 16,
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? 'Tidak boleh kosong' : null,
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

  Widget _buildPasswordField(
    String hint, {
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        validator: (value) => value!.length < 6 ? 'Minimal 6 karakter' : null,
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
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[500],
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
