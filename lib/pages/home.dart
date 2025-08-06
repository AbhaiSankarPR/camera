import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _image;
  String _time = "";

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _image = File(picked.path));
      _sendToBackend(File(picked.path));
    }
  }

  Future<void> _sendToBackend(File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.29.245:5000/detect-time'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    var response = await request.send();
    final result = await http.Response.fromStream(response);
    final decoded = jsonDecode(result.body);
    setState(() => _time = decoded["time"]);
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ClockReader"),),
      body: Column(
        children:[
          Text("Hello"),
          _image != null
                ? Image.file(_image!, height: 200)
                : const Text("No Image"),
          const SizedBox(height: 20),
            Text("Detected Time: $_time", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Take Photo"),
            ),
        ]
      ),
    );
  }
}
 

 
