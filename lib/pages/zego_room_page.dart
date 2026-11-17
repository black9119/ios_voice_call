import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:ios_voice_call/service/zego_service.dart';

class ZegoRoomPage extends StatefulWidget {
  const ZegoRoomPage({super.key});

  @override
  State<ZegoRoomPage> createState() => _ZegoRoomPageState();
}

class _ZegoRoomPageState extends State<ZegoRoomPage> {
  final String roomId = "room_001";
  late String userId;
  late String streamId;
  bool isPublishing = false;

  @override
  void initState() {
    super.initState();
    userId = DateTime.now().millisecondsSinceEpoch.toString();
    streamId = "stream_$userId";
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final zego = Provider.of<ZegoRoomService>(context, listen: false);
      await zego.initEngine();
      await zego.loginRoom(roomId, ZegoUser.id(userId));
    });
  }

  // 开始通话（推音频）
  Future<void> startCall() async {
    final zego = Provider.of<ZegoRoomService>(context, listen: false);
    await zego.startPublish(streamId);
    setState(() => isPublishing = true);
  }

  // 挂断
  Future<void> hangUp() async {
    final zego = Provider.of<ZegoRoomService>(context, listen: false);
    await zego.stopPublish();
    setState(() => isPublishing = false);
  }

  @override
  Widget build(BuildContext context) {
    final zego = Provider.of<ZegoRoomService>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("语音通话")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("当前角色：${zego.role == RoleType.a ? "A端接收方" : "B端控制方"}",
                style: const TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isPublishing ? hangUp : startCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPublishing ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text(isPublishing ? "挂断" : "开始通话", style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("退出房间"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    final zego = Provider.of<ZegoRoomService>(context, listen: false);
    zego.logoutRoom();
    super.dispose();
  }
}
