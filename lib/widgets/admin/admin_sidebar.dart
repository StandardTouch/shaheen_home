import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class AdminSideBar extends StatelessWidget {
  final SidebarXController controller;
  const AdminSideBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: Theme.of(context).colorScheme.primary,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.primary),
        ),
        selectedItemDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,

          borderRadius: BorderRadius.circular(10),
          // border: Border.all(
          //   color: Theme.of(context).colorScheme.primary.withOpacity(0.37),
          // ),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      footerDivider: Divider(
        color: Colors.white.withOpacity(0.5),
        height: 1,
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/logo.png'),
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          onTap: () {
            controller.selectIndex(0);
            debugPrint(controller.selectedIndex.toString());
          },
        ),
        SidebarXItem(
          icon: Icons.web,
          label: 'Websites',
          onTap: () {
            controller.selectIndex(1);
            debugPrint(controller.selectedIndex.toString());
          },
        ),
      ],
    );
  }
}
