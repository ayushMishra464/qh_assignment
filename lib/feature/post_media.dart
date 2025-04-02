import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class PostImage extends StatefulWidget {
  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  XFile? _selectedImage;
  File? _filteredImage;
  final ImagePicker _picker = ImagePicker();
  String _currentFilter = 'Original';

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _filteredImage = File(image.path);
        _currentFilter = 'Original';
      });
    }
  }

  void _applyFilter(String filterName) async {
    if (_selectedImage == null) return;

    final originalImage = await File(_selectedImage!.path).readAsBytes();
    img.Image? image = img.decodeImage(originalImage);

    if (image == null) return;

    setState(() {
      _currentFilter = filterName;
    });

    switch (filterName) {
      case 'Sepia':
        image = img.sepia(image);
        break;
      case 'Grayscale':
        image = img.grayscale(image);
        break;
      case 'Invert':
        image = img.invert(image);
        break;
      case 'Vintage':
        image = img.grayscale(image);
        image = img.adjustColor(image, contrast: 0.9, saturation: 0.5);
        break;
      case 'Cool': // Blue tint
        image = img.colorOffset(image, red: 0, green: 0, blue: 50);
        break;
      case 'Warm': // Red/Yellow tint
        image = img.colorOffset(image, red: 50, green: 30, blue: 0);
        break;
      case 'Original':
      default:
        break;
    }

    final filteredBytes = img.encodeJpg(image);
    final tempDir = Directory.systemTemp;
    final file = await File('${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg')
        .writeAsBytes(filteredBytes);

    setState(() {
      _filteredImage = file;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("New Post"),
        actions: [
          TextButton(
            onPressed: _selectedImage == null ? null : () {},
            child: Text("Next", style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
      body: Column(
        children: [
          _selectedImage == null
              ? Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: Text("Grant Gallery Access"),
              ),
            ),
          )
              : Column(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                child: _filteredImage != null
                    ? Image.file(
                  _filteredImage!,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterButton("Original", isSelected: _currentFilter == 'Original'),
                    _filterButton("Sepia", isSelected: _currentFilter == 'Sepia'),
                    _filterButton("Grayscale", isSelected: _currentFilter == 'Grayscale'),
                    _filterButton("Invert", isSelected: _currentFilter == 'Invert'),
                    _filterButton("Vintage", isSelected: _currentFilter == 'Vintage'),
                    _filterButton("Cool", isSelected: _currentFilter == 'Cool'),
                    _filterButton("Warm", isSelected: _currentFilter == 'Warm'),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple),
                child: Text("Next",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => _applyFilter(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.transparent,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.purple.withOpacity(0.2),
                radius: 20,
                child: Text(
                  label[0], // Show first letter of filter name
                  style: TextStyle(color: Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(label),
          ],
        ),
      ),
    );
  }
}