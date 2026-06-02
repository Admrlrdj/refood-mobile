import 'package:flutter/material.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  bool isActive = true; // Switch DND

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Relawan Aktif 🛵',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              Text(
                isActive ? 'Online' : 'Sibuk',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: isActive,
                activeThumbColor: const Color(0xFF10B981),
                onChanged: (val) => setState(() => isActive = val),
              ),
            ],
          ),
        ],
      ),
      body: isActive
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Orderan Tersedia',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF10B981),
                      child: Icon(Icons.delivery_dining, color: Colors.white),
                    ),
                    title: const Text(
                      'Antar: 20 Porsi Ayam Bakar',
                      style: FontWeight.bold,
                    ),
                    subtitle: const Text(
                      'Titik A: Warung Barokah\nTitik B: Panti Asuhan Kasih',
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed:
                          () {}, // Action untuk pindah ke screen Maps navigasi Leaflet
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ambil',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bedtime_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Mode Jangan Ganggu Aktif',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}
