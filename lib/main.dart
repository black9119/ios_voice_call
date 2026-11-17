import 'package:flutter/material.dart';
import 'root_app.dart';
import 'service/zego_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ZegoRoomService.instance.initEngine();
  runApp(const RootApp());
}
