import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final compressedImage = await ImageHelper.compressImage(File(image.path));
      if (compressedImage != null) {
        setState(() {
          _imageFile = compressedImage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(LoadProfile()),
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            // Only update controllers if they are empty (initial load)
            if (_nameController.text.isEmpty) {
              _nameController.text = state.user.name;
              _phoneController.text = state.user.phone;
            }
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && _nameController.text.isEmpty) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Use the context from the builder (which is under BlocProvider)
                      // But wait, this AppBar is OUTSIDE the BlocConsumer builder in the current structure?
                      // Let's check the structure.
                      // Scaffold is child of BlocConsumer? No.
                      // BlocConsumer is child of BlocProvider.
                      // Scaffold is child of BlocConsumer.
                      // So 'context' here is from 'build' method, which is ABOVE BlocProvider.
                      // We need to use a Builder or move BlocProvider up.
                      // Actually, let's look at the file again.
                      // BlocProvider -> BlocConsumer -> Scaffold.
                      // So the context in AppBar actions is from BlocConsumer's builder?
                      // No, wait.
                      // builder: (context, state) { return Scaffold(...) }
                      // Yes! The Scaffold is returned by the builder.
                      // So 'context' inside the builder IS the one we want.
                      // BUT, the IconButton is inside AppBar, which is inside Scaffold.
                      // So if we use 'context' from the builder, it should work.
                      
                      // However, let's make sure we are using the 'context' from the builder parameter, 
                      // not the 'context' from the build method.
                      // In the code: builder: (context, state) { ... return Scaffold(...) }
                      // The 'context' variable name shadows the build method's context.
                      // So it SHOULD be correct.
                      
                      context.read<ProfileBloc>().add(
                            UpdateProfile(
                              name: _nameController.text,
                              phone: _phoneController.text,
                              photo: _imageFile,
                            ),
                          );
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (state is ProfileLoaded && state.user.photoUrl != null
                                ? NetworkImage(state.user.photoUrl!)
                                : null) as ImageProvider?,
                        child: _imageFile == null &&
                                (state is! ProfileLoaded ||
                                    state.user.photoUrl == null)
                            ? const Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Change Photo'),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    if (state is ProfileLoading) ...[
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
