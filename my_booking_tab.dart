import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBookingTab extends StatefulWidget {
  const MyBookingTab({super.key});

  @override
  State<MyBookingTab> createState() => _MyBookingTabState();
}

class _MyBookingTabState extends State<MyBookingTab> {
  String name = "";
  String phone = "";
  String plate = "";
  int bookedSlot = -1;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    final prefs = await SharedPreferences.getInstance();

    String email = prefs.getString("email") ?? "";
    String key = "bookingHistory_$email";

    List<String> history = prefs.getStringList(key) ?? [];

    if (history.isNotEmpty) {
      String last = history.last;

      setState(() {
        bookedSlot = int.parse(last.split("\n")[0].split("S")[1]);
        name = last.split("\n")[1].split(": ")[1];
        phone = last.split("\n")[2].split(": ")[1];
        plate = last.split("\n")[3].split(": ")[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const size = Size(300, 300);

    return Scaffold(
      appBar: AppBar(title: const Text("My Booking")),
      body: bookedSlot == -1
          ? const Center(child: Text("No booking found"))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Slot Booked: S$bookedSlot",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // MAP
                Center(
                  child: CustomPaint(
                    size: size,
                    painter: MyBookingPainter(bookedSlot: bookedSlot),
                  ),
                ),

                const SizedBox(height: 20),

                // VEHICLE INFO
                Card(
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Text("Name: $name"),
                        Text("Phone: $phone"),
                        Text("Plate: $plate"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/* ---------------- MAP PAINTER ---------------- */

class MyBookingPainter extends CustomPainter {
  final int bookedSlot;

  MyBookingPainter({required this.bookedSlot});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      double startAngle = (-pi / 2) + (pi / 2) * i;

      if (bookedSlot == i + 1) {
        paint.color = Colors.blue; // booked slot highlight
      } else {
        paint.color = Colors.grey.shade300;
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        pi / 2,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: "S${i + 1}",
          style: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      double angle = startAngle + (pi / 4);
      double textX =
          center.dx + (radius * 0.55) * cos(angle) - textPainter.width / 2;
      double textY =
          center.dy + (radius * 0.55) * sin(angle) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(textX, textY));
    }

    final divider = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    for (int i = 0; i < 4; i++) {
      double angle = (-pi / 2) + (pi / 2) * i;

      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      canvas.drawLine(center, Offset(x, y), divider);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
