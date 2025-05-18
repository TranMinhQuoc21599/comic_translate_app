import 'package:flutter/material.dart';
import '../../../premium/presentation/pages/premium_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Language Preferences'),
          ListTile(
            title: const Text('Source Language'),
            subtitle: const Text('Auto-detect'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement language selection
            },
          ),
          ListTile(
            title: const Text('Target Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement language selection
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'App Settings'),
          SwitchListTile(
            title: const Text('Watermark'),
            subtitle: const Text('Add watermark to translated images'),
            value: true, // TODO: Implement watermark toggle
            onChanged: (bool value) {
              // TODO: Implement watermark toggle
            },
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive translation updates'),
            value: true, // TODO: Implement notifications toggle
            onChanged: (bool value) {
              // TODO: Implement notifications toggle
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Subscription'),
          ListTile(
            title: const Text('Current Plan'),
            subtitle: const Text('Free'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
              child: const Text('Upgrade'),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'About'),
          const ListTile(title: Text('Version'), subtitle: Text('1.0.0')),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            onTap: () {
              // TODO: Open terms of service
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
