import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_bloc/sign_in_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_bloc/sign_in_event.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_bloc/sign_in_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../components/custom_textfield.dart';
import '../../../components/square_tile.dart';
import '../../../components/ui_space.dart';
import '../../../constants/constants.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool signInRequired = false;
  bool obscurePassword = true;
  String? errorMessage;


  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          setState(() {
            signInRequired = false;
          });
        } else if (state is SignInProcess) {
          setState(() {
            signInRequired = true;
          });
        } else if (state is SignInFailure) {
          setState(() {
            signInRequired = false;
            final snackBar = SnackBar(
                backgroundColor: const Color(0xFF322F35),
                padding: const EdgeInsets.only(left: 16, right: 8),
                content: Container(
                  alignment: Alignment.centerLeft,
                  height: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Text(
                    'Invalid email or password.',
                    style: TextStyleConstants.snackBarText,
                  ),
                ),
                elevation: 6,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
          
                // logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
          
                const SizedBox(height: 48),
          
                // welcome back, you've been missed!
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
          
                const SizedBox(height: 24),
          
                // username text field
                Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const UISpace(height: 16),
                        CustomTextField(
                          width: MediaQuery.of(context).size.width,
                          text: 'Email',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          prefixIcon: const Icon(IconConstants.iconMail),
                          textEditingController: emailController,
                          obscureText: false,
                          containerBorderRadius: 8,
                          containerColor: Theme.of(context).colorScheme.surface,
                          prefixIconColor:
                              Theme.of(context).colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          focusNode: emailFocus,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            } else if (!RegExp(Constants.rejectEmailString)
                                .hasMatch(val)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          errorMsg: errorMessage,
                        ),
                        const UISpace(height: 16),
                        CustomTextField(
                          width: MediaQuery.of(context).size.width,
                          text: 'Password',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          prefixIcon: const Icon(IconConstants.iconPassword),
                          textEditingController: passwordController,
                          obscureText: obscurePassword,
                          containerBorderRadius: 8,
                          containerColor: Theme.of(context).colorScheme.surface,
                          prefixIconColor:
                              Theme.of(context).colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          focusNode: passwordFocus,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            } else if (!RegExp(Constants.rejectPasswordString)
                                .hasMatch(val)) {
                              return 'Please enter a valid password';
                            }
                            return null;
                          },
                          errorMsg: errorMessage,
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              child: Icon(obscurePassword
                                  ? IconConstants.iconHidePassword
                                  : IconConstants.iconShowPassword)),
                          suffixIconColor:
                              Theme.of(context).colorScheme.onSurface,
                        ),

                        const UISpace(height: 40),
          
                        (!signInRequired)
                            ? GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<SignInBloc>().add(
                                        SignInRequired(
                                            email: emailController.value.text,
                                            password:
                                                passwordController.value.text));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: LoadingAnimationWidget.discreteCircle(
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 40,
                                ),
                              ),
                      ],
                    )),
          
                const SizedBox(height: 48),
          
                // or continue with
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
          
                UISpace(height: MediaQuery.of(context).size.height*0.18),
          
                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Not a member?',
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: (){
                        context.go("/signup");
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
