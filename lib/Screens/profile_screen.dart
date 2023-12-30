import 'dart:developer';
import 'dart:io';

import 'package:appchat/Resources/color.dart';
import 'package:appchat/Resources/fonts_sizes.dart';
import 'package:appchat/Screens/Auth/login.dart';
import 'package:appchat/api/api.dart';
import 'package:appchat/helper/dialogs.dart';
import 'package:appchat/main.dart';
import 'package:appchat/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ChatUser> list = [];
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding Keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showCircularProgress(context);
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                });
              });
            },
            icon: Icon(Icons.logout_outlined),
            label: Text('Logout'),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.height * .03),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: mq.height * 0.03,
                      width: mq.height,
                    ),
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(
                                  File(_image!),
                                  width: mq.height * 0.2,
                                  height: mq.height * 0.2,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: CachedNetworkImage(
                                  width: mq.height * 0.2,
                                  height: mq.height * 0.2,
                                  fit: BoxFit.fill,
                                  imageUrl: widget.user.image,
                                  // placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                    child: Icon(CupertinoIcons.person),
                                  ),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            color: Colors.white,
                            shape: CircleBorder(),
                            child: Icon(Icons.edit),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: mq.height * 0.03,
                    ),
                    Text(
                      widget.user.email,
                      style: TextStyle(
                          fontSize: 18, color: AppColors.darkGrayColor),
                    ),
                    SizedBox(
                      height: mq.height * 0.03,
                    ),
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg: Abdul',
                          label: Text('Name'),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.blue,
                          )),
                    ),
                    SizedBox(
                      height: mq.height * 0.02,
                    ),
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'Feeling Good',
                          label: Text('About'),
                          prefixIcon: Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                          )),
                    ),
                    SizedBox(
                      height: mq.height * 0.02,
                    ),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            minimumSize: Size(mq.width * .4, mq.height * .06)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save;
                            APIs.updateUserInfo().then((value) {
                              Dialogs.showSnackbar(
                                  context, 'Profile updated Successfully');
                            });
                          }
                        },
                        icon: Icon(
                          Icons.update,
                          size: 26,
                        ),
                        label: Text(
                          'Update',
                          style: TextStyle(fontSize: 19),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              Text(
                'Pick Profile Photo',
                style: kHeading3TextStyle,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: mq.height * .01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.whiteColor,
                          fixedSize: Size(mq.height * .15, mq.height * .15),
                          shape: CircleBorder()),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          Navigator.pop(context);
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                        }
                      },
                      child: Image.asset('assets/gallery.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.whiteColor,
                          fixedSize: Size(mq.height * .15, mq.height * .15),
                          shape: CircleBorder()),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          Navigator.pop(context);
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                        }
                      },
                      child: Image.asset('assets/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
