import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

// 角色枚举
enum RoleType {
  a, // A端接收方
  b, // B端控制方
}

class ZegoRoomService extends ChangeNotifier {
  static final ZegoRoomService instance = ZegoRoomService._internal();
  ZegoRoomService._internal();

  ZegoExpressEngine? _engine;
  final ValueNotifier<List<String>> remoteStreamIdList = ValueNotifier([]);

  RoleType role = RoleType.a;

  void setRole(RoleType r) {
    role = r;
    notifyListeners();
  }

  Future<void> initEngine() async {
    if (_engine != null) return;

    final ZegoEngineProfile profile = ZegoEngineProfile(
      491443522,
      ZegoScenario.StandardVoiceCall,
      appSign: "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204",
      enablePlatformView: false,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);
    _engine = ZegoExpressEngine.instance;

    await ZegoExpressEngine.instance.enableCamera(false);

    ZegoExpressEngine.onRoomStreamUpdate = (
      String roomID,
      ZegoUpdateType updateType,
      List<ZegoStream> streamList,
      Map<String, dynamic> extendedData,
    ) {
      final List<String> newList = [...remoteStreamIdList.value];
      for (final stream in streamList) {
        if (updateType == ZegoUpdateType.Add) {
          if (!newList.contains(stream.streamID)) {
            newList.add(stream.streamID);
            ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
          }
        } else {
          newList.remove(stream.streamID);
          ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
        }
      }
      remoteStreamIdList.value = newList;
    };

    ZegoExpressEngine.onIMRecvCustomCommand = (
      String roomID,
      ZegoUser fromUser,
      String command,
    ) {
      debugPrint('收到信令 user:${fromUser.userID}, cmd=$command');
    };

    ZegoExpressEngine.onRoomStateUpdate = (
      String roomID,
      ZegoRoomState state,
      int errorCode,
      Map<String, dynamic> extendedData,
    ) {
      debugPrint('房间状态 room:$roomID state:$state err:$errorCode');
    };
  }

  Future<void> loginRoom(String roomID, ZegoUser user) async {
    final config = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;
    await ZegoExpressEngine.instance.loginRoom(roomID, user, config: config);
  }

  Future<void> logoutRoom() async {
    await ZegoExpressEngine.instance.logoutRoom();
    remoteStreamIdList.value = [];
  }

  Future<void> startPublish(String streamID) async {
    await ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublish() async {
    await ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> sendCustomCommand(
    String roomID,
    String command,
    List<ZegoUser> targetUsers,
  ) async {
    final ZegoIMSendCustomCommandResult res =
        await ZegoExpressEngine.instance.sendCustomCommand(roomID, command, targetUsers);
    if (res.errorCode != 0) {
      debugPrint('发送信令失败 code:${res.errorCode}');
    }
  }

  Future<void> destroy() async {
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onIMRecvCustomCommand = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    remoteStreamIdList.value = [];
    await ZegoExpressEngine.destroyEngine();
    _engine = null;
  }

  // 麦克风静音（通话中静音，推荐这个）
Future<void> enableMic(bool mute) async {
  await ZegoExpressEngine.instance.muteMicrophone(mute);
}

// 听筒 / 扬声器切换
Future<void> enableSpeaker(bool toSpeaker) async {
  await ZegoExpressEngine.instance.setAudioRouteToSpeaker(toSpeaker);
}

}
