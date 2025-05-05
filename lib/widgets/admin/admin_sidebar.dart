import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class AdminSideBar extends StatefulWidget {
  final SidebarXController controller;
  const AdminSideBar({
    super.key,
    required this.controller,
  });

  @override
  State<AdminSideBar> createState() => _AdminSideBarState();
}

class _AdminSideBarState extends State<AdminSideBar> {
bool _isLoading = false;
void logout()async{
  final auth =  FirebaseAuth.instance;

  try {
    setState(() {
      _isLoading = true;

    });

    await auth.signOut();
  } catch (e) {
    print(e);
  }
  finally{
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      // ↓↓↓ Add this ↓↓↓
showToggleButton: true,
toggleButtonBuilder: (context, extended) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Divider(               // ← top border
        height: 1,
        thickness: 1,
        color: Colors.white.withOpacity(0.3),
      ),
      InkWell(
        key: const Key('custom_toggle'),
        onTap: () {
          widget.controller.toggleExtended();  // toggle collapse/expand
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(
            extended
                ? Icons.arrow_back_ios_new
                : Icons.arrow_forward_ios,
            size: 20,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    ],
  );
},
// ↑↑↑ End addition ↑↑↑

      controller: widget.controller,
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
      // footerDivider: Divider(
      //   color: Colors.white.withOpacity(0.5),
      //   height: 1,
      // ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/logo.png'),
          ),
        );
      },
      footerItems: [
SidebarXItem(
          selectable: false,
          icon: Icons.logout_rounded,
          label: 'Logout',
         
          onTap: _isLoading ? null : logout,
        ),
      ],
      items: [
     
        SidebarXItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          onTap: () {
            widget.controller.selectIndex(0);
            debugPrint(widget.controller.selectedIndex.toString());
          },
        ),
        SidebarXItem(
          icon: Icons.web,
          label: 'Websites',
          onTap: () {
            widget.controller.selectIndex(1);
            debugPrint(widget.controller.selectedIndex.toString());
          },
        ),
         
      ],
    
    );
    
  }
}
