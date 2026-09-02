import 'package:flutter/material.dart';
import '../utils/app_texts.dart';

class GameHeader extends StatelessWidget implements PreferredSizeWidget {
  const GameHeader({
    super.key,
    required this.titleKey,
    this.showBackButton = true,
  });

  final String titleKey;
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    leading: showBackButton && Navigator.of(context).canPop()
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            tooltip: AppTexts.get('back'),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    title: Text(
      AppTexts.get(titleKey),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    ),
    centerTitle: true,
  );
}
