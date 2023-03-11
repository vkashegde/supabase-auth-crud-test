import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//update functionality
//Syntax : supabase.from('users').update({'name':'Elon Musk'}).match({'id':10})
//Syntax : supabase.from('users').update({'nmae':'Elon Musk'}).eq('id':10);

//delete functionality
//Syntax: supabase.from('users').delete().match({'id':10});

class EditPage extends StatefulWidget {
  final String editData;
  final int editId;
  const EditPage({Key? key, required this.editData, required this.editId})
      : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void dispose() {
    supabase.dispose();
    titleController.dispose();
    super.dispose();
  }

  Future<void> updateData() async {
    if (titleController.text != '') {
      setState(() {
        isLoading = true;
      });

      try {
        await supabase.from('todos').update(
            {'title': titleController.text}).match({'id': widget.editId});
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
  }

  Future<void> deleteData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await supabase.from('todos').delete().match({'id': widget.editId});
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
  void initState() {
    titleController.text = widget.editData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Data'),
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
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                            onPressed: () {
                              updateData();
                            },
                            child: const Text('Update')),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      ElevatedButton(
                          onPressed: () {
                            deleteData();
                          },
                          child: const Text('Delete'))
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
