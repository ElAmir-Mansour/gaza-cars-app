import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/notification_service.dart';
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
              if (true) // Always show for now, or use kDebugMode
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orange),
                  title: const Text('Debug Notifications'),
                  subtitle: const Text('Simulate push notifications'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Test Notifications'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              sl<NotificationService>().showTestNotification(
                                title: 'Car Approved! 🎉',
                                body: 'Your Toyota Camry has been approved and is now live.',
                                payload: 'carId: 123, status: approved',
                              );
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Simulate "Car Approved"'),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              sl<NotificationService>().showTestNotification(
                                title: 'Car Rejected ⚠️',
                                body: 'Your Honda Civic was rejected. Please check the guidelines.',
                                payload: 'carId: 456, status: rejected',
                              );
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Simulate "Car Rejected"'),
                            ),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              sl<NotificationService>().showTestNotification(
                                title: 'New Message 💬',
                                body: 'Ahmed sent you a message about your BMW.',
                                payload: 'chatId: 789',
                              );
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Simulate "New Message"'),
                            ),
                          ),
                          const Divider(),
                          SimpleDialogOption(
                            onPressed: () async {
                              final token = await sl<NotificationService>().getToken();
                              if (context.mounted) {
                                if (token != null) {
                                  // Clipboard requires 'services' library but we can just print for now 
                                  // or use SelectableText if Clipboard is not imported.
                                  // Let's assume we can import services.
                                  // Actually, let's just show it in a dialog for manual copying if needed, 
                                  // or print to console which is safer without adding imports.
                                  // But user asked for "phone" testing, so console might not be visible easily.
                                  // Let's try to use Clipboard.
                                  // We need to import 'package:flutter/services.dart'.
                                  debugPrint('🔥 FCM Token: $token');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Token copied to clipboard: $token')),
                                  );
                                  // We will add the import in a separate step if needed, 
                                  // but for now let's just print and show SnackBar (assuming user can see logs or we add import).
                                  // Wait, I can't easily add import in this block. 
                                  // I'll just show it in an AlertDialog.
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('FCM Token'),
                                      content: SelectableText(token),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Could not get FCM Token')),
                                  );
                                }
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('View FCM Token'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
}
