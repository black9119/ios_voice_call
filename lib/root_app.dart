import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service/zego_service.dart';
import 'role.dart';
import 'pages/dial_page.dart';
import 'pages/role_setting_page.dart';
import 'pages/setting_page.dart';

final rootAppKey = GlobalKey<_RootAppState>();

class RootApp extends StatefulWidget {
  const RootApp({super.key});
  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  CallRole? role;

  void setRole(CallRole r) {
    setState(() {
      role = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ZegoRoomService.instance,
      child: MaterialApp(
        key: rootAppKey,
        title: "语音通话",
        theme: ThemeData.dark(),
        home: const DialPage(),
        routes: {
          "/roleSetting": (ctx) => RoleSettingPage(
            currentRole: role,
            onSaveRole: (r) => setRole(r),
          ),
          "/setting": (ctx) => const SettingPage(),
        },
      ),
    );
  }
}
