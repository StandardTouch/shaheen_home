import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shaheen_home/widgets/admin/admin_dashboard_content.dart';
import 'package:shaheen_home/widgets/admin/admin_sidebar.dart';
import 'package:shaheen_home/widgets/admin/admin_signin_widget.dart';
import 'package:sidebarx/sidebarx.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const route = "/admin/dashboard";
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final controller = SidebarXController(selectedIndex: 0, extended: true);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(

      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
         if (!snapshot.hasData) {
          //
          return AdminSigninWidget();
        }
        return Scaffold(
          body: Row(
            children: [
              // sidebar
              AdminSideBar(controller: controller),
              // create a widget that takes in controller and returns a widget
              AdminDashboardContent(controller: controller),
            ],
          ),
        );
      }
    );
  }
}
