import 'package:flutter/material.dart';
import '../models/person.dart';
import '../models/group.dart';

class EditPersonScreen extends StatefulWidget {
  final Person person;
  final ValueChanged<Person> onSave;
  final List<Group> groups;

  const EditPersonScreen({
    super.key,
    required this.person,
    required this.onSave,
    required this.groups,
  });

  @override
  State<EditPersonScreen> createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _imageUrlController;
  int? selectedGroupId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person.name);
    _phoneController = TextEditingController(text: widget.person.phone);
    _imageUrlController = TextEditingController(text: widget.person.imageUrl);
    selectedGroupId = widget.person.groupId;
  }

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

    final updatedPerson = Person(
      id: widget.person.id,
      name: _nameController.text,
      phone: _phoneController.text,
      imageUrl: _imageUrlController.text,
      groupId: selectedGroupId,
    );

    widget.onSave(updatedPerson);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Teman"),
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
              icon: const Icon(Icons.save),
              label: const Text("Simpan Perubahan"),
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
