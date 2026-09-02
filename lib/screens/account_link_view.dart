import 'package:flutter/material.dart';
import '../widgets/game_header.dart';
import '../utils/app_texts.dart';

class AccountLinkView extends StatelessWidget {
  const AccountLinkView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const GameHeader(titleKey: 'account'),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Guest #1024'),
            subtitle: Text(AppTexts.get('guestPlaying')),
          ),
        ),
        const SizedBox(height: 16),
        _link(context, 'Google', Icons.g_mobiledata),
        _link(context, 'Apple', Icons.apple),
        const SizedBox(height: 20),
        Text(
          AppTexts.get('accountLinkDesc'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    ),
  );

  Widget _link(BuildContext context, String service, IconData icon) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text('$service ${AppTexts.get('linkAccount')}'),
      trailing: OutlinedButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$service ${AppTexts.get('linkStarted')}')),
        ),
        child: Text(AppTexts.get('link')),
      ),
    ),
  );
}
