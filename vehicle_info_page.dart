import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleInfoPage extends StatefulWidget {
  final int slotNumber;

  const VehicleInfoPage({super.key, required this.slotNumber});

  @override
  State<VehicleInfoPage> createState() => _VehicleInfoPageState();
}

class _VehicleInfoPageState extends State<VehicleInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final plateController = TextEditingController();

  late DatabaseReference bookingRef;

  @override
  void initState() {
    super.initState();

    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "YOUR_FIREBASE_DATABASE_URL",
    );

    bookingRef = database.ref("parking/bookings");
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    int bookingId = 1000;

    // 🔥 Get all existing bookings
    DataSnapshot allData = await bookingRef.get();

    if (allData.value != null && allData.value is Map) {
      Map data = allData.value as Map;

      // Find max existing ID
      List<int> existingIds = data.keys
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e >= 1000 && e <= 1010)
          .toList();

      if (existingIds.isNotEmpty) {
        existingIds.sort();
        bookingId = existingIds.last + 1;
      }
    }

    // 🔥 Limit booking IDs between 1000 and 1010
    if (bookingId > 1010) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking ID limit reached (1000-1010)"),
        ),
      );
      return;
    }

    // 🔥 Remove old booking of same slot
    if (allData.value != null && allData.value is Map) {
      Map data = allData.value as Map;

      for (var key in data.keys) {
        if (data[key] is Map && data[key]["S${widget.slotNumber}"] != null) {
          await bookingRef.child(key).remove();
        }
      }
    }

    // 🔥 Save structure:
    // bookings → bookingId → S1 : "b"
    await bookingRef
        .child(bookingId.toString())
        .set({"S${widget.slotNumber}": "b"});

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Details - Slot S${widget.slotNumber}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v!.length != 10 ? "Enter valid 10-digit phone" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: "Car Plate Number",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter plate number" : null,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Submit Booking"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
