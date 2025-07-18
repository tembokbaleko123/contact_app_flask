import 'package:flutter/material.dart';
import 'package:frontend/screen/login.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/auth_card.dart';
import 'package:frontend/widgets/custom_input_field.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const id = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  bool _isLoading = false;

  void _handleRegister() async {
    final nama = namaController.text.trim();
    final email = emailController.text.trim();
    final password = passController.text;
    final confirmPassword = confirmPassController.text;

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar("Semua field wajib diisi");
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar("Password tidak cocok");
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      username: nama,
      email: email,
      password: password,
    );

    setState(() => _isLoading = false);

    if (result['status'] == 201) {
      _showSnackbar("Registrasi berhasil! Silakan login");
      Navigator.pushReplacementNamed(context, LoginPage.id);
    } else {
      _showSnackbar(result['data']['message'] ?? "Terjadi kesalahan");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                Text("Buat Akun", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                const SizedBox(height: 8),
                Text("Isi data di bawah untuk mendaftar", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 24),
                CustomInputField(label: "Nama Lengkap", icon: Icons.person, textEditingController: namaController),
                const SizedBox(height: 16),
                CustomInputField(label: "Email", icon: Icons.email_outlined, textEditingController: emailController),
                const SizedBox(height: 16),
                CustomInputField(label: "Password", icon: Icons.lock_outline, obscureText: true, textEditingController: passController),
                const SizedBox(height: 16),
                CustomInputField(label: "Konfirmasi Password", icon: Icons.lock_reset, obscureText: true, textEditingController: confirmPassController),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _isLoading ? "Memproses..." : "Daftar",
                  onPressed: _isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun?"),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, LoginPage.id),
                      child: const Text("Login", style: TextStyle(color: Colors.blueAccent)),
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
