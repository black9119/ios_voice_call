import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/zego_service.dart';
import '../role.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("隐藏设置页"),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<ZegoRoomService>(
          builder: (context, zego, child) {
            return Column(
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
                  tileColor: zego.role == CallRole.a ? Colors.blueGrey : Colors.transparent,
                  onTap: () {
                    zego.setRole(CallRole.a);
                  },
                ),
                ListTile(
                  title: const Text(
                    "B端【发送方，呼叫】",
                    style: TextStyle(color: Colors.white),
                  ),
                  tileColor: zego.role == CallRole.b ? Colors.blueGrey : Colors.transparent,
                  onTap: () {
                    zego.setRole(CallRole.b);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
