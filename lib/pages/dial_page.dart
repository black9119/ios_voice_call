import '../root_app.dart';
import 'package:flutter/material.dart';
import '../role.dart';
import 'role_setting_page.dart';

class DialPage extends StatefulWidget {
  final CallRole? role;
  const DialPage({super.key, this.role});

  @override
  State<DialPage> createState() => _DialPageState();
}

class _DialPageState extends State<DialPage> {
  String _inputNumber = "";

  Widget _buildDialKey(String num, String? letter, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(color: Colors.grey),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(num, style: const TextStyle(fontSize: 24, color: Colors.white)),
              if (letter != null) Text(letter, style: const TextStyle(fontSize:12, color:Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  void _onNumberTap(String n) {
    setState(() {
      _inputNumber += n;
    });
    // 隐藏入口：999999999
    if (_inputNumber == "999999999") {
      _inputNumber = "";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoleSettingPage(
            currentRole: widget.role,
            onSaveRole: (r) {
              Navigator.pop(context);
              rootAppKey.currentState?.setRole(r);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("拨号页")),
      body: Center(child: Text("输入号码：$_inputNumber", style: TextStyle(fontSize:22))),
    );
  }
}
