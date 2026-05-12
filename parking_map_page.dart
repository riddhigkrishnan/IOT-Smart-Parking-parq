import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'vehicle_info_page.dart';

class ParkingMapPage extends StatefulWidget {
  const ParkingMapPage({super.key});

  @override
  State<ParkingMapPage> createState() => _ParkingMapPageState();
}

class _ParkingMapPageState extends State<ParkingMapPage> {
  int? selectedSlot;

  List<String> slotStatus = ["e", "e", "e", "e"];

  late DatabaseReference bookingRef;
  StreamSubscription<DatabaseEvent>? bookingSub;

  @override
  void initState() {
    super.initState();

    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: "YOUR_FIREBASE_DATABASE_URL",
    );

    bookingRef = database.ref("parking/bookings");

    _listenToBookings();
  }

  // 🔥 Live Firebase Listener
  void _listenToBookings() {
    bookingSub = bookingRef.onValue.listen((event) {
      List<String> newStatus = ["e", "e", "e", "e"];

      final data = event.snapshot.value;

      if (data != null && data is Map) {
        data.forEach((bookingId, value) {
          if (value is Map) {
            value.forEach((slotKey, status) {
              if (slotKey.startsWith("S")) {
                int index = int.parse(slotKey.substring(1)) - 1;

                if (index >= 0 && index < 4) {
                  if (status == "p") {
                    newStatus[index] = "p";
                  } else if (status == "b" && newStatus[index] != "p") {
                    newStatus[index] = "b";
                  }
                }
              }
            });
          }
        });
      }

      if (mounted) {
        setState(() {
          slotStatus = newStatus;
        });
      }
    });
  }

  void _updateSlots(dynamic snapshotValue) {
    List<String> newStatus = ["e", "e", "e", "e"];

    if (snapshotValue != null && snapshotValue is Map) {
      snapshotValue.forEach((key, value) {
        // Convert ANY type to string safely
        String slotValue = value.toString();

        if (slotValue.startsWith("S") && slotValue.length >= 3) {
          int index = int.parse(slotValue[1]) - 1;
          String status = slotValue.substring(2);

          if (index >= 0 && index < 4) {
            newStatus[index] = status;
          }
        }
      });
    }

    if (mounted) {
      setState(() {
        slotStatus = newStatus;
      });
    }
  }

  // 🔥 Manual Refresh after return
  Future<void> _refreshFromFirebase() async {
    final snapshot = await bookingRef.get();
    _updateSlots(snapshot.value);
  }

  void _handleTap(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    if (sqrt(dx * dx + dy * dy) > radius) return;

    double angle = atan2(dy, dx);
    angle += pi / 2;
    if (angle < 0) angle += 2 * pi;

    int tappedIndex = (angle ~/ (pi / 2));

    if (slotStatus[tappedIndex] == "e") {
      setState(() {
        selectedSlot = tappedIndex;
      });
    }
  }

  void _proceedToVehicleInfo() async {
    if (selectedSlot == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleInfoPage(slotNumber: selectedSlot! + 1),
      ),
    );

    // Clear selection & refresh
    selectedSlot = null;
    await _refreshFromFirebase();
  }

  @override
  void dispose() {
    bookingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double mapSize = 280;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Slot"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              onTapUp: (details) {
                _handleTap(details.localPosition, const Size(mapSize, mapSize));
              },
              child: CustomPaint(
                size: const Size(mapSize, mapSize),
                painter: ParkingPainter(
                  slotStatus: slotStatus,
                  selectedSlot: selectedSlot,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: selectedSlot != null ? _proceedToVehicleInfo : null,
            child: const Text("Confirm Booking"),
          ),
        ],
      ),
    );
  }
}

class ParkingPainter extends CustomPainter {
  final List<String> slotStatus;
  final int? selectedSlot;

  ParkingPainter({
    required this.slotStatus,
    required this.selectedSlot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 4; i++) {
      final paint = Paint()..style = PaintingStyle.fill;

      // 🔥 Correct priority
      if (slotStatus[i] == "b") {
        paint.color = Colors.orange;
      } else if (slotStatus[i] == "p") {
        paint.color = Colors.red;
      } else if (selectedSlot == i && slotStatus[i] == "e") {
        paint.color = Colors.yellow;
      } else {
        paint.color = Colors.green;
      }

      double startAngle = (-pi / 2) + (pi / 2) * i;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        pi / 2,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        pi / 2,
        true,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: "S${i + 1}",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      double labelAngle = startAngle + pi / 4;

      Offset textOffset = Offset(
        center.dx + radius * 0.6 * cos(labelAngle) - textPainter.width / 2,
        center.dy + radius * 0.6 * sin(labelAngle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
