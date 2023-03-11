import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePage extends StatefulWidget {
  CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  Future insertData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String userId = supabase.auth.currentUser!.id;
      await supabase
          .from('todos')
          .insert({'title': titleController.text, 'user_id': userId});
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${e.toString()}'),
        backgroundColor: Color.fromARGB(255, 243, 17, 6),
      ));
    }
  }

  @override
  void dispose() {
    supabase.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  hintText: " Enter the title", border: OutlineInputBorder()),
            ),
            const SizedBox(
              height: 10,
            ),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: () {
                      insertData();
                    },
                    child: Text('Create'))
          ],
        ),
      ),
    );
  }
}
