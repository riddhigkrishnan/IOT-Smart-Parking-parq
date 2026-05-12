import 'package:flutter/material.dart';
import 'booking_details_page.dart';
import 'profile_page.dart';

class PrebookPage extends StatelessWidget {
  const PrebookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PARQ'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: const PrebookTab(),
    );
  }
}

class PrebookTab extends StatelessWidget {
  const PrebookTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Location: RSET',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookingDetailsPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 15,
              ),
            ),
            child: const Text(
              'Prebook',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
