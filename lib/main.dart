import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'service/zego_room_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zego Voice Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RoomPage(),
    );
  }
}

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final ZegoRoomService _roomService = ZegoRoomService.instance;
  final TextEditingController _roomIdCtrl = TextEditingController(text: "room001");
  final TextEditingController _userIdCtrl = TextEditingController(text: "user001");
  final TextEditingController _userNameCtrl = TextEditingController(text: "user001");
  bool _inRoom = false;

  @override
  void initState() {
    super.initState();
    _roomService.initEngine();
  }

  Future<void> _joinRoom() async {
    final roomId = _roomIdCtrl.text.trim();
    final userId = _userIdCtrl.text.trim();
    final userName = _userNameCtrl.text.trim();
    if (roomId.isEmpty || userId.isEmpty) return;

    await _roomService.loginRoom(roomId, ZegoUser(userId, userName));
    setState(() {
      _inRoom = true;
    });
  }

  Future<void> _leaveRoom() async {
    await _roomService.logoutRoom();
    setState(() {
      _inRoom = false;
    });
  }

  Future<void> _startPublish() async {
    await _roomService.startPublish("stream_${_userIdCtrl.text}");
  }

  Future<void> _stopPublish() async {
    await _roomService.stopPublish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zego 语音房间")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _roomIdCtrl,
              decoration: const InputDecoration(labelText: "RoomID"),
              enabled: !_inRoom,
            ),
            TextField(
              controller: _userIdCtrl,
              decoration: const InputDecoration(labelText: "UserID"),
              enabled: !_inRoom,
            ),
            TextField(
              controller: _userNameCtrl,
              decoration: const InputDecoration(labelText: "UserName"),
              enabled: !_inRoom,
            ),
            const SizedBox(height: 16),
            if (!_inRoom)
              ElevatedButton(onPressed: _joinRoom, child: const Text("加入房间"))
            else
              Column(
                children: [
                  ElevatedButton(onPressed: _leaveRoom, child: const Text("退出房间")),
                  ElevatedButton(onPressed: _startPublish, child: const Text("开始推流")),
                  ElevatedButton(onPressed: _stopPublish, child: const Text("停止推流")),
                  ValueListenableBuilder<List<String>>(
                    valueListenable: _roomService.remoteStreamIdList,
                    builder: (ctx, streams, child) {
                      return Column(
                        children: streams.map((sid) {
                          return FutureBuilder<Widget?>(
                            future: _roomService.startPlayStream(sid),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return SizedBox(height: 200, child: snapshot.data!);
                              }
                              return Text("等待播放 $sid");
                            },
                          );
                        }).toList(),
                      );
                    },
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomService.destroy();
    super.dispose();
  }
}
