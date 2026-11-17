import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:ios_voice_call/service/zego_service.dart';

class DialPage extends StatefulWidget {
  const DialPage({super.key});

  @override
  State<DialPage> createState() => _DialPageState();
}

enum CallState {
  idle, // 空闲
  calling, // 呼叫中（B端呼出）
  incoming, // 收到来电（A端）
  onCall, // 通话中
}

class _DialPageState extends State<DialPage> {
  final TextEditingController _targetRoomCtrl = TextEditingController(text: "room_001");
  CallState _callState = CallState.idle;
  bool _micOn = true;
  bool _speakerOn = false;

  // 计时
  Timer? _timer;
  int _callSeconds = 0;

  late String _myUserId;
  late String _myStreamId;
  String _roomId = "room_001";

  @override
  void initState() {
    super.initState();
    _myUserId = DateTime.now().millisecondsSinceEpoch.toString();
    _myStreamId = "stream_$_myUserId";
  }

  /// 开始计时
  void _startTimer() {
    _callSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callSeconds++;
      });
    });
  }

  /// 停止计时
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 格式化 00:00
  String _formatTime(int sec) {
    int m = sec ~/ 60;
    int s = sec % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  /// B端发起呼叫
  Future<void> _call() async {
    final zego = Provider.of<ZegoRoomService>(context, listen: false);
    _roomId = _targetRoomCtrl.text.trim();
    await zego.initEngine();
    await zego.loginRoom(_roomId, ZegoUser.id(_myUserId));
    // 发送呼叫信令
    await zego.sendCustomCommand(
      _roomId,
      '{"action":"call","from":"$_myUserId"}',
      [],
    );
    setState(() {
      _callState = CallState.calling;
    });
  }

  /// A端接听
  Future<void> _accept() async {
    final zego = Provider.of<ZegoRoomService>(context, listen: false);
    await zego.startPublish(_myStreamId);
    setState(() {
      _callState = CallState.onCall;
    });
    _startTimer();
  }

  /// 挂断 / 拒绝
  Future<void> _hangUp() async {
    final zego = Provider.of<ZegoRoomService>(context, listen: false);
    await zego.stopPublish();
    await zego.logoutRoom();
    _stopTimer();
    setState(() {
      _callState = CallState.idle;
      _micOn = true;
      _speakerOn = false;
    });
  }

  /// 静音切换
 Future<void> _toggleMic() async {
  final zego = Provider.of<ZegoRoomService>(context, listen: false);
  _micOn = !_micOn;
  // _micOn=true 代表麦克风正常开启，所以 mute=false
  await zego.enableMic(!_micOn);
  setState(() {});
}


  /// 扬声器/听筒切换
  Future<void> _toggleSpeaker() async {
    final zego = Provider.of<ZegoRoomService>(context, listen: false);
    _speakerOn = !_speakerOn;
    await zego.enableSpeaker(_speakerOn);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final zego = Provider.of<ZegoRoomService>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("语音拨号"),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "当前角色：${zego.role == RoleType.a ? "A端【接收方】" : "B端【控制端】"}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // ========== 空闲状态：拨号输入 ==========
            if (_callState == CallState.idle)
              Column(
                children: [
                  TextField(
                    controller: _targetRoomCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "房间号",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: zego.role == RoleType.b ? _call : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("发起呼叫", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 12),
                  const Text("A端等待呼叫，B端才能发起呼叫", style: TextStyle(color: Colors.grey)),
                ],
              ),

            // ========== 呼叫中 ==========
            if (_callState == CallState.calling)
              Column(
                children: [
                  const Text("正在呼叫...", style: TextStyle(color: Colors.white, fontSize: 22)),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _hangUp,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("取消呼叫", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),

            // ========== 通话中（带计时、静音、扬声器） ==========
            if (_callState == CallState.onCall)
              Column(
                children: [
                  Text(
                    _formatTime(_callSeconds),
                    style: const TextStyle(color: Colors.white, fontSize: 48, letterSpacing: 4),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 静音按钮
                      ElevatedButton(
                        onPressed: _toggleMic,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _micOn ? Colors.grey : Colors.blue,
                        ),
                        child: Text(_micOn ? "静音" : "取消静音"),
                      ),
                      // 扬声器切换
                      ElevatedButton(
                        onPressed: _toggleSpeaker,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _speakerOn ? Colors.blue : Colors.grey,
                        ),
                        child: Text(_speakerOn ? "听筒" : "扬声器"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _hangUp,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("挂断", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
