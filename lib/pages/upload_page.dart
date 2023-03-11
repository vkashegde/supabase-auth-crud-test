import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

//Syntax to fetch images

//final List<fileObject> results = await supabase.storage.from('bucket-name').list();

//syntax to remove file
//final List<FileObject> result = await supabase.storage.from('bucketName').remove([user_id/'imagename.png'])

class UploadPage extends StatefulWidget {
  UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool isUploading = false;

  @override
  void initState() {
    getMyfiles();
    super.initState();
  }

  Future<void> deleteImage(String imageName) async {
    try {
      await supabase.storage
          .from('user-images')
          .remove(['${supabase.auth.currentUser!.id}/$imageName']);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e'),
        backgroundColor: Color.fromARGB(255, 233, 70, 11),
      ));
    }
  }

  Future getMyfiles() async {
    final List<FileObject> result = await supabase.storage
        .from('user-images')
        .list(path: supabase.auth.currentUser!.id);

    List<Map<String, dynamic>> myImages = [];

    for (var image in result) {
      final getUrl = supabase.storage
          .from('user-images')
          .getPublicUrl('${supabase.auth.currentUser!.id}/${image.name}');
      myImages.add({'name': image.name, 'url': getUrl});
    }

    print(myImages.toString());

    return myImages;
  }

  Future uploadFile() async {
    var pickedFile = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (pickedFile != null) {
      setState(() {
        isUploading = true;
      });
      try {
        File file = File(pickedFile.files.first.path!);
        String fileName = pickedFile.files.first.name;
        String uploadUrl = await supabase.storage
            .from('user-images')
            .upload('${supabase.auth.currentUser!.id}/${fileName}', file);
        print(uploadUrl);

        setState(() {
          isUploading = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Success ! File Uploaded'),
          backgroundColor: Color(0xff12E2A3),
        ));
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${e}'),
          backgroundColor: Color.fromARGB(255, 226, 67, 18),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Storage'),
      ),
      body: FutureBuilder(
        future: getMyfiles(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return const Center(
                child: Text('No Image Found'),
              );
            }

            return ListView.separated(
              itemCount: snapshot.data.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              separatorBuilder: (context, index) {
                return const Divider(
                  thickness: 2,
                  color: Colors.black38,
                );
              },
              itemBuilder: (context, index) {
                Map imagedata = snapshot.data[index];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 300,
                      child: Image.network(
                        imagedata['url'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        deleteImage(imagedata['name']);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                  ],
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_a_photo),
        onPressed: () {
          uploadFile();
        },
      ),
    );
  }
}
