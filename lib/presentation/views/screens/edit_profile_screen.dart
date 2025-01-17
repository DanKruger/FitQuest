import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _EditingProfileScreenState();
}

class _EditingProfileScreenState extends State<EditProfileScreen> {
  String _name = "John";
  String _surname = "Doe";
  // TODO Finish edit profile feature
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Consumer<AuthViewmodel>(
        builder: (context, auth, child) {
          return FutureBuilder(
            future: auth.currentUser,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              if (snapshot.hasError) return const Text('error occurred');
              User? user = snapshot.data;
              List<String>? displayname = user?.displayName!.split(" ");
              _name = displayname![0];
              _surname = displayname[1];
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildEditableField("Name", _name, (newName) {
                          setState(() {
                            _name = newName;
                          });
                        }),
                        const SizedBox(height: 16),
                        _buildEditableField("Surname", _surname, (newSurname) {
                          setState(() {
                            _surname = newSurname;
                          });
                        }),
                        TextButton(onPressed: () {}, child: const Text('Done'))
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEditableField(
      String title, String value, Function(String) onSave) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.edit_rounded),
          onPressed: () {
            _showEditDialog(title, value, onSave);
          },
        ),
      ],
    );
  }

  Future<void> _showEditDialog(
      String title, String initialValue, Function(String) onSave) async {
    TextEditingController controller =
        TextEditingController(text: initialValue);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Enter new $title",
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
