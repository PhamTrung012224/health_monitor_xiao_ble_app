import 'package:capstone_mobile_app/src/config/components/custom_textfield.dart';
import 'package:capstone_mobile_app/src/config/components/ui_icon.dart';
import 'package:capstone_mobile_app/src/config/components/ui_space.dart';
import 'package:capstone_mobile_app/src/config/constants/constants.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_up_screen/sign_up_bloc/sign_up_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_up_screen/sign_up_bloc/sign_up_event.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_up_screen/sign_up_bloc/sign_up_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:user_repository/user_repository.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool signUpRequired = false;
  bool obscurePassword = true;
  String? errorMessage;

  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          setState(() {
            signUpRequired = false;
          });
        } else if (state is SignUpProcess) {
          setState(() {
            signUpRequired = true;
          });
        } else if (state is SignUpFailure) {
          setState(() {
            signUpRequired = false;
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
                    state.errorMessage.replaceAll(RegExp(r'\[.*?\]\s?'), ''),
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
              children: [
                GestureDetector(
                  onTap: (){
                    context.go("/");
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric( horizontal: 16.0,vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_back,size: 48),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                UIIcon(size: 100, icon: IconConstants.accountBoxIcon, color: Theme.of(context).colorScheme.onBackground),
                const SizedBox(height: 24),
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
                          prefixIconColor: Theme.of(context).colorScheme.onSurface,
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
                          prefixIconColor: Theme.of(context).colorScheme.onSurface,
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
                          suffixIconColor: Theme.of(context).colorScheme.onSurface,
                          onChanged: (value) {
                            if (value!.contains(RegExp(r'(?=.*[A-Z])'))) {
                              setState(() {
                                containsUpperCase = true;
                              });
                            } else {
                              setState(() {
                                containsUpperCase = false;
                              });
                            }
                            if (value.contains(RegExp(r'.{8,}$'))) {
                              setState(() {
                                contains8Length = true;
                              });
                            } else {
                              setState(() {
                                contains8Length = false;
                              });
                            }
                            if (value.contains(RegExp(r'(?=.*[a-z])'))) {
                              setState(() {
                                containsLowerCase = true;
                              });
                            } else {
                              setState(() {
                                containsLowerCase = false;
                              });
                            }
                            if (value.contains(RegExp(
                                r'^(?=.*?[!@#$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^])'))) {
                              setState(() {
                                containsSpecialChar = true;
                              });
                            } else {
                              setState(() {
                                containsSpecialChar = false;
                              });
                            }
                            if (value.contains(RegExp(r'(?=.*[0-9])'))) {
                              setState(() {
                                containsNumber = true;
                              });
                            } else {
                              setState(() {
                                containsNumber = false;
                              });
                            }
                            return null;
                          },
                        ),
                        const UISpace(height: 16),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.86,
                          child: Wrap(
                            direction: Axis.horizontal,
                            spacing: 12.0,
                            runSpacing: 4.0,
                            children: [
                              Text(
                                '⚈ 1 Upper Case',
                                style: containsUpperCase
                                    ? TextStyleConstants.validText
                                    : TextStyleConstants.invalidText,
                              ),
                              Text(
                                '⚈ 1 Lower Case',
                                style: containsLowerCase
                                    ? TextStyleConstants.validText
                                    : TextStyleConstants.invalidText,
                              ),
                              Text(
                                '⚈ 1 Number',
                                style: containsNumber
                                    ? TextStyleConstants.validText
                                    : TextStyleConstants.invalidText,
                              ),
                              Text(
                                '⚈ 1 Special Character',
                                style: containsSpecialChar
                                    ? TextStyleConstants.validText
                                    : TextStyleConstants.invalidText,
                              ),
                              Text(
                                '⚈ 8 Characters',
                                style: contains8Length
                                    ? TextStyleConstants.validText
                                    : TextStyleConstants.invalidText,
                              ),
                            ],
                          ),
                        ),
                        const UISpace(height: 10),
                        CustomTextField(
                          width: MediaQuery.of(context).size.width,
                          text: 'Username',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          prefixIcon: const Icon(IconConstants.iconName),
                          textEditingController: nameController,
                          obscureText: false,
                          containerBorderRadius: 8,
                          containerColor: Theme.of(context).colorScheme.surface,
                          prefixIconColor: Theme.of(context).colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          focusNode: nameFocus,
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Please fill in this field';
                            } else if (!RegExp(Constants.rejectNameString)
                                .hasMatch(val)) {
                              return 'Please enter a valid name';
                            }
                            return null;
                          },
                          errorMsg: errorMessage,
                        ),
                        const UISpace(height: 20),
                        (!signUpRequired)
                            ? GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    MyUser myUser = MyUser.empty;
                                    myUser = myUser.copyWith(
                                      email: emailController.value.text,
                                      name: nameController.value.text,
                                    );
                                    context.read<SignUpBloc>().add(SignUpRequired(
                                        myUser: myUser,
                                        password: passwordController.value.text));
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
                                      "Sign Up",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
