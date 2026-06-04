import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_config.dart';

// Import Dashboard
import '../donor/donor_dashboard.dart';
import '../receiver/receiver_dashboard.dart';
// import '../volunteer/volunteer_dashboard.dart';

// Import Role Selection & Register Pages
import 'role_selection_page.dart';
import 'register_page.dart';
import 'register_receiver_page.dart';
import 'register_volunteer_page.dart';

class LoginPage extends StatefulWidget {
  final String? role;

  const LoginPage({Key? key, this.role}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obsPassword = true;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password harus diisi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Sesuaikan role bahasa Indonesia dari UI ke bahasa Inggris untuk Backend
    String roleParam = '';
    if (widget.role == 'Donatur')
      roleParam = 'donor';
    else if (widget.role == 'Penerima')
      roleParam = 'receiver';
    else if (widget.role == 'Relawan')
      roleParam = 'volunteer';
    else
      roleParam = widget.role?.toLowerCase() ?? '';

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': _usernameController.text,
              'password': _passwordController.text,
              'role': roleParam,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // MENCEGAH ERROR NULL: Mengambil 'token' atau 'access_token'
        String token = data['token'] ?? data['access_token'] ?? '';
        await prefs.setString('auth_token', token);

        // MENCEGAH ERROR NULL: Mengambil role dengan aman
        String role = roleParam; // Gunakan parameter awal sebagai cadangan
        if (data['user'] != null && data['user']['role'] != null) {
          role = data['user']['role'];
        } else if (data['data'] != null && data['data']['role'] != null) {
          role = data['data']['role'];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login berhasil!"),
            backgroundColor: Colors.green,
          ),
        );

        if (role == 'donor') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DonorDashboard()),
            (route) => false,
          );
        } else if (role == 'receiver') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ReceiverDashboard()),
            (route) => false,
          );
        } else if (role == 'volunteer') {
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(builder: (_) => const VolunteerDashboard()),
          //   (route) => false,
          // );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Role tidak dikenal!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Login gagal"),
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
    String titleText = "Welcome Back!";
    String subtitleText =
        "Silakan masuk menggunakan akun yang telah Anda daftarkan.";
    Color themeColor = const Color(0xFF2E7D32);

    if (widget.role == 'Penerima') {
      titleText = "Halo, Penerima Kebaikan";
      subtitleText =
          "Silakan masuk untuk melihat dan mengajukan request makanan.";
      themeColor = const Color(0xFF0F766E);
    } else if (widget.role == 'Relawan') {
      titleText = "Halo, Pahlawan Pangan!";
      subtitleText = "Silakan masuk untuk mulai mengantar kebaikan hari ini.";
      themeColor = const Color(0xFF1D4ED8);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RoleSelectionPage()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_person_rounded,
                  size: 50,
                  color: themeColor,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              titleText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitleText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // INPUT USERNAME
            const Text(
              "Username",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: "Masukkan username",
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
            const SizedBox(height: 20),

            // INPUT PASSWORD
            const Text(
              "Password",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obsPassword,
              decoration: InputDecoration(
                hintText: "Masukkan password",
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
                    _obsPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[500],
                  ),
                  onPressed: () => setState(() => _obsPassword = !_obsPassword),
                ),
              ),
            ),

            // LUPA PASSWORD
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Fitur Lupa Password segera hadir!"),
                    ),
                  );
                },
                child: Text(
                  "Lupa Password?",
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TOMBOL LOGIN
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // BELUM PUNYA AKUN? REGISTER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Belum punya akun? ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.role == 'Donatur') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    } else if (widget.role == 'Penerima') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterReceiverPage(),
                        ),
                      );
                    } else if (widget.role == 'Relawan') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterVolunteerPage(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => RoleSelectionPage()),
                      );
                    }
                  },
                  child: Text(
                    "Daftar Sekarang",
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
