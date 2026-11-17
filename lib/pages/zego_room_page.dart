import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoRoomService {
  static final ZegoRoomService instance = ZegoRoomService._internal();
  ZegoRoomService._internal();

  final ValueNotifier<List<String>> remoteStreamIdList = ValueNotifier([]);

  Future<void> initEngine() async {
    const int appID = 491443522;
    const String appSign = "f141828e865741eb46cccf86fb4667b5d808e4e02be0f214dcdcfbe622db4204";

    final profile = ZegoEngineProfile(
      appID,
      ZegoScenario.StandardVoiceCall,
      appSign: appSign,
      enablePlatformView: false,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);

    ZegoExpressEngine.onRoomStreamUpdate = (
      String roomID,
      ZegoUpdateType updateType,
      List<ZegoStream> streamList,
      Map<String, dynamic> extendedData,
    ) {
      debugPrint("onRoomStreamUpdate: updateType=$updateType, count=${streamList.length}");
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          remoteStreamIdList.value = [...remoteStreamIdList.value, stream.streamID];
          ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          remoteStreamIdList.value = remoteStreamIdList.value.where((id) => id != stream.streamID).toList();
          ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
        }
      }
    };

    ZegoExpressEngine.onIMRecvCustomCommand = (
      String roomID,
      ZegoUser fromUser,
      String command,
    ) {
      debugPrint("收到信令命令: $command");
    };
  }

  Future<void> loginRoom(String roomId, ZegoUser user) async {
    await ZegoExpressEngine.instance.loginRoom(roomId, user);
    await ZegoExpressEngine.instance.startPublishingStream("stream_${user.userID}");
  }

  Future<void> logoutRoom() async {
    await ZegoExpressEngine.instance.stopPublishingStream();
    await ZegoExpressEngine.instance.logoutRoom();
    remoteStreamIdList.value = [];
  }

  Future<void> sendCustomCommand(String roomId, String cmd) async {
    final result = await ZegoExpressEngine.instance.sendCustomCommand(roomId, cmd, []);
    debugPrint("sendCustomCommand result code: ${result.errorCode}");
  }

  Future<void> destroy() async {
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onIMRecvCustomCommand = null;
    await ZegoExpressEngine.destroyEngine();
    remoteStreamIdList.value = [];
  }
}
