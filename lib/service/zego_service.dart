import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

enum RoleType { a, b }

class ZegoService extends ChangeNotifier {
  // ========== 【这里一定要替换成你自己ZEGO后台的信息】 ==========
  static const int appID = 491443522;
  static const String appSign = "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204";
  // ==========================================================

  RoleType role = RoleType.a;
  String? localUserID;
  String? roomID;
  bool isInRoom = false;

  final AudioPlayer busyPlayer = AudioPlayer();
  final AudioPlayer emptyPlayer = AudioPlayer();

  ZegoService() {
    initSDK();
  }

  void setRole(RoleType r) {
    role = r;
    notifyListeners();
  }

  Future<void> initSDK() async {
    if(kIsWeb) return;
    await ZegoExpressEngine.createEngine(appID, appSign, true, ZegoScenario.General);
    ZegoExpressEngine.onRoomStreamUpdate = _onRoomStreamUpdate;
    ZegoExpressEngine.onRecvCustomCommand = _onRecvCustomCommand;
  }

  // 收到B端下发指令
  Future<void> _onRecvCustomCommand(String roomID, String fromUserID, String command) async {
    debugPrint("收到指令：$command");
    if(role != RoleType.a) return;
    if(command == "busy"){
      await busyPlayer.play(AssetSource("sound/busy.mp3"));
    }else if(command == "empty"){
      await emptyPlayer.play(AssetSource("sound/empty_number.mp3"));
    }
  }

  void _onRoomStreamUpdate(String roomID, ZegoUpdateType updateType, List<ZegoStream> streamList, Map<String, dynamic> extendedData) {
    if(updateType == ZegoUpdateType.Add){
      for(var s in streamList){
        ZegoExpressEngine.instance().startPlayingStream(s.streamID);
      }
    }
  }

  Future<void> startCall({required String remoteUserID}) async {
    localUserID = DateTime.now().millisecondsSinceEpoch.toString();
    roomID = "room_$remoteUserID";

    await ZegoExpressEngine.instance().loginRoom(roomID!, ZegoUser(localUserID!, localUserID));
    await ZegoExpressEngine.instance().startPublishingStream(localUserID!);
    await ZegoExpressEngine.instance().startAudioCapture();
    await ZegoExpressEngine.instance().setAudioRouteToSpeaker(true);
    isInRoom = true;
    notifyListeners();
  }

  // B端发送自定义指令
  Future<void> sendCommand(String cmd) async {
    if(!isInRoom || role != RoleType.b) return;
    await ZegoExpressEngine.instance().sendCustomCommand(roomID!, cmd);
  }

  // 变声接口：简单示例，你可以在UI再加按钮调用
  Future<void> setVoiceChange(ZegoVoiceChangerType type) async {
    await ZegoExpressEngine.instance().setVoiceChangerType(type);
  }

  Future<void> stopCall() async {
    await ZegoExpressEngine.instance().stopPublishingStream();
    await ZegoExpressEngine.instance().logoutRoom();
    isInRoom = false;
    notifyListeners();
  }

  @override
  void dispose() {
    busyPlayer.dispose();
    emptyPlayer.dispose();
    ZegoExpressEngine.destroyEngine();
    super.dispose();
  }
}
