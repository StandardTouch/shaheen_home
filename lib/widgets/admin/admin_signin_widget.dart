import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as emailAuth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shaheen_home/screens/admin/admin_dashboard_screen.dart';

class AdminSigninWidget extends StatelessWidget {
  const AdminSigninWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      sideBuilder: (context, constraints) {
        return Container(
          height: double.infinity,
          color: Colors.green,
          child: Image.asset(
            "assets/images/logo.png",
            scale: 0.5,
          ),
        );
      },
      showAuthActionSwitch: false,
      showPasswordVisibilityToggle: true,
      providers: [emailAuth.EmailAuthProvider()],
      actions: [
        AuthStateChangeAction<UserCreated>((context, state) {
          // Put any new user logic here
          // this is not getting trigerred since there is no user created button
          // onSignedIn();
        }),
        AuthStateChangeAction<SignedIn>((context, state) {
          context.go(AdminDashboardScreen.route);
          // onSignedIn();
        }),
      ],
    );
  }
}
