import 'package:RollaStrava/src/constants/app_styles.dart';
import 'package:RollaStrava/src/translate/en.dart';
import 'package:RollaStrava/src/utils/index.dart';
import 'package:RollaStrava/src/widget/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  double screenHeight = 0;
  double keyboardHeight = 0;
  final int _currentIndex = 4;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String previousUsernameText = '@smith';
  String previousNameText = 'Brian Smith';
  String previousBioText = 'Life is good!';
  String previousGarageText = 'Lixus, BMW';
  String previousPlaceText = 'Lake Placid, NY';

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController garageController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  

  bool _showSaveButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (mounted) {
        setState(() {
          this.keyboardHeight = keyboardHeight;
        });
      } 
    });
    usernameController.text = previousUsernameText;
    nameController.text = previousNameText;
    bioController.text = previousBioText;
    garageController.text = previousGarageText;
    placeController.text = previousPlaceText;

    usernameController.addListener(_onTextChanged);
    nameController.addListener(_onTextChanged);
    bioController.addListener(_onTextChanged);
    garageController.addListener(_onTextChanged);
    placeController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.removeListener(_onTextChanged);
    nameController.removeListener(_onTextChanged);
    bioController.removeListener(_onTextChanged);
    garageController.removeListener(_onTextChanged);
    placeController.removeListener(_onTextChanged);
    usernameController.dispose();
    nameController.dispose();
    bioController.dispose();
    garageController.dispose();
    placeController.dispose();
  }

  void _onTextChanged() {
    if (!_showSaveButton) {
      setState(() {
        if (usernameController.text != previousUsernameText) {
          _showSaveButton = true;
          previousUsernameText = usernameController.text;
        }
        if (nameController.text != previousNameText) {
          _showSaveButton = true;
          previousNameText = nameController.text;
        }
        if (bioController.text != previousBioText) {
          _showSaveButton = true;
          previousBioText = bioController.text;
        }
        if (garageController.text != previousGarageText) {
          _showSaveButton = true;
          previousGarageText = garageController.text;
        }
        if (placeController.text != previousPlaceText) {
          _showSaveButton = true;
          previousPlaceText = placeController.text;
        }
      });
    }
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      _selectedImage = photo;
                      _showSaveButton = true;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? galleryImage = await _picker.pickImage(source: ImageSource.gallery);
                  if (galleryImage != null) {
                    setState(() {
                      _selectedImage = galleryImage;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: FocusScope(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: vhh(context, 90),
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: IntrinsicHeight(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: kColorWhite,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: vww(context, 4)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: vhh(context, 10)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'assets/images/icons/allow-left.png',
                                width: vww(context, 5),
                              ),
                            ),
                            
                            const Text(edit_profile, style: TextStyle(color: kColorBlack, fontSize: 18, fontWeight: FontWeight.bold),),

                            Container(),
                          ],
                        ),

                        SizedBox(height: vhh(context, 1)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: kColorGrey,
                                borderRadius: BorderRadius.circular(200),
                                border: Border.all(
                                    color: kColorHereButton, width: 2),
                                    image: _selectedImage != null
                                      ? DecorationImage(
                                          image: FileImage(
                                            File(_selectedImage!.path),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null, 
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: vhh(context, 1)),
                        GestureDetector(
                          onTap: () {
                            _showPicker(context);
                          },
                          child: const Text(
                            'Change Profile Photo',
                            style: TextStyle(
                              color: Colors.black, // Replace with `kColorBlack` if defined
                              fontSize: 18,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        SizedBox(height: vhh(context, 2),),

                        const Divider(color: kColorGrey, thickness: 1),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  edit_profile_username,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  width: 200, // Adjust width as needed
                                  height: 25,
                                  child: TextField(
                                    controller: usernameController,
                                    textAlign: TextAlign.right,
                                    maxLines: 1, // Restrict to a single line
                                    maxLength: 20,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none, // Remove underline
                                      contentPadding: EdgeInsets.only(bottom: 15),
                                      counterText: '', // Removes the counter text (10/10)
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black, // Replace with kColorBlack
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: kColorGrey, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  edit_profile_name,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  width: 200, // Adjust width as needed
                                  height: 25,
                                  child: TextField(
                                    controller: nameController,
                                    textAlign: TextAlign.right,
                                    maxLines: 1, // Restrict to a single line
                                    maxLength: 20,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none, // Remove underline
                                      contentPadding: EdgeInsets.only(bottom: 15),
                                      counterText: '', // Removes the counter text (10/10)
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black, // Replace with kColorBlack
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: kColorGrey, thickness: 1),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  edit_profile_bio,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  width: 200, // Adjust width as needed
                                  height: 25,
                                  child: TextField(
                                    controller: bioController,
                                    textAlign: TextAlign.right,
                                    maxLines: 1, // Restrict to a single line
                                    maxLength: 20,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none, // Remove underline
                                      contentPadding: EdgeInsets.only(bottom: 15),
                                      counterText: '', // Removes the counter text (10/10)
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black, // Replace with kColorBlack
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: vhh(context, 7)),
                            const Divider(color: kColorGrey, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  edit_profile_garage,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  width: 200, // Adjust width as needed
                                  height: 25,
                                  child: TextField(
                                    controller: garageController,
                                    textAlign: TextAlign.right,
                                    maxLines: 1, // Restrict to a single line
                                    maxLength: 20,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none, // Remove underline
                                      contentPadding: EdgeInsets.only(bottom: 15),
                                      counterText: '', // Removes the counter text (10/10)
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black, // Replace with kColorBlack
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: kColorGrey, thickness: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  edit_profile_happy_place,
                                  style: TextStyle(color: kColorGrey, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                                SizedBox(
                                  width: 200, // Adjust width as needed
                                  height: 25,
                                  child: TextField(
                                    controller: placeController,
                                    textAlign: TextAlign.right,
                                    maxLines: 1, // Restrict to a single line
                                    maxLength: 20,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none, // Remove underline
                                      contentPadding: EdgeInsets.only(bottom: 15),
                                      counterText: '', // Removes the counter text (10/10)
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black, // Replace with kColorBlack
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlignVertical: TextAlignVertical.center,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: kColorGrey, thickness: 1),
                            if (_showSaveButton)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle save logic here
                                    setState(() {
                                      _showSaveButton = false; // Hide the button after saving
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue, // Customize as needed
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                  ),
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }

}
