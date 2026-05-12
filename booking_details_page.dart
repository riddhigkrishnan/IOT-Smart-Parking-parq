import 'package:flutter/material.dart';
import 'parking_map_page.dart';

class BookingDetailsPage extends StatefulWidget {
  const BookingDetailsPage({super.key});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  DateTime? selectedDate;
  TimeOfDay? arrivalTime;
  String duration = '1 Hour';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prebooking Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                selectedDate == null
                    ? 'Select Date'
                    : 'Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                arrivalTime == null
                    ? 'Select Arrival Time'
                    : 'Arrival Time: ${arrivalTime!.format(context)}',
              ),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  setState(() {
                    arrivalTime = pickedTime;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: duration,
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '1 Hour', child: Text('1 Hour')),
                DropdownMenuItem(value: '2 Hours', child: Text('2 Hours')),
                DropdownMenuItem(value: '3 Hours', child: Text('3 Hours')),
              ],
              onChanged: (value) {
                setState(() {
                  duration = value!;
                });
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (selectedDate == null || arrivalTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select date and time"),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParkingMapPage(),
                  ),
                );
              },
              child: const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
