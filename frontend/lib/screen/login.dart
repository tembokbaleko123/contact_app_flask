import 'package:flutter/material.dart';
import 'package:frontend/screen/home_page.dart';
import 'package:frontend/screen/register.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/auth_card.dart';
import 'package:frontend/widgets/custom_input_field.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const id = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // ✅ Cek apakah user sudah login sebelumnya
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null) {
      // Sudah login → langsung ke HomePage
      Navigator.pushReplacementNamed(context, HomePage.id);
    }
  }

  // ✅ Login dan simpan user_id ke SharedPreferences
  void _handleLogin() async {
    final email = emailController.text.trim();
    final password = passController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Email dan password wajib diisi");
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      email: email,
      password: password,
    );

    setState(() => _isLoading = false);

    if (result['status'] == 200) {
      final userId = result['data']['user_id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId); // Simpan user_id

      Navigator.pushReplacementNamed(context, HomePage.id);
    } else {
      _showSnackbar(result['data']['message'] ?? "Login gagal");
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: AuthCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Selamat Datang",
                    style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900])),
                const SizedBox(height: 8),
                Text("Silakan login untuk melanjutkan",
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 24),
                CustomInputField(
                    label: "Email",
                    icon: Icons.email_outlined,
                    textEditingController: emailController),
                const SizedBox(height: 16),
                CustomInputField(
                    label: "Password",
                    icon: Icons.lock_outline,
                    obscureText: true,
                    textEditingController: passController),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Lupa Password?",
                        style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: _isLoading ? "Memproses..." : "Login",
                  onPressed: _isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, RegisterPage.id);
                      },
                      child: const Text("Daftar",
                          style: TextStyle(color: Colors.blueAccent)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
