// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

import 'api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? imageFile;
  Uint8List? imageFile1;

  String? imagePath;

  _showPicker(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Gallery'),
                      onTap: () {
                        getImage(ImageSource.gallery);
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Camera'),
                    onTap: () {
                      getImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void getImage(ImageSource source) async {
    try {
      setState(() {
        isLoading = true;
      });
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imagePath = pickedImage.path;
        imageFile1 = await pickedImage.readAsBytes();
        imageFile = await ApiClient().removeBgApi(imagePath!);
        colors = await getImagePalette(MemoryImage(imageFile!));
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      imageFile = null;
      setState(() {});
    }
    if (mounted) {
      setState(() {});
    }
  }

  List<Color> colors = [];
  // Calculate dominant color from ImageProvider
  Future<List<Color>> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.colors.toList();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 20,
          ),
          imageFile == null
              ? Center(
                  child: const Text('Choose your Image.'),
                )
              : SizedBox(),
          isLoading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox(),
          imageFile != null
              ? Image.memory(
                  imageFile1!,
                  width: MediaQuery.of(context).size.width * .8,
                  height: MediaQuery.of(context).size.height * .3,
                )
              : SizedBox(),
          SizedBox(
            height: 0,
          ),
          imageFile != null
              ? Image.memory(
                  imageFile!,
                  width: MediaQuery.of(context).size.width * .8,
                  height: MediaQuery.of(context).size.height * .3,
                )
              : SizedBox(),
          SizedBox(
            height: 20,
          ),
          imageFile != null
              ? Text(
                  'Colour Palette',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              : SizedBox(),
          SizedBox(
            height: 20,
          ),
          imageFile != null
              ? Container(
                  height: 40,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: colors.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          height: 20.0,
                          width: 15.0,
                          decoration: BoxDecoration(
                              color: colors[index], //this is the important line
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                        ),
                      ));
                    },
                  ),
                )
              : SizedBox(),
          Spacer(),
          Container(
            width: double.infinity,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  _showPicker(context);
                },
                child: const Text('Pick Image'),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
