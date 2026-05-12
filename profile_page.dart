import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authentication_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  String phone = "";
  String password = "";
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /* ---------------- LOAD USER DATA ---------------- */

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    String loadedEmail = prefs.getString('email') ?? "";

    String? userData = prefs.getString("user_$loadedEmail");

    String loadedName = "";
    String loadedPhone = "";
    String loadedPassword = "";

    if (userData != null) {
      List<String> parts = userData.split("|");
      loadedName = parts[0];
      loadedPhone = parts[1];
      loadedPassword = parts[2];
    }

    String userHistoryKey = "bookingHistory_$loadedEmail";
    List<String> userHistory = prefs.getStringList(userHistoryKey) ?? [];

    setState(() {
      name = loadedName;
      email = loadedEmail;
      phone = loadedPhone;
      password = loadedPassword;
      history = userHistory;
    });
  }

  /* ---------------- EDIT PROFILE ---------------- */

  Future<void> _editProfile() async {
    TextEditingController nameCtrl = TextEditingController(text: name);
    TextEditingController emailCtrl = TextEditingController(text: email);
    TextEditingController phoneCtrl = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();

              String oldEmail = email;
              String newEmail = emailCtrl.text;

              // delete old record
              await prefs.remove("user_$oldEmail");

              // save new record
              String newUserData =
                  "${nameCtrl.text}|${phoneCtrl.text}|$password";
              await prefs.setString("user_$newEmail", newUserData);

              // update session email
              await prefs.setString("email", newEmail);

              Navigator.pop(context);
              loadData();
            },
          ),
        ],
      ),
    );
  }

  /* ---------------- LOGOUT ---------------- */

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("email");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthenticationPage()),
      (route) => false,
    );
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ⭐ EDIT ICON ADDED HERE
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      spreadRadius: 2)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "User Information",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  _buildProfileRow("Name", name),
                  const SizedBox(height: 18),
                  _buildProfileRow("Email", email),
                  const SizedBox(height: 18),
                  _buildProfileRow("Phone", phone),
                  const SizedBox(height: 18),
                  _buildProfileRow("Password", password),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Booking History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            history.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("No bookings yet."),
                  )
                : Column(
                    children: history
                        .map(
                          (item) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300, blurRadius: 5)
                              ],
                            ),
                            child: Text(item),
                          ),
                        )
                        .toList(),
                  ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text("Log Out"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
