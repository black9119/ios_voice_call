import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/zego_service.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final zego = Provider.of<ZegoRoomService>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("隐藏设置页"),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "选择设备角色",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text(
                "A端【接收方，播放/空号】",
                style: TextStyle(color: Colors.white),
              ),
              // ✅ 修复：两边都返回Color，不再返回null
              tileColor: zego.role == RoleType.a ? Colors.blueGrey : Colors.transparent,
              onTap: () {
                zego.setRole(RoleType.a);
              },
            ),
            ListTile(
              title: const Text(
                "B端【控制端，可以下发指令】",
                style: TextStyle(color: Colors.white),
              ),
              tileColor: zego.role == RoleType.b ? Colors.blueGrey : Colors.transparent,
              onTap: () {
                zego.setRole(RoleType.b);
              },
            ),
            const SizedBox(height: 30),
            const Text(
              "说明：",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              "A端只能接收通话、接收指令播放提示音",
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("返回"),
            ),
          ],
        ),
      ),
    );
  }
}
