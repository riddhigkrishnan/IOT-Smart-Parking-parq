import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prebook_page.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PARQ'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Sign Up'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LoginTab(),
            SignUpTab(),
          ],
        ),
      ),
    );
  }
}

/* ---------------- LOGIN TAB ---------------- */

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();

      String email = emailController.text.trim().toLowerCase();
      String password = passwordController.text.trim();

      String? userData = prefs.getString("user_$email");

      if (userData != null) {
        List<String> parts = userData.split("|");

        if (parts.length == 3 && parts[2] == password) {
          await prefs.setString("email", email);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PrebookPage()),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  !value!.contains("@") ? "Enter valid email" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) =>
                  value!.length < 6 ? "Password must be 6+ characters" : null,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- SIGN UP TAB ---------------- */

class SignUpTab extends StatefulWidget {
  const SignUpTab({super.key});

  @override
  State<SignUpTab> createState() => _SignUpTabState();
}

class _SignUpTabState extends State<SignUpTab> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();

      String email = emailController.text.trim().toLowerCase();

      if (prefs.containsKey("user_$email")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User already exists")),
        );
        return;
      }

      String userData =
          "${nameController.text.trim()}|${phoneController.text.trim()}|${passwordController.text.trim()}";

      await prefs.setString("user_$email", userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Successful! Please login.")),
      );

      DefaultTabController.of(context).animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? "Enter your name" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.length != 10 ? "Enter valid 10-digit phone" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  !value!.contains("@") ? "Enter valid email" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) =>
                  value!.length < 6 ? "Password must be 6+ characters" : null,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: signUp,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
