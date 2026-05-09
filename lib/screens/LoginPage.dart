import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_split/Services/AvatarRepo.dart';
import 'package:just_split/bloc/Avatar/avatarbloc_bloc.dart';
import 'package:just_split/bloc/auth/auth_bloc.dart';
import 'package:just_split/screens/LandingPage.dart';
import 'package:just_split/screens/SignupPage.dart';
import 'package:just_split/utils/Cooloors.dart';

// Cute neo-brutalist cat SVG
const String _catSvg = '''
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
  <!-- drop shadow -->
  <path d="M 50 180 C 20 180, 20 120, 20 100 L 30 40 L 70 70 C 90 60, 110 60, 130 70 L 170 40 L 180 100 C 180 120, 180 180, 150 180 Z" fill="#000000" transform="translate(8, 8)"/>
  <!-- cat body -->
  <path d="M 50 180 C 20 180, 20 120, 20 100 L 30 40 L 70 70 C 90 60, 110 60, 130 70 L 170 40 L 180 100 C 180 120, 180 180, 150 180 Z" fill="#ffffff" stroke="#000000" stroke-width="8" stroke-linejoin="round"/>
  <!-- eyes -->
  <circle cx="70" cy="120" r="10" fill="#000000"/>
  <circle cx="130" cy="120" r="10" fill="#000000"/>
  <!-- mouth: a little 'w' shape -->
  <path d="M 90 140 Q 95 155 100 140 Q 105 155 110 140" fill="none" stroke="#000000" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _authenticateWithEmailAndPassword(context) {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        SignInRequested(_emailController.text, _passwordController.text),
      );
    }
  }

  void _authenticateWithGoogle(context) {
    BlocProvider.of<AuthBloc>(context).add(
      GoogleSignUpRequested(0, null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary, // The purple background
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => LandingPage(user: state.user)),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                // Top Section (Illustration/Branding)
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // The SVG Cat
                        SizedBox(
                          height: 140,
                          width: 140,
                          child: SvgPicture.string(_catSvg),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Just Split",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Section (White/Dark Card)
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      border: const Border(
                        top: BorderSide(color: Colors.black, width: 4),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 40.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Welcome back!",
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Sign in to manage your expenses.",
                                style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withOpacity(0.6),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 32.0),

                              TextFormField(
                                controller: _emailController,
                                style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  hintText: "Email address",
                                  hintStyle: TextStyle(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.3)),
                                  prefixIcon: Icon(Icons.email_rounded,
                                      color: colorScheme.onSurface),
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: colorScheme.primary, width: 3.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Please enter Email address';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.3)),
                                  prefixIcon: Icon(Icons.lock_rounded,
                                      color: colorScheme.onSurface),
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: colorScheme.primary, width: 3.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Please enter Password';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32.0),

                              // Neo-brutalist Login Button
                              Container(
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: Cooloors.neoShadow,
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _authenticateWithEmailAndPassword(
                                          context);
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
                                  child: const Text("LOGIN",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                          fontSize: 16)),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Google Login Button
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
                                    foregroundColor: colorScheme.onSurface,
                                    side: BorderSide(
                                        color: colorScheme.onSurface, width: 3),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  onPressed: () =>
                                      _authenticateWithGoogle(context),
                                  icon: FaIcon(FontAwesomeIcons.google,
                                      size: 20, color: colorScheme.onSurface),
                                  label: BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      if (state is Loading) {
                                        return SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: colorScheme.onSurface,
                                              strokeWidth: 3),
                                        );
                                      }
                                      return const Text("CONTINUE WITH GOOGLE",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13));
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Register Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BlocProvider(
                                            create: (context) => AvatarBloc(
                                                context.read<AvatarRepo>()),
                                            child: SignUpPage(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Register here",
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Global Theme Toggle positioned at Top Right
            const Positioned(
              top: 50,
              right: 20,
              child: ThemeToggle(),
            ),
          ],
        ),
      ),
    );
  }
}
