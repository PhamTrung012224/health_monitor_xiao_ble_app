import 'package:capstone_mobile_app/src/config/components/ui_icon.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_bloc/sign_in_bloc.dart';
import 'package:capstone_mobile_app/src/config/presentations/authentication_screen/sign_in_screen/sign_in_bloc/sign_in_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../constants/constants.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  const HomeScreen({super.key, required this.title});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  BuildContext? _context;
  ColorScheme? _colorScheme;
  // bool isDarkMode = false;
  bool _isLoadingLogOut = false;

  @override
  void didChangeDependencies() {
    // isDarkMode = (Theme.of(context).brightness == Brightness.dark);
    _context = context;
    _colorScheme = Theme.of(context).colorScheme;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          color: _colorScheme!.background,
        ),
        SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                toolbarHeight: 70,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const UIIcon(
                        size: 32,
                        icon: IconConstants.bluetoothIcon,
                        color: Colors.black),
                    GestureDetector(
                        onTap: () async {
                          setState(() {
                            _isLoadingLogOut = true;
                          });
                          _context!.read<SignInBloc>().add(SignOutRequired());
                          setState(() {
                            _isLoadingLogOut = false;
                          });
                        },
                        child: const UIIcon(
                            size: 32,
                            icon: IconConstants.logoutIcon,
                            color: Colors.black)),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(24),
                  child: Center(
                      child: Text(
                    "IMU Data Dashboard",
                    style: TextStyleConstants.tabBarTitle,
                  )),
                ),
                pinned: true,
                backgroundColor: _colorScheme!.tertiaryContainer,
                expandedHeight: MediaQuery.of(context).size.height * 0.24,
                flexibleSpace: const FlexibleSpaceBar(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          height: MediaQuery.of(context).size.height * 0.18,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16)),
                              color: _colorScheme!.primaryContainer),
                          margin: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Accelerate",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _colorScheme!.onPrimaryContainer),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'x: ?.????',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _colorScheme!.onPrimaryContainer),
                                    ),
                                    Text(
                                      'y: ?.????',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _colorScheme!.onPrimaryContainer),
                                    ),
                                    Text(
                                      'z: ?.????',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _colorScheme!.onPrimaryContainer),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          height: MediaQuery.of(context).size.height * 0.18,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16)),
                              color: _colorScheme!.primaryContainer),
                          margin: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Gyroscope",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _colorScheme!.onPrimaryContainer),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'x: ?.????',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _colorScheme!.onPrimaryContainer),
                                    ),
                                    Text(
                                      'y: ?.????',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _colorScheme!.onPrimaryContainer),
                                    ),
                                    Text(
                                      'z: ?.????',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              _colorScheme!.onPrimaryContainer),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Direct use of ListView with shrinkWrap
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 10,
                          padding: EdgeInsets.zero,
                          // Constrain the ListView within the column
                          itemBuilder: (context, idx) {
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                  color: _colorScheme!.primaryContainer),
                              height: MediaQuery.of(context).size.height * 0.18,
                              margin:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        _isLoadingLogOut
            ? Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: _colorScheme!.primary, size: 90),
              )
            : const SizedBox()
      ],
    );
  }

  @override
  void dispose() {
    _context = null;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
