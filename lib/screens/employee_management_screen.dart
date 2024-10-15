import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  EmployeeManagementScreenState createState() => EmployeeManagementScreenState();
}

class EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final CollectionReference _employees =
  FirebaseFirestore.instance.collection('employees');

  Future<void> _addEmployee() {
    return _employees.add({
      'name': _nameController.text,
      'email': _emailController.text,
    }).then((value) {
      _nameController.clear();
      _emailController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Employee added')));
    });
  }

  Future<void> _deleteEmployee(String id) {
    return _employees.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Employee Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Employee Email'),
            ),
          ),
          ElevatedButton(
            onPressed: _addEmployee,
            child: const Text('Add Employee'),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _employees.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: Text(doc['name']),
                      subtitle: Text(doc['email']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteEmployee(doc.id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
