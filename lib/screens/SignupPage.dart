import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_split/bloc/Avatar/avatarbloc_bloc.dart';
import 'package:just_split/bloc/auth/auth_bloc.dart';
import 'package:just_split/screens/LandingPage.dart';
import 'package:just_split/utils/Avatars.dart';
import 'package:just_split/utils/MyTextField.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({Key? key}) : super(key: key);
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
  void _authenticateWithGoogle(context, int avatar) {
    BlocProvider.of<AuthBloc>(context).add(
      GoogleSignUpRequested(avatar),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Sign Up",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
              SizedBox(
                height: 200,
                child: BlocBuilder<AvatarBloc, AvatarState>(
                  builder: (context, state) {
                    return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 100,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10),
                        itemCount: avatars.length,
                        itemBuilder: (BuildContext ctx, index) {
                          return GestureDetector(
                            onTap: () {
                              BlocProvider.of<AvatarBloc>(context)
                                  .add(AvatarChangeRequest(index));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5.0),
                              width: 30,
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  // color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 2,
                                      color: state.selected == index
                                          ? Colors.white
                                          : Colors.transparent)),
                              child: Container(
                                padding: const EdgeInsets.all(5.0),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: avatars[index],
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is Authenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LandingPage(user: state.user)),
                    );
                  } else if (state is AuthError) {
                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    //   content: Text(state.error),
                    //   behavior: SnackBarBehavior.floating,
                    // ));
                    print(state.error);
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }
                    if (state is UnAuthenticated) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _formKeySignIn,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: MyTextField(
                                    inputController: _nameController,
                                    hintText: "Name",
                                    formkey: _formKeySignIn,
                                    isName: true,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: MyTextField(
                                    inputController: _emailController,
                                    hintText: "Email",
                                    formkey: _formKeySignIn,
                                    isEmail: true,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: MyTextField(
                                    inputController: _passwordController,
                                    hintText: "Password",
                                    formkey: _formKeySignIn,
                                    isPassword: true,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.white),
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
                                    child: SizedBox(
                                      height: 50.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: const Center(
                                        child: Text(
                                          "Sign Up",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18.0),
                                        ),
                                      ),
                                    )),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.white),
                                    onPressed: () {
                                      _authenticateWithGoogle(
                                          context,
                                          BlocProvider.of<AvatarBloc>(context)
                                              .avatarRepo
                                              .selectedAvatar);
                                    },
                                    child: SizedBox(
                                      height: 50.0,
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          FaIcon(FontAwesomeIcons.google,
                                              color: Colors.black),
                                          SizedBox(
                                            width: 12.0,
                                          ),
                                          Text(
                                            "Signup with Google",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0),
                                          )
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
