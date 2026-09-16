import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 앱 버전 문자열 생성 (예: v1.0.0+3)
String appVersionString(PackageInfo info) => 'v${info.version}+${info.buildNumber}';

/// 공용 앱 버전 표시 위젯 (타이틀/로딩/설정 공용)
class AppVersionText extends StatelessWidget {
  const AppVersionText({super.key, this.prefix = '', this.style});

  final String prefix;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final text = info == null
            ? '${prefix}v1.0.0'
            : '$prefix${appVersionString(info)}';
        return Text(text, style: style);
      },
    );
  }
}