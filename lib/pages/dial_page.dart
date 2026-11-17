import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'setting_page.dart';
import '../service/zego_service.dart';

class DialPage extends StatefulWidget {
  const DialPage({super.key});

  @override
  State<DialPage> createState() => _DialPageState();
}

class _DialPageState extends State<DialPage> {
  String inputNumber = "";
  final String secretCode = "999999999";

  void onNumberTap(String num) {
    setState(() {
      inputNumber += num;
    });
    // 判断是否是秘钥，进入隐藏设置
    if (inputNumber == secretCode) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => const SettingPage()),
      );
      setState(() {
        inputNumber = "";
      });
    }
  }

  void onDelete() {
    if (inputNumber.isNotEmpty) {
      setState(() {
        inputNumber = inputNumber.substring(0, inputNumber.length - 1);
      });
    }
  }

  void onCall() {
    final zego = Provider.of<ZegoService>(context, listen: false);
    if (inputNumber.isEmpty) return;
    zego.startCall(remoteUserID: inputNumber);
  }

  Widget buildKey(String text, {Widget? child}) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.grey[800],
        ),
        onPressed: () => onNumberTap(text),
        child: child ?? Text(
          text,
          style: const TextStyle(fontSize: 28, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zego = Provider.of<ZegoService>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              inputNumber,
              style: const TextStyle(color: Colors.white, fontSize: 36),
            ),
            const SizedBox(height: 40),
            // 拨号键盘 仿iOS布局
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildKey("1"),
                    const SizedBox(width: 16),
                    buildKey("2"),
                    const SizedBox(width: 16),
                    buildKey("3"),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildKey("4"),
                    const SizedBox(width: 16),
                    buildKey("5"),
                    const SizedBox(width: 16),
                    buildKey("6"),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildKey("7"),
                    const SizedBox(width: 16),
                    buildKey("8"),
                    const SizedBox(width: 16),
                    buildKey("9"),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildKey("*"),
                    const SizedBox(width: 16),
                    buildKey("0"),
                    const SizedBox(width: 16),
                    buildKey("#"),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.green,
                        ),
                        onPressed: onCall,
                        child: const Icon(Icons.call, size: 32),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.grey[700],
                        ),
                        onPressed: onDelete,
                        child: const Icon(Icons.backspace, size: 28),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              "当前角色：${zego.role.name}",
              style: const TextStyle(color: Colors.white70, fontSize:16),
            ),
            const SizedBox(height: 10),
            if(zego.role == RoleType.b)
              Wrap(
                spacing:10,
                children: [
                  ElevatedButton(
                    onPressed: ()=> zego.sendCommand("busy"),
                    child: const Text("发送忙音"),
                  ),
                  ElevatedButton(
                    onPressed: ()=> zego.sendCommand("empty"),
                    child: const Text("发送空号"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
