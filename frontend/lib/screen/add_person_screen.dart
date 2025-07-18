import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/group.dart';

class AddPersonScreen extends StatefulWidget {
  final ValueChanged<Person> onAdd;
  final List<Group> groups;

  const AddPersonScreen({
    super.key,
    required this.onAdd,
    required this.groups,
  });

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  int? selectedGroupId;

  void _submit() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _imageUrlController.text.isEmpty ||
        selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    final newPerson = Person(
      name: _nameController.text,
      phone: _phoneController.text,
      imageUrl: _imageUrlController.text,
      groupId: selectedGroupId,
    );

    widget.onAdd(newPerson);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Teman"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "No. Telepon"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: "URL Gambar"),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedGroupId,
              decoration: const InputDecoration(
                labelText: "Pilih Grup",
                border: OutlineInputBorder(),
              ),
              items: widget.groups
                  .map((group) => DropdownMenuItem<int>(
                        value: group.id,
                        child: Text(group.name ?? ''),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedGroupId = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text("Tambahkan Teman"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
