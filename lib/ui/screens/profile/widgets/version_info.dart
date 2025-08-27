import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfo extends StatefulWidget {
  const VersionInfo({super.key});

  @override
  State<VersionInfo> createState() => _VersionInfoState();
}

class _VersionInfoState extends State<VersionInfo> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = 'Version ${packageInfo.version}';
      });
    } catch (e) {
      setState(() {
        _version = 'Version 2.1.0'; // Fallback version
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          _version,
          style: const TextStyle(
            fontSize: 15,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ),
    );
  }
}
