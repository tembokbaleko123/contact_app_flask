import 'package:flutter/material.dart';
import 'package:frontend/models/group.dart';
import 'package:frontend/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});
  static const id = '/add-group';

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Future<void> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (_nameController.text.isEmpty || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama grup wajib diisi")),
      );
      return;
    }

    final group = Group(
      name: _nameController.text,
      description: _descController.text,
      userId: userId,
    );

    final success = await ApiServices.addGroup(group);
    if (success) {
      Navigator.pop(context, true); // kembali ke halaman sebelumnya
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuat grup")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Grup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nama Grup"),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
