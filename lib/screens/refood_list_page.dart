import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/api_config.dart';

class ReFoodListPage extends StatefulWidget {
  const ReFoodListPage({super.key});

  @override
  State<ReFoodListPage> createState() => _ReFoodListPageState();
}

class _ReFoodListPageState extends State<ReFoodListPage> {
  Future<List<dynamic>> fetchFoods() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/foods'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      throw Exception('Koneksi gagal. Cek IP & Laravel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RE-FOOD: Food Rescue',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchFoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data makanan."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var food = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.restaurant, color: Colors.white),
                  ),
                  title: Text(
                    food['nama_makanan'] ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "📍 ${food['lokasi_restoran'] ?? 'Lokasi tidak diketahui'}\n📄 ${food['deskripsi'] ?? '-'}",
                  ),
                  trailing: Text(
                    "${food['porsi'] ?? 0} Porsi",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {}),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
