import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../Widgets/user_image_picker.dart';

final fireBase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  File? passedSelectedImage;
  bool isAuthentication = false;
  bool _isLogIn = true;
  String enteredEmail = '';
  String enteredUserName = '';
  String enteredPass = '';
  final _formKey = GlobalKey<FormState>();
  void onSubmitted() async {
    bool isValidate = _formKey.currentState!.validate();
    if (!isValidate || !_isLogIn&&passedSelectedImage == null) {
      return;
    }

    _formKey.currentState!.save();
    try {
      setState(() {
        isAuthentication = true;
      });
      if (_isLogIn) {
        final userCredential = await fireBase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPass);
      } else {
        final userCredential = await fireBase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPass);
        final storageRef = FirebaseStorage.instance.ref().child('user_images').child("${userCredential.user!.uid}.jpg");
        await storageRef.putFile(passedSelectedImage!);
        final imgUrl =await storageRef.getDownloadURL();
        FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(
            {
              'userName' :enteredUserName ,
              'eMail' :enteredEmail,
              'imgUrl' : imgUrl
            });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication Failed')));
      setState(() {
        isAuthentication = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              margin: const EdgeInsets.only(
                  top: 30, bottom: 20, left: 20, right: 20),
              child: Image.asset('assets/images/chat.png'),
            ),
            Card(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogIn)
                            UserImagePicker(
                              selectedImageFunction: (mySelectedImage) {
                                passedSelectedImage = mySelectedImage;
                              },
                            ),
                          TextFormField(
                            onSaved: (value) {
                              enteredEmail = value!;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please Enter Valid Email';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            decoration: const InputDecoration(
                              labelText: 'Email Adress',
                            ),
                          ),
                          if(!_isLogIn)
                            TextFormField(
                              validator: (value){
                                if(value ==null || value.trim().isEmpty || value.trim().length<4){
                                  return 'Please Enter Valid User Name';
                                }
                                return null;
                              },
                              onSaved: (value){
                                enteredUserName = value!;
                              },
                              decoration: InputDecoration(
                                labelText: 'User Name'
                              ),
                            ),
                          TextFormField(
                            onSaved: (value) {
                              enteredPass = value!;
                            },
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 character';
                              }
                              return null;
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if(isAuthentication)
                            CircularProgressIndicator(),
                          if(!isAuthentication)
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              onPressed: () {
                                onSubmitted();
                              },
                              child: Text(_isLogIn ? ' Sign In' : 'Sign Up')),
                          if(!isAuthentication)
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogIn = !_isLogIn;
                                });
                              },
                              child: Text(_isLogIn
                                  ? 'Create An Account'
                                  : 'Already Have An Account'))
                        ],
                      )),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
