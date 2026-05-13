import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Import Dashboard masing-masing role (akan kita buat di bawah)
import '../donor/donor_dashboard.dart';
import '../receiver/receiver_dashboard.dart';
import '../volunteer/volunteer_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String selectedRole = 'donor'; // Default role
  bool isLoading = false;

  Future<void> _login() async {
    setState(() => isLoading = true);

    // Endpoint beda-beda tergantung role
    String endpoint = 'http://10.0.2.2:8000/api/login/$selectedRole';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Simpan Token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['data']['access_token']);
        await prefs.setString('role', selectedRole);

        // Arahkan ke Dashboard sesuai Role
        if (!mounted) return;
        if (selectedRole == 'donor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const DonorDashboard()),
          );
        } else if (selectedRole == 'receiver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const ReceiverDashboard()),
          );
        } else if (selectedRole == 'volunteer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const VolunteerDashboard()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login Gagal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan koneksi!')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Placeholder
              const Icon(Icons.eco_rounded, size: 80, color: Color(0xFF10B981)),
              const SizedBox(height: 16),
              const Text(
                'RE-FOOD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selamatkan Makanan, Selamatkan Bumi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Dropdown Pilihan Role
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'donor',
                        child: Text('Login sebagai Donatur (Restoran)'),
                      ),
                      DropdownMenuItem(
                        value: 'receiver',
                        child: Text('Login sebagai Penerima (Yayasan)'),
                      ),
                      DropdownMenuItem(
                        value: 'volunteer',
                        child: Text('Login sebagai Relawan (Kurir)'),
                      ),
                    ],
                    onChanged: (value) => setState(() => selectedRole = value!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Login
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Login Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
