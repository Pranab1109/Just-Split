import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_split/bloc/Avatar/avatarbloc_bloc.dart';
import 'package:just_split/bloc/auth/auth_bloc.dart';
import 'package:just_split/screens/LandingPage.dart';
import 'package:just_split/utils/Avatars.dart';
import 'package:just_split/utils/Cooloors.dart';
import 'package:just_split/utils/MyTextField.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final _formKeySignIn = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  void _authenticateWithEmailAndPassword(context, int avatar) {
    if (_formKeySignIn.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        SignUpRequested(_emailController.text, _passwordController.text, avatar,
            _nameController.text),
      );
    }
  }

//
  void _authenticateWithGoogle(context, int avatar, String userName) {
    BlocProvider.of<AuthBloc>(context).add(
      GoogleSignUpRequested(avatar, _nameController.text),
    );
  }

  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Stack(
        children: [
          Column(
            children: [
              // Top Section (Avatar Selection)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Pick an Avatar",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 120,
                        child: BlocBuilder<AvatarBloc, AvatarState>(
                          builder: (context, state) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: avatars.length,
                              itemBuilder: (ctx, index) {
                                final isSelected = selectedIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    selectedIndex = index;
                                    BlocProvider.of<AvatarBloc>(context)
                                        .add(AvatarIndexChangeRequest(index));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: isSelected ? 4 : 2,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.black26,
                                      ),
                                      boxShadow: isSelected
                                          ? const [
                                              BoxShadow(
                                                  color: Colors.black,
                                                  offset: Offset(2, 2))
                                            ]
                                          : null,
                                    ),
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: avatars[index],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Section (Form)
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: const Border(
                        top: BorderSide(color: Colors.black, width: 4)),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 40.0),
                      child: BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is Authenticated) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LandingPage(user: state.user)),
                            );
                          }
                        },
                        child: Form(
                          key: _formKeySignIn,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Create Account",
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 32),

                              MyTextField(
                                inputController: _nameController,
                                hintText: "Full Name",
                                formkey: _formKeySignIn,
                                isName: true,
                              ),
                              const SizedBox(height: 16),
                              MyTextField(
                                inputController: _emailController,
                                hintText: "Email Address",
                                formkey: _formKeySignIn,
                                isEmail: true,
                              ),
                              const SizedBox(height: 16),
                              MyTextField(
                                inputController: _passwordController,
                                hintText: "Password",
                                formkey: _formKeySignIn,
                                isPassword: true,
                              ),

                              const SizedBox(height: 32),

                              // Sign Up Button
                              Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: Cooloors.neoShadow,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKeySignIn.currentState!
                                        .validate()) {
                                      _authenticateWithEmailAndPassword(
                                          context,
                                          BlocProvider.of<AvatarBloc>(context)
                                              .avatarRepo
                                              .selectedAvatar);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(
                                        color: Colors.black, width: 3),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: const Text("SIGN UP",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                          fontSize: 16)),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Google Button
                              Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: Cooloors.neoShadow,
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.surface,
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(
                                        color: Colors.black, width: 3),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _authenticateWithGoogle(
                                      context,
                                      BlocProvider.of<AvatarBloc>(context)
                                          .avatarRepo
                                          .selectedAvatar,
                                      BlocProvider.of<AvatarBloc>(context)
                                          .avatarRepo
                                          .userName),
                                  icon: const FaIcon(FontAwesomeIcons.google,
                                      size: 20, color: Colors.black),
                                  label: BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      if (state is Loading) {
                                        return const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.black,
                                              strokeWidth: 3),
                                        );
                                      }
                                      return const Text("SIGNUP WITH GOOGLE",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13));
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Already have an account? Login",
                                  style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: const ThemeToggle(),
          ),
        ],
      ),
    );
  }
}
