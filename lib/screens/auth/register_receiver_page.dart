import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/api_config.dart';
import '../widgets/map_picker_page.dart'; // Pastikan import MapPickerPage untuk navigasi ke peta

class RegisterReceiverPage extends StatefulWidget {
  const RegisterReceiverPage({Key? key}) : super(key: key);

  @override
  State<RegisterReceiverPage> createState() => _RegisterReceiverPageState();
}

class _RegisterReceiverPageState extends State<RegisterReceiverPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _picNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Dropdown values
  String? _selectedType;
  String? _selectedNeedLevel;

  final List<String> _typeOptions = [
    'Panti Asuhan',
    'Komunitas',
    'Keluarga',
    'Individu',
  ];
  final List<String> _needOptions = ['Tinggi', 'Sedang', 'Rendah'];

  Future<void> _handleRegister() async {
    // Validasi form kosong
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _selectedType == null ||
        _selectedNeedLevel == null ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi semua data wajib!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password dan Konfirmasi Password tidak cocok!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Pastikan Endpoint sesuai dengan backend Laravel Anda
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register/receiver'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'username': _usernameController.text,
          'type': _selectedType,
          'pic_name': _picNameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'capacity_people': int.tryParse(_capacityController.text) ?? 0,
          'need_level': _selectedNeedLevel,
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi Penerima Berhasil! Silakan Login."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman Login
      } else {
        String errorMessage = "Registrasi Gagal.";
        if (responseData['errors'] != null) {
          errorMessage = responseData['errors'].values.first[0];
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan koneksi: $e"),
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
    _usernameController.dispose();
    _picNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Melengkung
            ClipPath(
              clipper: RegisterHeaderClipper(),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF86D538), Color(0xFF2E7D32)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daftar Akun Penerima",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lengkapi data instansi atau personal Anda",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  // Fields
                  _buildLabel("Nama Lengkap / Instansi"),
                  _buildTextField(
                    "Masukkan nama lengkap atau instansi",
                    controller: _nameController,
                  ),

                  _buildLabel("Username (Untuk Login)"),
                  _buildTextField(
                    "Cth: panti_sejahtera",
                    controller: _usernameController,
                  ),

                  _buildLabel("Tipe Penerima"),
                  _buildDropdown(
                    hint: "Pilih tipe penerima",
                    value: _selectedType,
                    items: _typeOptions,
                    onChanged: (val) => setState(() => _selectedType = val),
                  ),

                  _buildLabel("Nama Penanggung Jawab (PIC)"),
                  _buildTextField(
                    "Masukkan nama penanggung jawab",
                    controller: _picNameController,
                  ),

                  _buildLabel("Email"),
                  _buildTextField(
                    "Masukkan email aktif",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  _buildLabel("No. Handphone"),
                  _buildTextField(
                    "Masukkan nomor handphone",
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  _buildLabel("Alamat Lengkap"),
                  _buildAddressField(
                    "Pilih lokasi dari Peta",
                    controller: _addressController,
                  ),

                  _buildLabel("Kapasitas (Jumlah Orang)"),
                  _buildTextField(
                    "Cth: 50",
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                  ),

                  _buildLabel("Tingkat Kebutuhan"),
                  _buildDropdown(
                    hint: "Pilih tingkat kebutuhan",
                    value: _selectedNeedLevel,
                    items: _needOptions,
                    onChanged: (val) =>
                        setState(() => _selectedNeedLevel = val),
                  ),

                  _buildLabel("Password"),
                  _buildPasswordField(
                    hint: "Buat password",
                    controller: _passwordController,
                    isVisible: _isPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),

                  _buildLabel("Konfirmasi Password"),
                  _buildPasswordField(
                    hint: "Ulangi password",
                    controller: _confirmPasswordController,
                    isVisible: _isConfirmPasswordVisible,
                    toggleVisibility: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  // Button Register
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF86D538), Color(0xFF4CAF50)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
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
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Daftar Sekarang",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Teks Login
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Sudah punya akun? ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          children: const [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Color(0xFF56AB2F),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
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
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
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
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
      decoration: InputDecoration(
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
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
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
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[500],
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
  Widget _buildAddressField(
    String hint, {
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true, // User tidak mengetik manual, harus klik maps
      onTap: () async {
        // Navigasi ke Map Picker dan tunggu hasilnya
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapPickerPage(),
          ), // Pastikan import MapPickerPage
        );

        // Jika user memilih lokasi (tidak menekan tombol back saja)
        if (result != null) {
          setState(() {
            controller.text = result['address'];

            // OPSIONAL: Jika Anda ingin menyimpan Latitude & Longitude ke backend nanti,
            // Anda bisa simpan result['latitude'] dan result['longitude'] ke variabel State.
          });
        }
      },
      maxLines: 3,
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
        // Tambahkan Icon Maps di kanan form
        suffixIcon: const Icon(Icons.map_rounded, color: Color(0xFF56AB2F)),
      ),
    );
  }
}

class RegisterHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
