import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/group.dart';
import '../services/api_services.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<Group> groups = [];
  int? userId;
  bool isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserAndGroups();
  }

  Future<void> _loadUserAndGroups() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User tidak ditemukan")),
      );
      return;
    }

    await fetchGroups();
  }

  Future<void> fetchGroups() async {
    if (userId == null) return;

    try {
      final data = await ApiServices.getAllGroupsByUser(userId!);
      setState(() {
        groups = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat grup: $e")),
      );
    }
  }

  void _showGroupDialog({Group? group}) {
    if (group != null) {
      _nameController.text = group.name ?? '';
      _descController.text = group.description ?? '';
    } else {
      _nameController.clear();
      _descController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(group == null ? 'Tambah Grup' : 'Edit Grup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Grup'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newGroup = Group(
                name: _nameController.text,
                description: _descController.text,
              );
              if (group == null) {
                await ApiServices.addGroup(newGroup);
              } else {
                await ApiServices.updateGroup(group.id!, newGroup);
              }
              Navigator.pop(context);
              fetchGroups();
            },
            child: Text(group == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteGroup(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus grup ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiServices.deleteGroup(id);
      fetchGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Grup'),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGroupDialog(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  title: Text(group.name ?? ''),
                  subtitle: Text(group.description ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showGroupDialog(group: group),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteGroup(group.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
