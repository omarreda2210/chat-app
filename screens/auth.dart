// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chat_app/widegts/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLogging = true;
  final formKey = GlobalKey<FormState>();
  var enterdEmail = '';
  var enterdPassword = '';
  File? selectedimage;
  var isuplodaing = false;
  var enterdUsername = '';

  void submit() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid || !isLogging && selectedimage == null) {
      return;
    }

    formKey.currentState!.save();
    try {
      setState(() {
        isuplodaing = true;
      });
      if (isLogging) {
        final userCandi = await firebase.signInWithEmailAndPassword(
            email: enterdEmail, password: enterdPassword);
      } else {
        final userCandi = await firebase.createUserWithEmailAndPassword(
            email: enterdEmail, password: enterdPassword);

        final storgeRef = FirebaseStorage.instance
            .ref()
            .child('users_images')
            .child('${userCandi.user!.uid}.jpg');
        await storgeRef.putFile(selectedimage!);
        final imageUrl = await storgeRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCandi.user!.uid)
            .set({
          'username': enterdUsername,
          'email': enterdEmail,
          'Image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authenticatoin faild.'),
        ),
      );
      setState(() {
        isuplodaing = false;
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
                margin: const EdgeInsets.only(
                  top: 30,
                  right: 20,
                  left: 20,
                  bottom: 20,
                ),
                width: 200,
                child: Image.asset('assests/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLogging)
                            UserImagePicker(
                              onPickedImage: (pickedImage) {
                                selectedimage = pickedImage;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Adress'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid emill adress';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              enterdEmail = value!;
                            },
                          ),
                          if (!isLogging)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length < 4 ||
                                    value.isEmpty ||
                                    value.trim().length > 36) {
                                  return 'Plase enter a viled username betwwen 4 and 32characters long ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                enterdUsername = value!;
                              },
                            ),
                          TextFormField(
                            onSaved: (value) {
                              enterdPassword = value!;
                            },
                            decoration:
                                const InputDecoration(labelText: 'password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 13,
                          ),
                          if (isuplodaing) const CircularProgressIndicator(),
                          if (!isuplodaing)
                            ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(isLogging ? 'LogIn' : 'SignUp'),
                            ),
                          if (!isuplodaing)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogging = !isLogging;
                                });
                              },
                              child: Text(
                                isLogging
                                    ? 'Create an account'
                                    : 'I already have an account',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
