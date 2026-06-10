import '/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final box = Hive.box("database");

  Widget tiles(dynamic trailing, String title, Color color, IconData icon, String additionalInfo) {
    return CupertinoListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: CupertinoColors.white),
      ),
      additionalInfo: Text(
        additionalInfo,
        style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
      ),
      trailing: trailing,
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: color,
        ),
        child: Icon(icon, size: 15, color: CupertinoColors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Color(0xFF000000),
        border: null,
        middle: Text(
          'Settings',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      child: ListView(
        children: [
          CupertinoListSection.insetGrouped(
            backgroundColor: const Color(0xFF000000),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            children: [
              tiles(
                CupertinoSwitch(
                  value: box.get("biometrics", defaultValue: false),
                  activeColor: CupertinoColors.systemGreen,
                  onChanged: (value) {
                    setState(() {
                      box.put("biometrics", value);
                    });
                  },
                ),
                'Biometrics',
                CupertinoColors.systemGreen,
                Icons.fingerprint_rounded,
                "",
              ),
              GestureDetector(
                onTap: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) {
                      return CupertinoAlertDialog(
                        title: const Text("Sign Out"),
                        content: const Text("Are you sure you want to sign out?"),
                        actions: [
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text('Sign Out'),
                          ),
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: tiles(
                  const Icon(
                    CupertinoIcons.chevron_forward,
                    color: Color(0xFF636366),
                    size: 14,
                  ),
                  "Sign Out",
                  CupertinoColors.systemRed,
                  Icons.logout,
                  box.get("username", defaultValue: ""),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}