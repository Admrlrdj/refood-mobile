import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api_config.dart';
import 'register_page.dart';
import 'register_receiver_page.dart';
import 'register_volunteer_page.dart';

// PENTING: Tambahkan import Dashboard Donatur di sini!
import '../donor/donor_dashboard.dart';
import '../receiver/receiver_dashboard.dart';

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({Key? key, required this.role}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _navigateToRegister() {
    if (widget.role == 'Penerima') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterReceiverPage()),
      );
    } else if (widget.role == 'Relawan') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterVolunteerPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    String apiRole = 'donor';
    if (widget.role == 'Penerima') apiRole = 'receiver';
    if (widget.role == 'Relawan') apiRole = 'volunteer';

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': _usernameController.text, // <-- Ganti email jadi username
              'password': _passwordController.text,
              'role': apiRole,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          ); // <--- TAMBAHKAN TIMEOUT DI SINI

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String token = responseData['access_token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', apiRole);

        // Menghilangkan pesan "Login Berhasil" agar transisi lebih mulus
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Login Berhasil!"), backgroundColor: Colors.green),
        // );

        // ==========================================
        // ARAHKAN KE DASHBOARD BERDASARKAN ROLE
        // ==========================================
        if (apiRole == 'donor') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DonorDashboard()),
            (route) => false,
          );
        } else if (apiRole == 'receiver') {
          // Buka blokir komentarnya, ganti jadi ini:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ReceiverDashboard()),
            (route) => false,
          );
        } else if (apiRole == 'volunteer') {
          // TODO: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VolunteerDashboard()));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? "Login Gagal"),
            backgroundColor: Colors.red,
          ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: HeaderClipper(),
              child: Container(
                height: 230,
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
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text(
                            "Login",
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

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, ${widget.role}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Silakan login untuk melanjutkan",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),

                  const Text(
                    "Username",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:
                        _usernameController, // <-- Pasang username controller
                    keyboardType: TextInputType.text, // <-- Ganti keyboard
                    decoration: InputDecoration(
                      hintText: "Masukkan username",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
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

                  const Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController, // Pasang Controller
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Masukkan password",
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
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
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Lupa Password?",
                        style: TextStyle(
                          color: Color(0xFF56AB2F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

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
                      onPressed: _isLoading
                          ? null
                          : _handleLogin, // Panggil fungsi API
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: GestureDetector(
                      onTap: _navigateToRegister,
                      child: RichText(
                        text: TextSpan(
                          text: "Belum punya akun? ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          children: const [
                            TextSpan(
                              text: "Register",
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
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
