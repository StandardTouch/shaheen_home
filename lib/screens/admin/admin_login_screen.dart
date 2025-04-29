import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shaheen_home/screens/admin/admin_dashboard_screen.dart';
import 'package:shaheen_home/widgets/admin/admin_signin_widget.dart';

class AdminLoginScreen extends StatelessWidget {
  static const route = "/admin/login";
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          //
          return AdminSigninWidget();
        }
        // if authenticated, navigate to admin dashboard
        return const AdminDashboardScreen();
      },
    );
  }
}
