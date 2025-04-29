import 'package:flutter/material.dart';
import 'package:shaheen_home/widgets/admin/tabs/admin_dashboard_tab.dart';
import 'package:shaheen_home/widgets/admin/tabs/admin_websites_tab.dart';
import 'package:sidebarx/sidebarx.dart';

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key, required this.controller});
  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          switch (controller.selectedIndex) {
            case 0:
              return Expanded(
                child: const AdminDashboardTab(),
              );
            case 1:
              return Expanded(
                child: const AdminWebsitesTab(),
              );
            default:
              return const Placeholder();
          }
        });
  }
}
