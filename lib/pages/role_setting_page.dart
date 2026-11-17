import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../role.dart';

class RoleSettingPage extends StatefulWidget {
  final CallRole? currentRole;
  final Function(CallRole) onSaveRole;
  const RoleSettingPage({super.key, required this.currentRole, required this.onSaveRole});

  @override
  State<RoleSettingPage> createState() => _RoleSettingPageState();
}

class _RoleSettingPageState extends State<RoleSettingPage> {
  late CallRole? _selectedRole;
  bool _voiceChangerOn = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole;
  }

  void _switchVoiceChanger(bool enable) {
    setState(() => _voiceChangerOn = enable);
    if (enable) {
      ZegoExpressEngine.instance.setVoiceChangerPreset(ZegoVoiceChangerPreset.MaleMagnetic);
    } else {
      ZegoExpressEngine.instance.setVoiceChangerPreset(ZegoVoiceChangerPreset.None);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("角色与变声设置")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("选择角色", style: TextStyle(fontSize:20)),
            ListTile(
              title: const Text("A端【接收方，播放/空号】"),
              selected: _selectedRole == CallRole.a,
              onTap: ()=>setState(()=>_selectedRole = CallRole.a),
            ),
            ListTile(
              title: const Text("B端【发送方，呼叫】"),
              selected: _selectedRole == CallRole.b,
              onTap: ()=>setState(()=>_selectedRole = CallRole.b),
            ),
            const SizedBox(height:20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("开启磁性男声变声"),
                Switch(value: _voiceChangerOn, onChanged: _switchVoiceChanger),
              ],
            ),
            const SizedBox(height:30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  if(_selectedRole != null){
                    widget.onSaveRole(_selectedRole!);
                  }
                },
                child: const Text("保存"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
