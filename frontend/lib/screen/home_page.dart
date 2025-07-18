import 'package:flutter/material.dart';
import 'package:frontend/screen/add_group_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../models/group.dart';
import '../services/api_services.dart';
import '../widgets/person_card.dart';
import 'edit_person_screen.dart';
import 'add_person_screen.dart';
import 'group_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const id = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? userId;
  List<Person> people = [];
  List<Group> groups = [];
  int? selectedGroupId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchData();
  }

  Future<void> _loadUserIdAndFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');

    if (userId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    await fetchGroups();
    await fetchPersons();
  }

  Future<void> fetchPersons() async {
    try {
      final data = await ApiServices.getAllPersonsByUser(
        userId!,
        groupId: selectedGroupId,
      );
      setState(() {
        people = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage('Gagal memuat data: $e');
    }
  }

  Future<void> fetchGroups() async {
    try {
      final data = await ApiServices.getAllGroupsByUser(userId!);
      setState(() {
        groups = data;
      });
    } catch (e) {
      _showMessage('Gagal memuat grup: $e');
    }
  }

  void _onAddPerson() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPersonScreen(
          onAdd: (newPerson) async {
            newPerson.userId = userId;
            final success = await ApiServices.addPerson(newPerson);
            if (success) {
              fetchPersons();
              _showMessage("Data berhasil ditambahkan");
            }
          },
          groups: groups,
        ),
      ),
    );
  }

  void _onEdit(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonScreen(
          person: people[index],
          groups: groups,
          onSave: (updatedPerson) async {
            final id = people[index].id;
            if (id != null) {
              updatedPerson.userId = userId;
              final success = await ApiServices.updatePerson(id, updatedPerson);
              if (success) {
                fetchPersons();
                _showMessage("Data berhasil diperbarui");
              }
            }
          },
        ),
      ),
    );
  }

  void _onDelete(int index) async {
    final id = people[index].id;
    if (id != null) {
      final success = await ApiServices.deletePerson(id);
      if (success) {
        fetchPersons();
        _showMessage("Data berhasil dihapus");
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _goToGroupManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupScreen()),
    ).then((_) => fetchGroups());
  }

  void _goToAddGroup() {
    Navigator.pushNamed(context, AddGroupScreen.id).then((_) => fetchGroups());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Teman"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Tambah Grup',
            onPressed: _goToAddGroup,
          ),
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Kelola Grup',
            onPressed: _goToGroupManagement,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPerson,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (groups.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Filter berdasarkan Grup",
                        border: OutlineInputBorder(),
                      ),
                      value: selectedGroupId,
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text("Semua Grup"),
                        ),
                        ...groups.map(
                          (g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.name ?? ""),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedGroupId = value;
                          isLoading = true;
                        });
                        fetchPersons();
                      },
                    ),
                  ),
                Expanded(
                  child: people.isEmpty
                      ? const Center(child: Text("Belum ada data"))
                      : ListView.builder(
                          itemCount: people.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                showBottomSheetOptions(
                                  context: context,
                                  onEdit: () => _onEdit(index),
                                  onDelete: () => _onDelete(index),
                                );
                              },
                              child: PersonCard(person: people[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

void showBottomSheetOptions({
  required BuildContext context,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blueAccent),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      );
    },
  );
}
