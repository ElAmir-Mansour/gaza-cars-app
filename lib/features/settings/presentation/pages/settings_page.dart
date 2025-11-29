import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/language_cubit.dart';
import '../bloc/language_state.dart';

import '../../../../features/auth/presentation/bloc/auth_event.dart';

import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(l10n.profile),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.push('/profile');
                },
              ),
              const Divider(),
              ListTile(
                title: Text(l10n.language),
                subtitle: Text(state.locale.languageCode == 'ar' ? 'العربية' : 'English'),
                trailing: DropdownButton<String>(
                  value: state.locale.languageCode,
                  items: const [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: 'ar',
                      child: Text('العربية'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context.read<LanguageCubit>().changeLanguage(newValue);
                    }
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _launchUrl(context, 'https://elamir-mansour.github.io/gaza-cars-app/privacy_policy.html');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _launchUrl(context, 'https://elamir-mansour.github.io/gaza-cars-app/terms_of_service.html');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About App'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.push('/about');
                },
              ),
              const Divider(),

              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account?'),
                      content: const Text(
                        'This action is irreversible. All your data, including listings and chats, will be permanently deleted.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<AuthBloc>().add(DeleteAccountEvent());
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }


  Future<void> _launchUrl(BuildContext context, String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }
}
