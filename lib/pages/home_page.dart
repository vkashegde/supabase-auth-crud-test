import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:suppa_fluttr/pages/create_page.dart';
import 'package:suppa_fluttr/pages/edit_page.dart';
import 'package:suppa_fluttr/pages/upload_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Stream<List<Map<String, dynamic>>> _readStream;

  @override
  void initState() {
    _readStream = supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('id', ascending: false);
    super.initState();
  }

  Future<List> readData() async {
    final result = await supabase
        .from('todos')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('id', ascending: false);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UploadPage(),
              ));
            },
            icon: const Icon(Icons.upload_file_rounded),
          ),
          IconButton(
            onPressed: () async {
              await supabase.auth.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder(
        stream: _readStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return const Center(
                child: Text("No data Available"),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: ((context, index) {
                  var data = snapshot.data[index];
                  return ListTile(
                    title: Text(data['title']),
                    trailing: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditPage(
                                editData: data['title'], editId: data['id']),
                          ));
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.red,
                        )),
                  );
                }));
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CreatePage(),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
